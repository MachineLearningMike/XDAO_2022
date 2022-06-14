// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITGRToken is IERC20 {

    struct Pulse {
        uint256 latestTime;
        uint256 cycle;
        uint256 decayRate;
        address account;
        uint256 accDecayPerShare;
        uint256 sum_balances;
        uint256 pending_burn;
        uint256 latestRound;
    }
    struct User {
        uint256 debtToPendingBurn;        
    }

    function maxSupply() external view returns (uint256);
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
    function bury(address from, uint256 amount) external;
}

