// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.26;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract LendingProtocol {
    ERC20 public lendToken;
    ERC20 public collateralToken;

    mapping(address => uint256) public usersLend;
    mapping(address => uint256) public usersCollateral;
    mapping(address => uint256) public usersBorrow;

    //lend

    function depositLend(uint256 amount) external virtual {}
    function withdrawLend(uint256 amount) external virtual {}

    //collateral

    function depositCollateral(uint256 amount) external virtual {}

    function withdrawCollateral(uint256 amount) external virtual {}

    //borrow

    function borrow(uint256 amount) external virtual {}
    function repay(uint256 amount) external virtual {}

    function liquidate() external virtual {}
}
