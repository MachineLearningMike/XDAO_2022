// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "../session/Node.sol";
import "../libraries/WireLib.sol";
import "./interfaces/IMaker.sol";
import "../session/SessionManager.sol";
import "../session/LiquidityControl.sol";
import "../libraries/utils/TransferHelper.sol";
import "../libraries/CyberSwapLib.sol";
import "../libraries/math/SafeMath.sol";
import "../core/interfaces/IXDAOFactory.sol";
import "./interfaces/IWETH.sol";

import "hardhat/console.sol";
interface IBalanceLedger {
    function balanceOf(address account) external view returns (uint256);
}

contract Maker is Node, IMaker, Ownable, SessionManager, LiquidityControl {
    using SafeMath for uint256;

    FeeStores public override feeStores;
    mapping(SessionType => FeeRates) public override feeRates;

    address public immutable override WETH;
    
    string private sForbidden = "Taker: Forbidden";
    string private sInvalidPath = "Taker: Invalid path";
    string private sInsufficientOutput = "Taker: Insufficient output amount";
    string private sInsufficientA = "Taker: Insufficient A amount";
    string private sInsufficientB = "Taker: Insufficient B amount";
    string private sExcessiveInput = "Taker: Excessive input amount";
    string private sExpired = "Taker: Expired";

    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, sExpired);
        _;
    }

    constructor(address _WETH) Ownable()  {
        WETH = _WETH;
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    function getOwner() public view override returns (address) {
        return owner();
    }

    modifier canChangeLiquidityChangeLimit override virtual {
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
        WireLib.setFeeStores(feeStores, _feeStores);
        emit SetFeeStores(_feeStores);
    }

    function setFeeRates(SessionType _sessionType, FeeRates memory _feeRates, address caller) public override virtual {
        if (caller != address(this)) {
            WireLib.setFeeRates(_sessionType, feeRates, _feeRates);
            emit SetFeeRates(_sessionType, _feeRates);
            super.setFeeRates(_sessionType, _feeRates, caller);
        }
    }


    function getReserveOnETHPair(address _token) external view override virtual returns (uint256 reserve) {
        (uint256 reserve0, uint256 reserve1) = CyberSwapLib.getReserves(nodes.factory, _token, WETH);
        (address token0, ) = CyberSwapLib.sortTokens(_token, WETH);
        reserve = token0 == _token? reserve0 : reserve1;
    }

    // **** ADD LIQUIDITY ****
    function _addLiquidity( // Get amounts to transfer to the pair fee of fees.
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin
    ) internal virtual returns (uint256 amountA, uint256 amountB) {

  if (IXDAOFactory(nodes.factory).getPair(tokenA, tokenB) == address(0)) {
            IXDAOFactory(nodes.factory).createPair(tokenA, tokenB);
        }
        (uint256 reserveA, uint256 reserveB) = CyberSwapLib.getReserves(nodes.factory, tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint256 amountBOptimal = CyberSwapLib.quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, sInsufficientB);
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint256 amountAOptimal = CyberSwapLib.quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, sInsufficientA);
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }

    require(amountA >= amountAMin, sInsufficientA);
        require(amountB >= amountBMin, sInsufficientB);
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        )
    {
        _openSession(SessionType.AddLiquidity);

        (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);

        address pair = CyberSwapLib.pairFor(nodes.factory, tokenA, tokenB);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        liquidity = IXDAOPair(pair).mint(address(this));

        if(tokenA == nodes.token || tokenB == nodes.token)
            liquidity -= _payTransactionFeeLP(pair, liquidity);
        TransferHelper.safeTransfer(pair, to, liquidity);

        _closeSession();
    }

    function _payTransactionFeeLP(address lp, uint256 principal) internal virtual returns (uint256 feesPaid) {
        if (sessionParams.isOriginAction) { 
            feesPaid = CyberSwapLib.payFeeLP(lp, principal, feeRates[sessionParams.sessionType], feeStores);
        }
    }

    function addLiquidityETH(
        address _token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        virtual
        override
        ensure(deadline)
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        )
    {
        _openSession(SessionType.AddLiquidity);

        address pair = CyberSwapLib.pairFor(nodes.factory, _token, WETH);

        (amountToken, amountETH) = _addLiquidity(
            _token,
            WETH,
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountETHMin
        );

        TransferHelper.safeTransferFrom(_token, msg.sender, pair, amountToken);
        IWETH(WETH).deposit{value: amountETH}();
        assert(IWETH(WETH).transfer(pair, amountETH));
        liquidity = IXDAOPair(pair).mint(address(this)); // all arrive.
        if(_token == nodes.token)
            liquidity -= _payTransactionFeeLP(pair, liquidity);
        TransferHelper.safeTransfer(pair, to, liquidity);

        // refund dust eth, if any
        if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);

        _closeSession();
    }

     // **** REMOVE LIQUIDITY ****
    function _removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to
    ) internal virtual returns (uint256 amountA, uint256 amountB) {
        address pair = CyberSwapLib.pairFor(nodes.factory, tokenA, tokenB);

        PairSnapshot memory pairSnapshot = PairSnapshot(pair, address(0), address(0), 0, 0, 0, 0);
        (pairSnapshot.reserve0, pairSnapshot.reserve1, ) = IXDAOPair(pair).getReserves();
        _capturePairStateAtSessionBirth(sessionParams.session, pairSnapshot); // Liquidity control

        if (IXDAOPair(pair).balanceOf(msg.sender) < liquidity) {
            liquidity = IXDAOPair(pair).balanceOf(msg.sender);
        }

        TransferHelper.safeTransferFrom(pair, msg.sender, address(this), liquidity);
        if(tokenA == nodes.token || tokenB == nodes.token)
            liquidity -= _payTransactionFeeLP(pair, liquidity);
        TransferHelper.safeTransfer(pair, pair, liquidity);
        (uint256 amount0, uint256 amount1) = IXDAOPair(pair).burn(to);

        (pairSnapshot.reserve0, pairSnapshot.reserve1, ) = IXDAOPair(pair).getReserves();
        if (msg.sender != owner())  _ruleOutInvalidLiquidity(pairSnapshot); // Liquidity control

        (pairSnapshot.token0, pairSnapshot.token1 ) = CyberSwapLib.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == pairSnapshot.token0 ? (amount0, amount1) : (amount1, amount0);

        require(amountA >= amountAMin, sInsufficientA);
        require(amountB >= amountBMin, sInsufficientB);
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) public override virtual ensure(deadline) returns (uint256 amountA, uint256 amountB) {
        _openSession(SessionType.RemoveLiquidity);

        (amountA, amountB) = _removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to);

        _closeSession();
    }

    function removeLiquidityETH(
        address _token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) public override virtual ensure(deadline) returns (uint256 amountToken, uint256 amountETH) {
        _openSession(SessionType.RemoveLiquidity);

        (amountToken, amountETH) = _removeLiquidity(
            _token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this)
        );
        TransferHelper.safeTransfer(_token, to, amountToken);
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);

        _closeSession();
    }

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override virtual returns (uint256 amountA, uint256 amountB) {
        address pair = CyberSwapLib.pairFor(nodes.factory, tokenA, tokenB);
        uint256 value = approveMax ? type(uint256).max : liquidity;
        IXDAOPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountA, amountB) = removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
    }

    function removeLiquidityETHWithPermit(
        address _token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override virtual returns (uint256 amountToken, uint256 amountETH) {
        address pair = CyberSwapLib.pairFor(nodes.factory, _token, WETH);
        uint256 value = approveMax ? type(uint256).max : liquidity;
        IXDAOPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountToken, amountETH) = removeLiquidityETH(_token, liquidity, amountTokenMin, amountETHMin, to, deadline);
    }

    // **** REMOVE LIQUIDITY (supporting fee-on-transfer tokens) ****

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address _token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) public override virtual ensure(deadline) returns (uint256 amountETH) {
        _openSession(SessionType.RemoveLiquidity);

        (, amountETH) = _removeLiquidity(_token, WETH, liquidity, amountTokenMin, amountETHMin, address(this));
        TransferHelper.safeTransfer(_token, to, IERC20(nodes.token).balanceOf(address(this)));
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);

        _closeSession();
    }

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address _token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override virtual returns (uint256 amountETH) {
        address pair = CyberSwapLib.pairFor(nodes.factory, _token, WETH);
        uint256 value = approveMax ? type(uint256).max : liquidity;
        IXDAOPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        amountETH = removeLiquidityETHSupportingFeeOnTransferTokens(
            _token,
            liquidity,
            amountTokenMin,
            amountETHMin,
            to,
            deadline
        );
    }

    // **** LIBRARY FUNCTIONS ****
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) public pure override virtual returns (uint256 amountB) {
        return CyberSwapLib.quote(amountA, reserveA, reserveB);
    }

    function getPair(address tokenA, address tokenB) external view override virtual returns (address pair) {
        return IXDAOFactory(nodes.factory).getPair(tokenA, tokenB);
    }
}
