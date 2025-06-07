// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.26;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

import {Vault} from "./Vault.sol";

interface IUniV2 {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);
}

contract Univ2Strategy {
    IUniV2 public immutable univ2;
    ERC20 public immutable yacToken;
    ERC20 public immutable weth;
    ERC20 public immutable lpToken;

    constructor(address _univ2, address _yacToken, address _weth, address _lpToken) {
        univ2 = IUniV2(_univ2);
        yacToken = ERC20(_yacToken);
        weth = ERC20(_weth);
        lpToken = ERC20(_lpToken);
    }

    /// @notice Transfer LPs from vault and remove liquidity
    function removeLiquidity(Vault vault, uint256 liquidity, uint256 yacMinOut, uint256 wethMinOut) external {
        require(vault.allowedStrategies(address(this)) == true, "NOT ALLOWED");
        require(msg.sender == vault.owner(), "NOT VAULT OWNER");

        vault.transferToStrategy(address(lpToken), liquidity);
        SafeERC20.safeIncreaseAllowance(lpToken, address(univ2), liquidity);

        //shouldn't use block.timestamp but it'll do for now
        univ2.removeLiquidity(
            address(yacToken), address(weth), liquidity, yacMinOut, wethMinOut, vault.owner(), block.timestamp
        );
    }

    /// @notice Transfer tokens from vault and add liquidity
    function addLiquidityFromVault(
        Vault vault,
        uint256 yacAmount,
        uint256 wethAmount,
        uint256 yacMinOut,
        uint256 wethMinOut
    ) external {
        require(vault.allowedStrategies(address(this)) == true, "NOT ALLOWED");
        require(msg.sender == vault.owner(), "NOT VAULT OWNER");

        vault.transferToStrategy(address(yacToken), yacAmount);
        vault.transferToStrategy(address(weth), wethAmount);

        _addLiquidity(vault, yacAmount, wethAmount, yacMinOut, wethMinOut);
    }

    /// @notice Transfer tokens from owner and add liquidity
    function addLiquidityFromOwner(
        Vault vault,
        uint256 yacAmount,
        uint256 wethAmount,
        uint256 yacMinOut,
        uint256 wethMinOut
    ) external {
        require(vault.allowedStrategies(address(this)) == true, "NOT ALLOWED");
        require(msg.sender == vault.owner(), "NOT VAULT OWNER");

        SafeERC20.safeTransferFrom(yacToken, vault.owner(), address(this), yacAmount);
        SafeERC20.safeTransferFrom(weth, vault.owner(), address(this), wethAmount);

        _addLiquidity(vault, yacAmount, wethAmount, yacMinOut, wethMinOut);
    }

    /// @notice internal function to add liquidity to the vault
    function _addLiquidity(Vault vault, uint256 yacAmount, uint256 wethAmount, uint256 yacMinOut, uint256 wethMinOut)
        internal
    {
        SafeERC20.safeIncreaseAllowance(yacToken, address(univ2), yacAmount);
        SafeERC20.safeIncreaseAllowance(weth, address(univ2), wethAmount);

        //shouldn't use block.timestamp but it'll do for now
        univ2.addLiquidity(
            address(yacToken),
            address(weth),
            yacAmount,
            wethAmount,
            yacMinOut,
            wethMinOut,
            address(vault),
            block.timestamp
        );
    }
}
