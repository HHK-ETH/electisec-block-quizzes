// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.26;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract Vault {
    address public owner;
    mapping(address => bool) public allowedStrategies;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function deposit(address token, uint256 amount) external onlyOwner {
        SafeERC20.safeTransferFrom(ERC20(token), msg.sender, address(this), amount);
    }

    function withdraw(address token, uint256 amount) external onlyOwner {
        SafeERC20.safeTransfer(ERC20(token), msg.sender, amount);
    }

    function transferToStrategy(address token, uint256 amount) external {
        require(allowedStrategies[msg.sender] == true, "Not a strategy");
        SafeERC20.safeTransfer(ERC20(token), msg.sender, amount);
    }

    function addStrategy(address strategy) external onlyOwner {
        require(allowedStrategies[strategy] == false, "Already added");
        allowedStrategies[strategy] = true;
    }

    function removeStrategy(address strategy) external onlyOwner {
        require(allowedStrategies[strategy] == true, "Already removed");
        allowedStrategies[strategy] = false;
    }
}
