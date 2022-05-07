// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../session/interfaces/ISessionManager.sol";
import "../session/interfaces/ISessionFees.sol";
import "../periphery/interfaces/IMaker.sol";
import "../periphery/interfaces/ITaker.sol";
import "../farm/interfaces/ICrssToken.sol"; 
import "../farm/interfaces/IXCrssToken.sol";
import "../core/interfaces/ICrossPair.sol";
import "../farm/interfaces/ICrssReferral.sol";
import "../farm/interfaces/IMigratorChef.sol";
import "../farm/interfaces/ICrossFarmTypes.sol";
import "../farm/interfaces/ICrossFarm.sol";
import "../libraries/utils/TransferHelper.sol";
import "./math/SafeMath.sol";

import "hardhat/console.sol";

library FarmLibrary {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    function changeLpTokensToCrssInFarm(
        address sourceLpToken, 
        IMaker maker, 
        ITaker taker, 
        address token, 
        uint256 lpAmount
        ) external returns(uint256 newCrss) {
        if (address(sourceLpToken) != address(0) && lpAmount > 0) {

            if (sourceLpToken == token) {
                newCrss = lpAmount;

            } else {
                address token0 = ICrossPair(sourceLpToken).token0();
                address token1 = ICrossPair(sourceLpToken).token1();
                bool foundDirectSwapPath;
                {
                    address pair0 = maker.getPair(token, token0);
                    address pair1 = maker.getPair(token, token1);
                    foundDirectSwapPath = (address(token) == token0 || pair0 != address(0)) && (token == token1 || pair1 != address(0));
                }
                require(foundDirectSwapPath, "Swap path not found");

                uint256 balance0_old = IERC20(token0).balanceOf(address(this));
                uint256 balance1_old = IERC20(token1).balanceOf(address(this));
                IMaker(maker).removeLiquidity(token0, token1, lpAmount, 0, 0, address(this), block.timestamp);
                uint256 amount0 = IERC20(token0).balanceOf(address(this)) - balance0_old;
                uint256 amount1 = IERC20(token1).balanceOf(address(this)) - balance1_old;

                require( amount0 > 0 && amount1 > 0, "RemoveLiqudity failed");
                newCrss += _swapExactNonCrssToCrss(taker, token, token0, token, amount0);
                newCrss += _swapExactNonCrssToCrss(taker, token, token1, token, amount1);
            }
        }
    }

    function changeCrssInXTokenToLpInFarm(address targetLpToken, Nodes storage nodes, uint256 amountCrssInXToken, address dustBin) 
    public returns (uint256 newLpAmountInFarm) {
        if (targetLpToken != address(0) && amountCrssInXToken > 0) {
            uint256 balance0 = ICrssToken(nodes.token).balanceOf(address(this));
            tolerableCrssTransferFromXTokenAccount(nodes.xToken, address(this), amountCrssInXToken);
            uint256 balance1 = ICrssToken(nodes.token).balanceOf(address(this));
            uint256 amountCrssInFarm = balance1 - balance0;

            if (targetLpToken == nodes.token) {
                newLpAmountInFarm = amountCrssInFarm;  // pending rewards, by definition, reside in token.balanceOf[address(this)].

            } else {
                address token0 = ICrossPair(targetLpToken).token0();
                address token1 = ICrossPair(targetLpToken).token1();
                bool foundDirectSwapPath;
                {
                    address pair0 = IMaker(nodes.maker).getPair(nodes.token, token0);
                    address pair1 = IMaker(nodes.maker).getPair(nodes.token, token1);
                    foundDirectSwapPath = (nodes.token == token0 || pair0 != address(0)) && (nodes.token == token1 || pair1 != address(0));
                }
                require(foundDirectSwapPath, "Swap path not found");

                uint256 amount0 = amountCrssInFarm / 2;
                uint256 amount1 = amountCrssInFarm - amount0;
                amount0 = _swapExactCrssToNonCrss(ITaker(nodes.taker), nodes.token, nodes.token, token0, amount0);
                amount1 = _swapExactCrssToNonCrss(ITaker(nodes.taker), nodes.token, nodes.token, token1, amount1);
                
                require( amount0 > 0 && amount1 > 0, "Swap failed");
                balance0 = ICrossPair(targetLpToken).balanceOf(address(this));
                IERC20(token0).safeIncreaseAllowance(nodes.maker, amount0);
                IERC20(token1).safeIncreaseAllowance(nodes.maker, amount1);
                (uint256 _amount0, uint256 _amount1, ) =IMaker(nodes.maker).addLiquidity(token0, token1, amount0, amount1, 0, 0, address(this), block.timestamp);
                balance1 = ICrossPair(targetLpToken).balanceOf(address(this));

                if (_amount0 < amount0) TransferHelper.safeTransfer(token0, dustBin, amount0 - _amount0); // remove dust
                if (_amount1 < amount1) TransferHelper.safeTransfer(token1, dustBin, amount1 - _amount1); // remove dust

                newLpAmountInFarm = balance1 - balance0;
            }
        }
    }


    function _swapExactCrssToNonCrss(
        ITaker taker,
        address token,
        address tokenFr,
        address tokenTo,
        uint256 amount
    ) internal returns (uint256 resultingAmount){

        if (tokenTo == token) {
            resultingAmount = amount;

        } else if (tokenFr != tokenTo) {
            uint256 balance0 = IERC20(tokenTo).balanceOf(address(this));

            ICrssToken(tokenFr).approve(address(taker), amount);
            address[] memory path = new address[](2);
            path[0] = tokenFr;
            path[1] = tokenTo;
            taker.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amount,
                0, // in trust of taker's price control.
                path,
                address(this),
                block.timestamp
            );
            resultingAmount = IERC20(tokenTo).balanceOf(address(this)) - balance0;
        } else {
            resultingAmount = amount;
        }
    }

    function _swapExactNonCrssToCrss(
        ITaker taker,
        address token,
        address tokenFr,
        address tokenTo,
        uint256 amount
    ) internal returns (uint256 resultingAmount) {

        if (tokenFr == token) {
            resultingAmount = amount;

        } else if (tokenFr != tokenTo) {
            uint256 balance0 = IERC20(tokenTo).balanceOf(address(this));

            ICrssToken(tokenFr).approve(address(taker), amount);
            address[] memory path = new address[](2);
            path[0] = tokenFr;
            path[1] = tokenTo;
            taker.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amount,
                0, // in trust of taker's price control.
                path,
                address(this),
                block.timestamp
            );
            resultingAmount = IERC20(tokenTo).balanceOf(address(this)) - balance0;
        } else {
            resultingAmount = amount;
        }
    }

    function swapExactTokenForToken(
        ITaker taker,
        address token,
        address tokenFr,
        address tokenTo,
        uint256 amount
    ) external returns (uint256 tokenToAmount){
        if (tokenFr != tokenTo) {
            uint256 _tokenToAmt = IERC20(tokenTo).balanceOf(address(this));

            ICrssToken(token).approve(address(taker), amount);
            address[] memory path = new address[](2);
            path[0] = tokenFr;
            path[1] = tokenTo;
            taker.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amount,
                0, // in trust of taker's price control.
                path,
                address(this),
                block.timestamp
            );
            tokenToAmount = IERC20(tokenTo).balanceOf(address(this)) - _tokenToAmt;
        } else {
            return amount;
        }
    }

    function getTotalVestPrincipals(VestChunk[] storage vestList) public view returns (uint amount) {
        for (uint256 i = 0; i < vestList.length; i++) {
            amount += vestList[i].principal;
        }
    }

    function getTotalMatureVestPieces(VestChunk[] storage vestList, uint256 vestMonths) public view returns (uint amount) {
        for (uint256 i = 0; i < vestList.length; i++) {
            // Time simulation for test: 600 * 24 * 30. A hardhat block pushes 2 seconds of timestamp. 3 blocks will be equivalent to a month.
            uint256 elapsed = (block.timestamp - vestList[i].startTime) * 600 * 24 * 30; 
            uint256 monthsElapsed = elapsed / month >= vestMonths ? vestMonths : elapsed / month;
            uint256 unlockAmount = vestList[i].principal * monthsElapsed / vestMonths - vestList[i].withdrawn;
            amount += unlockAmount;
        }
    }

    function withdrawVestPieces(VestChunk[] storage vestList, uint256 vestMonths, uint amount) internal returns (uint256 _amount) {
        _amount = amount;

        uint256 i;
        while( _amount > 0 && i < vestList.length ) {
            // Time simulation for test: 600 * 24 * 30. A hardhat block pushes 2 seconds of timestamp. 3 blocks will be equivalent to a month.
            uint256 elapsed = (block.timestamp - vestList[i].startTime) * 600 * 24 * 30;
            uint256 monthsElapsed = elapsed / month >= vestMonths ? vestMonths : elapsed / month;
            uint256 unlockAmount = vestList[i].principal * monthsElapsed / vestMonths - vestList[i].withdrawn;
            if (unlockAmount > _amount) {
                vestList[i].withdrawn += _amount; // so, vestList[i].withdrawn < vestList[i].principal * monthsElapsed / vestMonths.
                _amount = 0;
            } else {
                _amount -= unlockAmount;
                vestList[i].withdrawn += unlockAmount; // so, vestList[i].withdrawn == vestList[i].principal * monthsElapsed / vestMonths.
            }
            if (vestList[i].withdrawn == vestList[i].principal) {  // if and only if monthsElapsed == vestMonths.
                for (uint256 j = i; j < vestList.length - 1; j++) vestList[j] = vestList[j + 1];
                vestList.pop();
            } else {
                i ++;
            }
        }
    }
    
    /**
    * @dev Transfer Crss amount with tolerance against (small?) numeric errors.
    */
    function tolerableCrssTransferFromXTokenAccount(address xToken, address _to, uint256 _amount) public {
        IXCrssToken(xToken).safeCrssTransfer(_to, _amount);
    }



    //============================================= Rewardds ===================================================
    //==========================================================================================================

    function takePendingCollectively(PoolInfo storage pool, FarmFeeParams storage feeParams, Nodes storage nodes) public {
        uint256 subPoolPending;
        uint256 totalRewards;

        uint256 lpSupply = pool.lpToken.balanceOf(address(this));

        //-------------------- OnOff SubPool Group Takes -------------------- Compound On, Vest Off
        if (lpSupply > 0) {
            subPoolPending = (pool.OnOff.sumAmount + pool.OnOff.Comp.bulk) * pool.reward / lpSupply;
        } else { subPoolPending = 0; }

        totalRewards += subPoolPending;
        if (subPoolPending > 0) {
            uint256 feePaid = subPoolPending * feeParams.nonVestBurnRate / FeeMagnifier;
            ICrssToken(nodes.token).burn(nodes.xToken, feePaid);
            subPoolPending -= feePaid;
            subPoolPending -= payCompoundFee(nodes.token, feeParams, subPoolPending, nodes);
            uint256 newLpAmountInFarm = changeCrssInXTokenToLpInFarm(address(pool.lpToken), nodes, subPoolPending, feeParams.treasury);
            _addToSubPool(pool.OnOff.Comp, pool.OnOff.sumAmount, newLpAmountInFarm); // updates bulk & accPerShare.
        }

        //-------------------- OnOn SubPool Group Takes -------------------- Compound On, Vest On

        if (lpSupply > 0) {
            subPoolPending = (pool.OnOn.sumAmount + pool.OnOn.Comp.bulk) * pool.reward / lpSupply;
        } else { subPoolPending = 0; }

        totalRewards += subPoolPending;
        if (subPoolPending > 0 ) {
            uint256 halfToCompound = subPoolPending / 2;
            uint256 halfToVest = subPoolPending - halfToCompound;
            halfToCompound -= payCompoundFee(nodes.token, feeParams, halfToCompound, nodes);
            uint256 newLpAmountInFarm = changeCrssInXTokenToLpInFarm(address(pool.lpToken), nodes, halfToCompound, feeParams.treasury);
            _addToSubPool(pool.OnOn.Comp, pool.OnOn.sumAmount, newLpAmountInFarm); // updates bulk & accPerShare.
            _addToSubPool(pool.OnOn.Vest, pool.OnOn.sumAmount, halfToVest); // updates bulk & accPerShare.
        }

        //-------------------- OffOn SubPool Group Takes -------------------- Compound Off, Vest On

        if (lpSupply > 0) {
            subPoolPending = (pool.OffOn.sumAmount) * pool.reward / lpSupply;
        } else { subPoolPending = 0; }

        totalRewards += subPoolPending;
        if (subPoolPending > 0) {
            uint256 halfToVest = subPoolPending / 2;
            uint256 halfToSend = subPoolPending - halfToVest;
            _addToSubPool(pool.OffOn.Vest, pool.OffOn.sumAmount, halfToVest); // updates bulk & accPerShare.
            _addToSubPool(pool.OffOn.Accum, pool.OffOn.sumAmount, halfToSend); // updates bulk & accPerShare.
        }

        //-------------------- OffOff SubPool Group Takes -------------------- Compound Off, Vest Off

        if (lpSupply > 0) {
            subPoolPending = (pool.OffOff.sumAmount) * pool.reward / lpSupply;
        } else { subPoolPending = 0; }

        totalRewards += subPoolPending;
        if (subPoolPending > 0) {
            uint256 feePaid = subPoolPending * feeParams.nonVestBurnRate / FeeMagnifier;
            ICrssToken(nodes.token).burn(nodes.xToken, feePaid);
            subPoolPending -= feePaid;
            _addToSubPool(pool.OffOff.Accum, pool.OffOff.sumAmount, subPoolPending); // updates bulk & accPerShare.
        }

        //assert( pool.lpToken.balanceOf(address(this)) == checkSum );

        checkConsistency(pool, "after collective");
        if (pool.reward < totalRewards) {
            console.log("---", totalRewards - pool.reward, "pool.reward < totalRewards");
            console.log("pool.OnOff.sumAmount, Comp.bulk", pool.OnOff.sumAmount, pool.OnOff.Comp.bulk);
            console.log("pool.OnOn.sumAmount, Comp.bulk", pool.OnOn.sumAmount, pool.OnOn.Comp.bulk);
            console.log("pool.OffOn.sumAmount", pool.OffOn.sumAmount);
            console.log("pool.OffOff.sumAmount", pool.OffOff.sumAmount);

        }
    }

    function checkConsistency(PoolInfo storage pool, string memory tag) public view {
        // ------------------------------ Check ----------------------------

        uint256 balance = pool.lpToken.balanceOf(address(this));
        uint256 checkSum = pool.OnOff.sumAmount + pool.OnOff.Comp.bulk + pool.OnOn.sumAmount + pool.OnOn.Comp.bulk
        + pool.OffOn.sumAmount + pool.OffOff.sumAmount;

        if (balance != checkSum) {
            if (balance < checkSum) {
                console.log(tag, "balance < checksum", (checkSum - balance) * 1e12 /checkSum); 
            } else {
                console.log(tag, "balance > checksum", (balance - checkSum) * 1e12 / balance );
            }
            console.log("lp Balanace, checkSum", balance, checkSum);
            console.log("pool.OnOff.sumAmount, Comp.bulk", pool.OnOff.sumAmount, pool.OnOff.Comp.bulk);
            console.log("pool.OnOn.sumAmount, Comp.bulk", pool.OnOn.sumAmount, pool.OnOn.Comp.bulk);
            console.log("pool.OffOn.sumAmount", pool.OffOn.sumAmount);
            console.log("pool.OffOff.sumAmount", pool.OffOff.sumAmount);
        }
    }

    function _addToSubPool(SubPool storage subPool, uint256 totalShare, uint256 newAmount) internal {
        subPool.bulk += newAmount;
        if (totalShare > 0) {
            subPool.accPerShare += ( newAmount * 1e12 / totalShare); // Note that inteter devision is not greater than real division. So it's safe.
        } else { 
            console.log("\t --------------- totalShare = 0, compound dust, acc", newAmount, subPool.accPerShare); // newAmount should be compound dust. Ignore it.
            //subPool.accPerShare = 1e12; 
        }
    }

    function payCompoundFee(address payerToken, FarmFeeParams storage feeParams, uint256 amount, Nodes storage nodes) public returns (uint256 feesPaid) {
        feesPaid = amount * feeParams.compoundFeeRate / FeeMagnifier;
        if (feesPaid > 0) {
            uint256 half = feesPaid / 2;
            if (payerToken == nodes.token) {
                tolerableCrssTransferFromXTokenAccount(nodes.xToken, feeParams.stakeholders, half);
                tolerableCrssTransferFromXTokenAccount(nodes.xToken, feeParams.treasury, feesPaid - half);
            } else {
                TransferHelper.safeTransfer(payerToken, feeParams.stakeholders, half);
                TransferHelper.safeTransfer(payerToken, feeParams.treasury, feesPaid - half);
            }
        }
    }

    function pyaReferralComission(PoolInfo storage pool, UserInfo storage user, 
    address msgSender, FarmFeeParams storage feeParams, Nodes storage nodes)
    public {
        //-------------------- Pay referral fee outside of user's pending reward --------------------
        uint256 userPending = getRewardPayroll(pool, user) * pool.accCrssPerShare / 1e12 - user.rewardDebt; // This is the only place user.rewardDebt works explicitly.
        if (userPending > 0) {
            _mintReferralCommission(msgSender, userPending, feeParams, nodes);
            //user.rewardDebt = getRewardPayroll(pool, user) * pool.accCrssPerShare / 1e12;
        }
    }

    /**
     * @dev Take the current rewards related to user's deposit, so that the user can change their deposit further.
    */

    function takeIndividualReward(PoolInfo storage pool, UserInfo storage user) public {

        //-------------------- Calling User Takes -------------------------------------------------------------------------
        if (user.collectOption == CollectOption.OnOff && user.amount > 0) {
            uint256 userCompound = user.amount * pool.OnOff.Comp.accPerShare / 1e12 - user.debt1;
            if (userCompound > 0) {
                if (pool.OnOff.Comp.bulk < userCompound) userCompound =  pool.OnOff.Comp.bulk;
                pool.OnOff.Comp.bulk -= userCompound;
                user.amount += userCompound;  //---------- Compound
                pool.OnOff.sumAmount += userCompound;
                user.debt1 = user.amount * pool.OnOff.Comp.accPerShare / 1e12;
            }

        } else if (user.collectOption == CollectOption.OnOn && user.amount > 0) {
            uint256 userAmount = user.amount;
            uint256 userCompound = userAmount * pool.OnOn.Comp.accPerShare / 1e12 - user.debt1;
            if (userCompound > 0) {
                if (pool.OnOn.Comp.bulk < userCompound ) userCompound = pool.OnOn.Comp.bulk;
                pool.OnOn.Comp.bulk -= userCompound;
                user.amount += userCompound;  //---------- Compound
                pool.OnOn.sumAmount += userCompound;
                user.debt1 = user.amount * pool.OnOn.Comp.accPerShare / 1e12;
            }

            uint256 userVest = userAmount * pool.OnOn.Vest.accPerShare / 1e12 - user.debt2;
            if (userVest > 0) {
                if (pool.OnOn.Vest.bulk < userVest) userVest = pool.OnOn.Vest.bulk;
                pool.OnOn.Vest.bulk -= userVest;
                user.vestList.push( VestChunk ( {principal: userVest, withdrawn: 0, startTime: block.timestamp } ) ); //---------- Put in vesting
                user.debt2 =  user.amount * pool.OnOn.Vest.accPerShare / 1e12;
            }  

        } else if (user.collectOption == CollectOption.OffOn && user.amount > 0) {
            uint256 userAmount = user.amount;
            uint256 userVest = userAmount * pool.OffOn.Vest.accPerShare / 1e12 - user.debt1;
            if (userVest > 0) {
                if (pool.OffOn.Vest.bulk < userVest) userVest = pool.OffOn.Vest.bulk;
                pool.OffOn.Vest.bulk -= userVest;
                user.vestList.push( VestChunk ( {principal: userVest, withdrawn: 0, startTime: block.timestamp } ) ); //---------- Put in vesting.
                user.debt1 = user.amount * pool.OffOn.Vest.accPerShare / 1e12;
            }

            uint256 userAccum = userAmount * pool.OffOn.Accum.accPerShare / 1e12 - user.debt2;
            if (userAccum > 0) {
                if (pool.OffOn.Accum.bulk < userAccum) userAccum = pool.OffOn.Accum.bulk;
                pool.OffOn.Accum.bulk -= userAccum;
                user.accumulated += userAccum; //---------- Accumulate.
                user.debt2 = user.amount * pool.OffOn.Accum.accPerShare / 1e12;
            }

        } else if (user.collectOption == CollectOption.OffOff && user.amount > 0) {
            uint256 userAccum = user.amount * pool.OffOff.Accum.accPerShare / 1e12 - user.debt1;
            if (userAccum > 0) {
                if (pool.OffOff.Accum.bulk < userAccum) userAccum = pool.OffOff.Accum.bulk;
                pool.OffOff.Accum.bulk -= userAccum;
                user.accumulated += userAccum; //---------- Accumulate.
                //user.debt1 = user.amount * pool.OffOff.Accum.accPerShare / 1e12;
            }
        }

        user.rewardDebt = getRewardPayroll(pool, user) * pool.accCrssPerShare / 1e12;
    }

    /**
    * @dev Begine a new rewarding interval with a new user.amount.
    * @dev Change the user.amount value, change branches' sum of user.amounts, and reset all debt so that pendings are zero now.
    * Note: This is not the place to upgrade accPerShare, because this call is not a reward gain.
    * Reward gain, instead, takes place in _updatePool, for pools, and _takeIndividualRewards, for branches and subpools.
    */
    function startRewardCycle(
        PoolInfo storage pool, 
        UserInfo storage user, 
        uint256 amount, 
        FarmFeeParams storage feeParams, 
        bool addNotSubtract) 
        public {
        // Open it for 0 amount, as it re-bases user debts.

        user.amount = addNotSubtract ? (user.amount + amount) : (user.amount - amount);

        if (user.collectOption == CollectOption.OnOff) {
            pool.OnOff.sumAmount = addNotSubtract ? pool.OnOff.sumAmount + amount : pool.OnOff.sumAmount - amount;
            user.debt1 = user.amount * pool.OnOff.Comp.accPerShare / 1e12;

            if (pool.OnOff.sumAmount == 0) { // user.amount is also 0.
                if (pool.OnOff.Comp.bulk > 0) { // residue dust grew over 1%.
                    pool.lpToken.safeTransfer(feeParams.treasury, pool.OnOff.Comp.bulk);
                    pool.OnOff.Comp.bulk = 0;
                }
            }

        } else if (user.collectOption == CollectOption.OnOn) {
            pool.OnOn.sumAmount = addNotSubtract ? pool.OnOn.sumAmount + amount : pool.OnOn.sumAmount - amount;
            user.debt1 = user.amount * pool.OnOn.Comp.accPerShare / 1e12;
            user.debt2 =  user.amount * pool.OnOn.Vest.accPerShare / 1e12;

            if (pool.OnOn.sumAmount == 0) { // user.amount is also 0.
                if (pool.OnOn.Comp.bulk > 0) { // residue dust grew over 1%.
                    pool.lpToken.safeTransfer(feeParams.treasury, pool.OnOn.Comp.bulk);
                    pool.OnOn.Comp.bulk = 0;
                }
            }

        } else if (user.collectOption == CollectOption.OffOn) {
            pool.OffOn.sumAmount = addNotSubtract ? pool.OffOn.sumAmount + amount : pool.OffOn.sumAmount - amount;
            user.debt1 = user.amount * pool.OffOn.Vest.accPerShare / 1e12;
            user.debt2 =  user.amount * pool.OffOn.Accum.accPerShare / 1e12;

        } else if (user.collectOption == CollectOption.OffOff) {
            pool.OffOff.sumAmount = addNotSubtract ? pool.OffOff.sumAmount + amount : pool.OffOff.sumAmount - amount;
            user.debt1 = user.amount * pool.OffOff.Accum.accPerShare / 1e12;
        }

        user.rewardDebt = getRewardPayroll(pool, user) * pool.accCrssPerShare / 1e12;
    }

    /**
     * @dev Take the current rewards related to user's deposit, so that the user can change their deposit further.
    */

    function getRewardPayroll(PoolInfo storage pool, UserInfo storage user) 
    public view returns (uint256 userLp) {

        userLp = user.amount;

        if (user.collectOption == CollectOption.OnOff && user.amount > 0) {
            userLp += (user.amount * pool.OnOff.Comp.accPerShare / 1e12 - user.debt1);  //---------- Compound

        } else if (user.collectOption == CollectOption.OnOn && user.amount > 0) {
            userLp += (user.amount * pool.OnOn.Comp.accPerShare / 1e12 - user.debt1);  //---------- Compound

        }
    }

    /**
    * @dev Pay referral commission to the referrer who referred this user.
    */
    function _mintReferralCommission(address _user, uint256 principal, FarmFeeParams storage feeParams, Nodes storage nodes) internal {
        uint256 commission = principal.mul(feeParams.referralCommissionRate).div(FeeMagnifier);
        if (feeParams.crssReferral != address(0) && commission > 0) {
            address referrer = ICrssReferral(feeParams.crssReferral).getReferrer(_user);
            if (referrer != address(0)) {
                ICrssToken(nodes.token).mint(referrer, commission);
                ICrssReferral(feeParams.crssReferral).recordReferralCommission(referrer, commission);
            }
        }
    }

    function migratePool(PoolInfo storage pool, IMigratorChef migrator) external returns (IERC20 newLpToken) {
        IERC20 lpToken = pool.lpToken;
        uint256 bal = lpToken.balanceOf(address(this));
        lpToken.safeApprove(address(migrator), bal);
        newLpToken = migrator.migrate(lpToken);
        require(bal == newLpToken.balanceOf(address(this)), "migration inconsistent");
    }

    function switchCollectOption(
        PoolInfo storage pool, 
        UserInfo storage user, 
        CollectOption newOption,
        address msgSender, 
        FarmFeeParams storage feeParams, 
        Nodes storage nodes, 
        uint256 totalAllocPoint, 
        uint256 crssPerBlock, 
        uint256 bonusMultiplier
        ) external returns (bool switched) {
        CollectOption orgOption = user.collectOption;

        if (orgOption != newOption) {
            finishRewardCycle(pool, user, msgSender, feeParams, nodes, totalAllocPoint, crssPerBlock, bonusMultiplier);

            uint256 userAmount =  user.amount;
            startRewardCycle(pool, user, userAmount, feeParams, false); // false: addNotSubract

            user.collectOption = newOption;

            startRewardCycle(pool, user, userAmount, feeParams, true); // true: addNotSubract

            switched = true;
        }
    }

    function collectAccumulated(
            address msgSender,
            PoolInfo[] storage poolInfo,
            mapping(uint256 => mapping(address => UserInfo)) storage userInfo,
            FarmFeeParams storage feeParams,
            Nodes storage nodes,
            uint256 totalAllocPoint,
            uint256 crssPerBlock,
            uint256 bonusMultiplier
        ) external returns (uint256 rewards) {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; pid ++) {
            PoolInfo storage pool = poolInfo[pid];
            UserInfo storage user = userInfo[pid][msgSender];

            finishRewardCycle(pool, user, msgSender, feeParams, nodes, totalAllocPoint, crssPerBlock, bonusMultiplier);
            rewards += user.accumulated;
            user.accumulated = 0;
        }
    }

    function massCompoundRewards(
        address msgSender, 
        PoolInfo[] storage poolInfo, 
        mapping(uint256 => mapping(address => UserInfo)) storage userInfo, 
        Nodes storage nodes,
        FarmFeeParams storage feeParams
    ) external returns (uint256 totalCompounded, uint256 crssToPay) {
        uint256 len = poolInfo.length;
        for (uint256 pid = 0; pid < len; pid ++) {
            PoolInfo storage pool = poolInfo[pid];
            UserInfo storage user = userInfo[pid][msgSender];
            uint256 accumCrss = user.accumulated;
            if (feeParams.compoundFeeRate > 0) {
                uint256 fee = accumCrss * feeParams.compoundFeeRate / FeeMagnifier;
                accumCrss -= fee;
                crssToPay += fee;
            }
            totalCompounded += accumCrss;
            uint256 newLpAmount = changeCrssInXTokenToLpInFarm(
                address(pool.lpToken), nodes, accumCrss, feeParams.treasury);
            startRewardCycle(pool, user, newLpAmount, feeParams, true);  // true: addNotSubract
            user.accumulated = 0;
        }

        if (crssToPay > 0) {
            uint256 half = crssToPay / 2;
            tolerableCrssTransferFromXTokenAccount(nodes.xToken, feeParams.stakeholders, half);
            tolerableCrssTransferFromXTokenAccount(nodes.xToken, feeParams.treasury, crssToPay - half);
        }
    }

    function updateSpecialPools(PoolInfo[] storage poolInfo) internal returns (uint256 totalAllocPoint) {
        uint256 length = poolInfo.length;
        uint256 points;
        for (uint256 pid = 1; pid < length; ++pid) {
            points = points + poolInfo[pid].allocPoint;
        }
       
        uint256 pointsPerPercent;
        uint256 pointsForStakingPool;

        if (points != 0) {
            pointsPerPercent = points * 1e5 / ( 100 - CrssPoolAllocPercent ); // 25% for Crss staking pool.
            pointsForStakingPool = pointsPerPercent * CrssPoolAllocPercent / 1e5;
            totalAllocPoint = points + pointsForStakingPool;
            poolInfo[0].allocPoint = pointsForStakingPool;
        } else {
           poolInfo[0].allocPoint = 1000;
            totalAllocPoint = 1000;
        }
    }

    function setPool(
        PoolInfo[] storage poolInfo,
        uint256 pid,
        uint256 _allocPoint,
        uint256 _depositFeeRate
    ) external returns (uint256 totalAllocPoint) {
        PoolInfo storage pool = poolInfo[pid];
        pool.allocPoint = _allocPoint;
        pool.depositFeeRate = _depositFeeRate;

        totalAllocPoint = updateSpecialPools(poolInfo);
        require(poolInfo.length <= 1 || _allocPoint * 99 <= totalAllocPoint * (100 - CrssPoolAllocPercent), "Invalid allocPoint");
    }

    function addPool(
        uint256 _allocPoint,
        address _lpToken,
        uint256 _depositFeeRate,
        uint256 startBlock,
        PoolInfo[] storage poolInfo
    ) external returns (uint256 totalAllocPoint) {
        poolInfo.push( buildStandardPool(_lpToken, _allocPoint, startBlock, _depositFeeRate) );

        totalAllocPoint = updateSpecialPools(poolInfo);
        require(poolInfo.length <= 1 || _allocPoint * 99 <= totalAllocPoint * (100 - CrssPoolAllocPercent), "Invalid allocPoint");
    }


    function getMultiplier(uint256 _from, uint256 _to, uint256 bonusMultiplier) public pure returns (uint256) {
        return (_to - _from) * bonusMultiplier;
    }

    /**
    * @dev Mint rewards, and increase the pool's accCrssPerShare, accordingly.
    * accCrssPerShare: the amount of rewards that a user would have gaind NOW 
    * if they had maintained 1e12 LP tokens as user.amount since the very beginning.
    */

    event SetMigrator(address migrator);
    function updatePool(PoolInfo storage pool, uint256 totalAllocPoint, uint256 crssPerBlock, 
    uint256 bonusMultiplier, Nodes storage nodes
    ) public {
        if (block.number >  pool.lastRewardBlock) {
            uint256 lpSupply = pool.lpToken.balanceOf(address(this));

            if (lpSupply > 0) {
                uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number, bonusMultiplier);
                uint256 crssReward = multiplier * crssPerBlock * pool.allocPoint / totalAllocPoint;
                ICrssToken(nodes.token).mint(nodes.xToken, crssReward);
                pool.reward = crssReward; // used as a checksum
                pool.accCrssPerShare += (crssReward * 1e12 / lpSupply);
                pool.lastRewardBlock = block.number;
            }

            pool.lastRewardBlock = block.number;
        }
    }

    function pendingCrss(
    PoolInfo storage pool, 
    UserInfo storage user, 
    uint256 bonusMultiplier,
    uint256 crssPerBlock, 
    uint256 totalAllocPoint
    ) public view returns (uint256) {
        uint256 accCrssPerShare = pool.accCrssPerShare;
        uint256  lpSupply = pool.lpToken.balanceOf(address(this));

        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number, bonusMultiplier);
            uint256 crssReward = multiplier.mul(crssPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accCrssPerShare += (crssReward * 1e12 / lpSupply);
        }       
        return getRewardPayroll(pool, user) * accCrssPerShare / 1e12 - user.rewardDebt;
    }

    function finishRewardCycle(
        PoolInfo storage pool, 
        UserInfo storage user, 
        address msgSender, 
        FarmFeeParams storage feeParams, 
        Nodes storage nodes, 
        uint256 totalAllocPoint, 
        uint256 crssPerBlock, 
        uint256 bonusMultiplier
    ) public {
        updatePool(pool, totalAllocPoint, crssPerBlock, bonusMultiplier, nodes);
        if (pool.reward > 0) {
            pyaReferralComission(pool, user, msgSender, feeParams, nodes);
            takePendingCollectively(pool, feeParams, nodes); // subPools' bulk and accPerShare.
            takeIndividualReward(pool, user);
            pool.reward = 0;
        }
    }

    function getUserState(
        address msgSender,
        uint256 pid,
        PoolInfo[] storage poolInfo,
        mapping(uint256 => mapping(address => UserInfo)) storage userInfo,
        Nodes storage nodes,
        uint256 totalAllocPoint,
        uint256 crssPerBlock,
        uint256 bonusMultiplier,
        uint256 vestMonths
    ) external view returns (UserState memory userState) {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msgSender];
        userState.collectOption = uint256(user.collectOption);
        userState.deposit = user.amount;
        userState.accRewards = user.accumulated;
        userState.totalVest = getTotalVestPrincipals(user.vestList);
        userState.totalMatureVest = getTotalMatureVestPieces(user.vestList, vestMonths);
        userState.pendingCrss = pendingCrss(pool, user, bonusMultiplier, crssPerBlock, totalAllocPoint);
        userState.rewardPayroll = getRewardPayroll(pool, user);
        userState.lpBalance = pool.lpToken.balanceOf(msgSender);
        userState.crssBalance = ICrssToken(nodes.token).balanceOf(msgSender);
        for(pid = 0; pid < poolInfo.length; pid++) {
            userState.totalAccRewards += userInfo[pid][msgSender].accumulated;
        }
    }

    function getSubPooledCrss(PoolInfo storage pool, UserInfo storage user) external view returns (SubPooledCrss memory spc) {

        if (user.collectOption == CollectOption.OnOff && user.amount > 0) {

        } else if (user.collectOption == CollectOption.OnOn && user.amount > 0) {
            spc.toVest = user.amount * pool.OnOn.Vest.accPerShare / 1e12 - user.debt2;

        } else if (user.collectOption == CollectOption.OffOn && user.amount > 0) {
            spc.toVest = user.amount * pool.OffOn.Vest.accPerShare / 1e12 - user.debt1;
            spc.toAccumulate = user.amount * pool.OffOn.Accum.accPerShare / 1e12 - user.debt2;

        } else if (user.collectOption == CollectOption.OffOff && user.amount > 0) {
            spc.toAccumulate = user.amount * pool.OffOff.Accum.accPerShare / 1e12 - user.debt1;
        }        
    }

    function payDepositFeeLPFromFarm(
        PoolInfo storage pool, 
        uint256 amount,
        FeeStores storage feeStores
    ) external returns (uint256 feePaid) {
        if (pool.depositFeeRate > 0) {
            feePaid = amount * pool.depositFeeRate / FeeMagnifier;
            uint256 treasury = feePaid / 2;
            pool.lpToken.safeTransfer(feeStores.treasury, treasury);
            pool.lpToken.safeTransfer(feeStores.develop, feePaid - treasury);
        }
    }

    function payDepositFeeCrssFromXCrss(
        PoolInfo storage pool,
        address xToken,
        uint256 amount,
        FeeStores storage feeStores
    ) external returns (uint256 feePaid) {
        if (pool.depositFeeRate > 0) {
            feePaid = amount * pool.depositFeeRate / FeeMagnifier;
            uint256 treasury = feePaid / 2;
            tolerableCrssTransferFromXTokenAccount(xToken, feeStores.treasury, treasury);
            tolerableCrssTransferFromXTokenAccount(xToken, feeStores.develop, feePaid - treasury);
        }
    }

    function dailyPatrol(
        PoolInfo[] storage poolInfo, 
        uint256 totalAllocPoint, 
        uint256 crssPerBlock, 
        uint256 bonusMultiplier,
        FarmFeeParams storage feeParams,
        Nodes storage nodes,
        uint256 lastPatrolDay
    ) external returns (uint256 newLastPatrolDay) {
        uint256 currDay = block.timestamp /  (120 seconds); //     (1 days); for test onlt.
        if (lastPatrolDay < currDay ) {
            console.log("\t************* Patrolling... every 60 seconds, for test");
            // do dailyPatrol
            for (uint256 pid; pid < poolInfo.length; pid ++) {
                PoolInfo storage pool = poolInfo[pid];
                updatePool(pool, totalAllocPoint, crssPerBlock, bonusMultiplier, nodes);
                takePendingCollectively(pool, feeParams, nodes);
            }
            console.log("\t*************");
            newLastPatrolDay = currDay;
        }
    }

    function pullFromUser(PoolInfo storage pool, address userAddr, uint256 amount) external returns (uint256 arrived) {
        uint256 oldBalance = pool.lpToken.balanceOf(address(this));
        pool.lpToken.safeTransferFrom(userAddr, address(this), amount);
        uint256 newBalance = pool.lpToken.balanceOf(address(this));
        arrived = newBalance - oldBalance;
    }

    function buildStandardPool(address lp, uint256 allocPoint, uint256 startBlock, uint256 depositFeeRate) 
    public view returns (PoolInfo memory pool) {
        pool = PoolInfo({
            lpToken: IERC20(lp),
            allocPoint: allocPoint,
            lastRewardBlock: (block.number > startBlock ? block.number : startBlock),
            accCrssPerShare: 0,
            depositFeeRate: depositFeeRate,
            reward: 0,

            OnOff: Struct_OnOff(0, SubPool(0, 0)),
            OnOn: Struct_OnOn(0, SubPool(0, 0), SubPool(0, 0)),
            OffOn: Struct_OffOn(0, SubPool(0, 0), SubPool(0, 0)),
            OffOff: Struct_OffOff(0, SubPool(0, 0))
        });
    }
}

//  1  function Dijkstra(Graph, source):
//  2
//  3      for each vertex v in Graph.Vertices:            
//  4          dist[v] ← INFINITY                 
//  5          prev[v] ← UNDEFINED                
//  6          add v to Q                     
//  7      dist[source] ← 0                       
//  8     
//  9      while Q is not empty:
// 10          u ← vertex in Q with min dist[u]   
// 11          remove u from Q
// 12                                        
// 13          for each neighbor v of u still in Q:
// 14              alt ← dist[u] + Graph.Edges(u, v)
// 15              if alt < dist[v]:              
// 16                  dist[v] ← alt
// 17                  prev[v] ← u
// 18
// 19      return dist[], prev[]


// 1  S ← empty sequence
// 2  u ← target
// 3  if prev[u] is defined or u = source:          // Do something only if the vertex is reachable
// 4      while u is defined:                       // Construct the shortest path with a stack S
// 5          insert u at the beginning of S        // Push the vertex onto the stack
// 6          u ← prev[u]                           // Traverse from target to source