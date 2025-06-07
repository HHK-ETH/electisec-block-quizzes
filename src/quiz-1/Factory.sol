// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.26;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

import {Vault} from "./Vault.sol";

contract Factory {
    function createVault() external returns (Vault) {
        return new Vault(msg.sender);
    }

    function createVaultAndDeposit(address token, uint256 amount) external returns (Vault) {
        Vault newVault = new Vault(msg.sender);
        SafeERC20.safeTransferFrom(ERC20(token), msg.sender, address(newVault), amount);
        return newVault;
    }
}
