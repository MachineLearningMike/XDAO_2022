// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "../session/Node.sol";
import "../libraries/WireLibrary.sol";
import "./interfaces/ITaker.sol";
import "../session/SessionManager.sol";
import "../session/PriceControl.sol";
import "./ChainLinkControl.sol";
import "../libraries/utils/TransferHelper.sol";
import "../libraries/XDAOLibrary.sol";
import "../libraries/math/SafeMath.sol";
import "../core/interfaces/IXDAOFactory.sol";
import "./interfaces/IWETH.sol";

import "hardhat/console.sol";

interface IBalanceLedger {
    function balanceOf(address account) external view returns (uint256);
}

contract XDAOTaker is Node, ITaker, Ownable, SessionManager, PriceControl, ChainLinkControl {
    using SafeMath for uint256;

    FeeStores public override feeStores;
    mapping(SessionType => FeeRates) public override feeRates;

    address public immutable override WETH;

    string private sForbidden = "XDAOTaker: Forbidden";
    string private sInvalidPath = "XDAOTaker: Invalid path";
    string private sInsufficientOutput = "XDAOTaker: Insufficient output amount";
    string private sInsufficientA = "XDAOTaker: Insufficient A amount";
    string private sInsufficientB = "XDAOTaker: Insufficient B amount";
    string private sExcessiveInput = "XDAOTaker: Excessive input amount";
    string private sExpired = "XDAOTaker: Expired";

    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, sExpired);
        _;
    }

    constructor(address _WETH)  Ownable() {
        WETH = _WETH;
        _initializeBnbMainNetCLFeeds(); 
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    function getOwner() public view override returns (address) {
        return owner();
    }

    modifier canChangePriceChangeLimit override virtual {
        require(msg.sender == owner(), sForbidden);
        _;
    }

    function setNode(NodeType nodeType, address node, address caller) public override virtual {
        if (caller != address(this)) {
            if (nodeType == NodeType.Token) {
                sessionRegistrar = ISessionRegistrar(node);
                sessionFees = ISessionFees(node);
            }
            super.setNode(nodeType, node, caller);
        }
    }

    function setFeeStores(FeeStores memory _feeStores, address caller) public override virtual {
        super.setFeeStores(_feeStores, caller);
        WireLibrary.setFeeStores(feeStores, _feeStores);
        emit SetFeeStores(_feeStores);
    }

    function setFeeRates(SessionType _sessionType, FeeRates memory _feeRates, address caller) public override virtual {
        if (caller != address(this)) {
            WireLibrary.setFeeRates(_sessionType, feeRates, _feeRates);
            emit SetFeeRates(_sessionType, _feeRates);
            super.setFeeRates(_sessionType, _feeRates, caller);
        }
    }


    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    function _swap(
        uint256[] memory amounts,
        address[] memory path,
        address _to
    ) internal virtual {

        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);

            (PairSnapshot memory pairSnapshot, bool isNichePair) = _captureInitialPairState(input, output);
            IXDAOPair pair = IXDAOPair(pairSnapshot.pair);

            uint256 amountOut = amounts[i + 1];
            (uint256 amount0Out, uint256 amount1Out) = input == pairSnapshot.token0
                ? (uint256(0), amountOut)
                : (amountOut, uint256(0));
            address to = i < path.length - 2 ? XDAOLibrary.pairFor(nodes.factory, output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
            
            if(_msgSender() != owner()) _ruleOutInvalidPairState(isNichePair, pairSnapshot);
        }
    }

    function _captureInitialPairState(address input, address output) internal virtual returns (PairSnapshot memory pairSnapshot, bool isNichePair) {
        pairSnapshot.pair = XDAOLibrary.pairFor(nodes.factory, input, output);
        (pairSnapshot.token0, pairSnapshot.token1) = (IXDAOPair(pairSnapshot.pair).token0(), IXDAOPair(pairSnapshot.pair).token1());
        isNichePair = chainlinkFeeds[pairSnapshot.token0].proxy == address(0) || chainlinkFeeds[pairSnapshot.token1].proxy == address(0);
        if (isNichePair)  {
            (pairSnapshot.reserve0, pairSnapshot.reserve1, ) = IXDAOPair(pairSnapshot.pair).getReserves();
            _capturePairStateAtSessionBirth(sessionParams.session, pairSnapshot); // SAVE reserves if it'ssession-new pair. It's higly probable.
        } else {
            (pairSnapshot.decimal0, pairSnapshot.decimal1) = (IERC20Metadata(pairSnapshot.token0).decimals(), IERC20Metadata(pairSnapshot.token1).decimals());
        }
    }

    function _ruleOutInvalidPairState(bool isNichePair, PairSnapshot memory pairSnapshot) internal virtual {
        (pairSnapshot.reserve0, pairSnapshot.reserve1, ) = IXDAOPair(pairSnapshot.pair).getReserves();
        if (isNichePair) {
            _ruleOutInvalidPrice(pairSnapshot); // Compare current reserves to SAVED reserves
        } else {
            _ruleOutChainLinkInvalidPrice(pairSnapshot); // Compare current reserves to ChainLink. Use tokens and decimals.
        }
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external override virtual ensure(deadline) returns (uint256[] memory amounts) {
        _openSession(SessionType.Swap);

        amountIn -= _payPossibleSellFee(path[0], msg.sender, amountIn);

        amounts = XDAOLibrary.getAmountsOut(nodes.factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, sInsufficientOutput);

        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender, 
            XDAOLibrary.pairFor(nodes.factory, path[0], path[1]),
            amounts[0]
        );

        _swapWithPossibleBuyFee(amounts, path, feeRates[sessionParams.sessionType], to);

        _closeSession();
    }

    function _payPossibleSellFee(address firstPath, address payer, uint256 principal)
    internal virtual returns (uint256 feesPaid) {
        if (sessionParams.isOriginAction && firstPath == nodes.token) {
            feesPaid = _payFeeTGR(payer, principal, feeRates[sessionParams.sessionType], true); // we has not used up the allowance yet.
        }
    }

    function _swapWithPossibleBuyFee(uint256[] memory amounts, address[] calldata path, FeeRates memory rates, address to)
    internal virtual {
        if (sessionParams.isOriginAction && path[path.length-1] == nodes.token) {
            address detour = address(this);
            uint256 balance0 = IBalanceLedger(nodes.token).balanceOf(detour);
            _swap(amounts, path, detour);
            uint256 amountOut = IBalanceLedger(nodes.token).balanceOf(detour) - balance0; 
            amountOut -= _payFeeTGR(detour, amountOut, rates, false); // we have used up the allowance.
            if( detour != to) TransferHelper.safeTransferFrom(nodes.token, detour, to, amountOut);
        } else {
            _swap(amounts, path, to);
        }
    }

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external override virtual ensure(deadline) returns (uint256[] memory amounts) {
        _openSession(SessionType.Swap);

        amounts = XDAOLibrary.getAmountsIn(nodes.factory, amountOut, path);

        require(amounts[0] <= amountInMax, sExcessiveInput);
        _payPossibleSellFee(path[0], msg.sender, amounts[0]);

        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            XDAOLibrary.pairFor(nodes.factory, path[0], path[1]),
            amounts[0]
        );

        _swapWithPossibleBuyFee(amounts, path, feeRates[sessionParams.sessionType], to);

        _closeSession();
    }

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable override virtual ensure(deadline) returns (uint256[] memory amounts) {
        _openSession(SessionType.Swap);

        require(path[0] == WETH, sInvalidPath);       
        amounts = XDAOLibrary.getAmountsOut(nodes.factory, msg.value, path);
        require(amounts[amounts.length - 1] >= amountOutMin, sInsufficientOutput);
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(XDAOLibrary.pairFor(nodes.factory, path[0], path[1]), amounts[0]));

        _swapWithPossibleBuyFee(amounts, path, feeRates[sessionParams.sessionType], to);

        _closeSession();
    }

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external override virtual ensure(deadline) returns (uint256[] memory amounts) {
        _openSession(SessionType.Swap);

        require(path[path.length - 1] == WETH, sInvalidPath);
        amounts = XDAOLibrary.getAmountsIn(nodes.factory, amountOut, path);

        require(amounts[0] <= amountInMax, sExcessiveInput);
        _payPossibleSellFee(path[0], msg.sender, amounts[0]);

        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            XDAOLibrary.pairFor(nodes.factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);

        _closeSession();
    }

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external override virtual ensure(deadline) returns (uint256[] memory amounts) {
        _openSession(SessionType.Swap);

        amountIn -= _payPossibleSellFee(path[0], msg.sender, amountIn);
        require(path[path.length - 1] == WETH, sInvalidPath);
        amounts = XDAOLibrary.getAmountsOut(nodes.factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, sInsufficientOutput);

        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            XDAOLibrary.pairFor(nodes.factory, path[0], path[1]),
            amounts[0]
        );

        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);

        _closeSession();
    }

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable override virtual ensure(deadline) returns (uint256[] memory amounts) {
        _openSession(SessionType.Swap);

        require(path[0] == WETH, sInvalidPath);
        amounts = XDAOLibrary.getAmountsIn(nodes.factory, amountOut, path);

        require(amounts[0] <= msg.value, sExcessiveInput);
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(XDAOLibrary.pairFor(nodes.factory, path[0], path[1]), amounts[0]));

        _swapWithPossibleBuyFee(amounts, path, feeRates[sessionParams.sessionType], to);

        // refund dust eth, if any
        if (msg.value > amounts[0]) TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]);

        _closeSession();
    }

    // **** SWAP (supporting fee-on-transfer tokens) ****
    // requires the initial amount to have already been sent to the first pair
    function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual {

        for (uint256 i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);

            (PairSnapshot memory pairSnapshot, bool isNichePair) = _captureInitialPairState(input, output);
            IXDAOPair pair = IXDAOPair(pairSnapshot.pair);

            uint256 amountOutput;
            {
                uint256 amountInput;
                (uint256 reserveInput, uint256 reserveOutput) = input == pairSnapshot.token0
                    ? (pairSnapshot.reserve0, pairSnapshot.reserve1) : (pairSnapshot.reserve1, pairSnapshot.reserve0);
                amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
                amountOutput = XDAOLibrary.getAmountOut(amountInput, reserveInput, reserveOutput);
            }
            (uint256 amount0Out, uint256 amount1Out) = input == pairSnapshot.token0
                ? (uint256(0), amountOutput) : (amountOutput, uint256(0));
            address to = i < path.length - 2 ? XDAOLibrary.pairFor(nodes.factory, output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));

            if(_msgSender() != owner()) _ruleOutInvalidPairState(isNichePair, pairSnapshot);
        }
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external override virtual ensure(deadline) {
        _openSession(SessionType.Swap);

        amountIn -= _payPossibleSellFee(path[0], msg.sender, amountIn);

        TransferHelper.safeTransferFrom(path[0], msg.sender, XDAOLibrary.pairFor(nodes.factory, path[0], path[1]), amountIn);
        uint256 balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        
        _swapSupportingFeeOnTransferTokensWithPossibleBuyFee(path, feeRates[sessionParams.sessionType], to);

        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            sInsufficientOutput
        );

        _closeSession();
    }


    function _swapSupportingFeeOnTransferTokensWithPossibleBuyFee(address[] calldata path, FeeRates memory rates, address to)
    internal virtual {
        if (sessionParams.isOriginAction && path[path.length-1] == nodes.token) {
            address detour = address(this);
            uint256 balance0 = IBalanceLedger(nodes.token).balanceOf(detour);
            _swapSupportingFeeOnTransferTokens(path, detour);
            uint256 amountOut = IBalanceLedger(nodes.token).balanceOf(detour) - balance0;
            amountOut -= _payFeeTGR(detour, amountOut, rates, false); // we have used up the allowance.
            if( detour != to) TransferHelper.safeTransfer(nodes.token, to, amountOut);
        } else {
            _swapSupportingFeeOnTransferTokens(path, to);
        }
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable override virtual ensure(deadline) {
        _openSession(SessionType.Swap);

        require(path[0] == WETH, sInvalidPath);
        uint256 amountIn = msg.value;
        IWETH(WETH).deposit{value: amountIn}();
        assert(IWETH(WETH).transfer(XDAOLibrary.pairFor(nodes.factory, path[0], path[1]), amountIn));
        uint256 balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);

        _swapSupportingFeeOnTransferTokensWithPossibleBuyFee(path, feeRates[sessionParams.sessionType], to);

        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            sInsufficientOutput
        );

        _closeSession();
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external override virtual ensure(deadline) {
        _openSession(SessionType.Swap);

        require(path[path.length - 1] == WETH, sInvalidPath);

        amountIn -= _payPossibleSellFee(path[0], msg.sender, amountIn);

        TransferHelper.safeTransferFrom(path[0], msg.sender, XDAOLibrary.pairFor(nodes.factory, path[0], path[1]), amountIn);
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint256 amountOut = IERC20(WETH).balanceOf(address(this));
        require(amountOut >= amountOutMin, sInsufficientOutput);
        IWETH(WETH).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, amountOut);

        _closeSession();
    }

    // **** LIBRARY FUNCTIONS ****
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) public pure override virtual returns (uint256 amountB) {
        return XDAOLibrary.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure override virtual returns (uint256 amountOut) {
        return XDAOLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure override virtual returns (uint256 amountIn) {
        return XDAOLibrary.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(uint256 amountIn, address[] memory path)
        public
        view
        virtual
        override
        returns (uint256[] memory amounts)
    {
        return XDAOLibrary.getAmountsOut(nodes.factory, amountIn, path);
    }

    function getAmountsIn(uint256 amountOut, address[] memory path)
        public
        view
        virtual
        override
        returns (uint256[] memory amounts)
    {
        return XDAOLibrary.getAmountsIn(nodes.factory, amountOut, path);
    }


    function getReserveOnETHPair(address _token) external view override virtual returns (uint256 reserve) {
        (uint256 reserve0, uint256 reserve1) = XDAOLibrary.getReserves(nodes.factory, _token, WETH);
        (address token0, ) = XDAOLibrary.sortTokens(_token, WETH);
        reserve = token0 == _token? reserve0 : reserve1;
    }
}

