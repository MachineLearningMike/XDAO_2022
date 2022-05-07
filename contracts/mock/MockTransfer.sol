// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../farm/interfaces/ITGRToken.sol";
import "../farm/interfaces/IXDAOFarm.sol";
import "hardhat/console.sol";

contract MockTransfer is Ownable {
    ITGRToken private _crssToken;

    constructor(ITGRToken _token) {
        _crssToken = _token;
    }
    receive() external payable {}

    function transferTo(address _to, uint256 _amount) external {
        _crssToken.transfer(_to, _amount);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) external {
        _crssToken.transferFrom(_from, _to, _amount);
    }

    function transferXDAO(
        address _userA,
        address _userB,
        address _userC,
        uint256 _amountB,
        uint256 _amountC
    ) external {
        // transfer tokens from userA to userB
        _crssToken.transferFrom(_userA, _userB, _amountB);

        // transfer tokens from userA to userC
        _crssToken.transferFrom(_userA, _userC, _amountC);
    }

    fallback() external payable {
    }

    function withdrawVest(
        IXDAOFarm _farm,
        uint256 _pid,
        uint256 _amount
    ) external {
        _farm.withdrawVest(_pid, _amount);
    }
}
