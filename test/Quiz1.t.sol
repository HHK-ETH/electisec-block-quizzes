// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.26;

import "forge-std/Test.sol";

import "../../src/quiz-1/Factory.sol";
import "../../src/quiz-1/Univ2Strategy.sol";
import "../../src/quiz-1/Vault.sol";

contract Quiz1 is Test {
    address deployer;
    address alice;
    address attacker;

    Factory vaultFactory;
    Univ2Strategy uniV2Strategy;
    Vault aliceVault;

    IUniV2 univ2Router;
    ERC20 wbtc;
    ERC20 weth;
    address lp;

    function setUp() external {
        weth = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        wbtc = ERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
        univ2Router = IUniV2(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        lp = 0xBb2b8038a1640196FbE3e38816F3e67Cba72D940;

        vm.createSelectFork(getChain(1).rpcUrl, 22660569);

        alice = makeAddr("alice");
        attacker = makeAddr("attacker");
        deployer = makeAddr("deployer");

        vm.startPrank(deployer);
        vaultFactory = new Factory();
        uniV2Strategy = new Univ2Strategy(address(univ2Router), address(wbtc), address(weth), lp);
        vm.stopPrank();

        vm.startPrank(alice);
        aliceVault = vaultFactory.createVault();
        aliceVault.addStrategy(address(uniV2Strategy));
        weth.approve(address(uniV2Strategy), type(uint256).max);
        wbtc.approve(address(uniV2Strategy), type(uint256).max);
        vm.stopPrank();

        deal(address(weth), alice, 100 ether);
        deal(address(wbtc), alice, 100e8);

        deal(address(weth), attacker, 100);
        deal(address(wbtc), attacker, 100);
    }

    function test_solve() external {
        vm.startPrank(attacker);

        // -----------------------
        // Write your exploit here

        // -----------------------

        assertEq(weth.balanceOf(alice), 0, "!weth");
        assertEq(wbtc.balanceOf(alice), 0, "!wbtc");
    }
}
