// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.26;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

import {LendingProtocol} from "./LendingProtocol.sol";

contract InsuranceFund {
    address owner;
    LendingProtocol immutable lending;

    address[] accounts;
    mapping(address => bool) accountsAdded;

    constructor(address _owner, address _lending) {
        owner = _owner;
        lending = LendingProtocol(_lending);
    }

    /// @notice deposit into insurance fund, anyone can deposit
    function deposit(uint256 amount) external {
        lending.lendToken().transferFrom(msg.sender, address(this), amount);
    }

    /// @notice withdraw from insurance fund, only owner
    function withdraw(uint256 amount) external {
        require(msg.sender == owner, "Not owner");
        lending.lendToken().transferFrom(msg.sender, address(this), amount);
    }

    //decentralized insurance

    /// @notice add an account in bad debt, limited to 10 accounts total, anyone can add
    function addBadDebtAccount(address account) external {
        require(!accountsAdded[account], "Already added");
        require(accounts.length < 10, "Too many accounts");
        require(lending.usersCollateral(account) == 0 && lending.usersBorrow(account) > 0, "Not in Bad debt");

        accounts.push(account);
        accountsAdded[account] = true;
    }

    /// @notice repay the accounts stored as soon as over 3 accounts in bad debt, only owner can execute reimbursments
    function reimburse() external {
        require(msg.sender == owner, "Not owner");
        require(accounts.length > 3, "Not enough accounts");

        for (uint256 i = 0; i < accounts.length; i++) {
            address account = accounts[i];
            delete accountsAdded[account];

            lending.repay(lending.usersBorrow(account));
        }

        delete accounts;
    }
}
