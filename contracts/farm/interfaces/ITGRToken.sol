// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITGRToken is IERC20 {

    function maxSupply() external view returns (uint256);
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
    function bury(address from, uint256 amount) external;
    function maxTransferAmountRate() external view returns (uint256);
    function changeMaxTransferAmountRate(uint _maxTransferAmountRate) external;
    function tolerableTransfer(address from, address to, uint256 value) external returns (bool);
}

struct Pulse_LP_Reward {
    uint256 cycle;
    uint256 decayRate;
    address account;
    uint256 latestTime;
}

struct Pulse_Vote_Burn {
    uint256 cycle;
    uint256 decayRate;
    address account;
    uint256 latestTime;
}

struct Pulse_All_Burn {
    uint256 cycle;
    uint256 decayRate;
    uint256 latestTime;
    uint256 sum_balance;
    uint256 pending_burn;
    uint256 accBurnPerShare;
}

struct AccountInfo {
    uint256 burnDebt;
}