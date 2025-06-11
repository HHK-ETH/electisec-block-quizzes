// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.26;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract LendingProtocol {
    ERC20 public lendToken;
    ERC20 public collateralToken;

    mapping(address => uint256) public usersLend;
    mapping(address => uint256) public usersCollateral;
    mapping(address => uint256) public usersBorrow;

    uint256 public collateralPrice; //hardcoded for quiz simplicity
    address deployer;

    constructor(ERC20 lend, ERC20 collateral, uint256 colPrice) {
        deployer = msg.sender;
        lendToken = lend;
        collateralToken = collateral;
        collateralPrice = colPrice;
    }

    //lend

    function depositLend(uint256 amount) external {
        computeInterests();
        lendToken.transferFrom(msg.sender, address(this), amount);
        usersLend[msg.sender] += amount;
    }

    function withdrawLend(uint256 amount) external {
        computeInterests();
        lendToken.transfer(msg.sender, amount);
        usersLend[msg.sender] -= amount;
    }

    //collateral

    function depositCollateral(uint256 amount) external {
        computeInterests();
        collateralToken.transferFrom(msg.sender, address(this), amount);
        usersCollateral[msg.sender] += amount;
    }

    function withdrawCollateral(uint256 amount) external {
        computeInterests();
        collateralToken.transfer(msg.sender, amount);
        usersCollateral[msg.sender] -= amount;
        require(validHealthFactor(usersBorrow[msg.sender], usersCollateral[msg.sender]), "HF");
    }

    //borrow

    function borrow(uint256 amount) external {
        computeInterests();
        lendToken.transfer(msg.sender, amount);
        usersBorrow[msg.sender] += amount;
        require(validHealthFactor(usersBorrow[msg.sender], usersCollateral[msg.sender]), "HF");
    }

    function repay(uint256 amount) external {
        computeInterests();
        lendToken.transferFrom(msg.sender, address(this), amount);
        usersBorrow[msg.sender] -= amount;
        require(validHealthFactor(usersBorrow[msg.sender], usersCollateral[msg.sender]), "HF");
    }

    function liquidate(address user) external {
        computeInterests();
        require(!validHealthFactor(usersBorrow[user], usersCollateral[user]), "!HF");

        collateralToken.transfer(msg.sender, usersCollateral[user]);
        usersCollateral[user] = 0;

        lendToken.transferFrom(msg.sender, address(this), usersBorrow[user]);
        usersBorrow[user] = 0;
    }

    function validHealthFactor(uint256 borrowed, uint256 collateral) internal view returns (bool) {
        //health factor is handled here, for quiz simplicity we hardcode ltv to 95%
        uint256 borrowedUsd = borrowed * getPrice(lendToken);
        uint256 collateraldUsdWithLtv = collateral * getPrice(collateralToken) * 95 / 100;
        return borrowedUsd < collateraldUsdWithLtv;
    }

    //interests
    function computeInterests() public {
        //Interests are handled here, for quiz simplcity this is not implemented.
    }

    //oracle
    function getPrice(ERC20 token) public view returns (uint256) {
        //Oracle are handled here, for quiz simplicity we hardcode prices with 1e8 decimals
        if (token == lendToken) {
            return 1e8;
        } else if (token == collateralToken) {
            return collateralPrice;
        } else {
            revert();
        }
    }

    function setPrice(uint256 price) external {
        require(msg.sender == deployer, "!deployer");
        //Oracle are hendled here, for quiz simplicity we hardcode prices with 1e8 decimals
        //This price setter is here as helper only, here only to update market conditions while building pocs
        require(price > 1e8, "!price");
        collateralPrice = price;
    }
}
