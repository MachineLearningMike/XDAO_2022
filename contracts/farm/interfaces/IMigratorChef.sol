// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IMigratorChef {
    // Perform LP token migration from legacy XDAOSwap to TGRSwap.
    // Take the current LP token address and return the new LP token address.
    // Migrator should have full access to the caller's LP token.
    // Return the new LP token address.
    //
    // XXX Migrator must have allowance access to XDAOSwap LP tokens.
    // TGRSwap must mint EXACTLY the same amount of TGRSwap LP tokens or
    // else something bad will happen. Traditional XDAOSwap does not
    // do that so be careful!
    function migrate(IERC20 token) external returns (IERC20);
}
