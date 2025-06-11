// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.26;

import "forge-std/Test.sol";

import "../../src/quiz-2/InsuranceFund.sol";
import "../../src/quiz-2/LendingProtocol.sol";

contract Quiz2 is Test {
    address deployer;
    address alice;
    address attacker;

    InsuranceFund insurance;
    LendingProtocol lending;

    ERC20 dai;
    ERC20 weth;

    function setUp() external {
        weth = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        dai = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

        vm.createSelectFork(getChain(1).rpcUrl, 22660569);

        alice = makeAddr("alice");
        attacker = makeAddr("attacker");
        deployer = makeAddr("deployer");

        vm.startPrank(deployer);
        lending = new LendingProtocol(dai, weth, 2500e18);
        insurance = new InsuranceFund(deployer, address(lending));
        vm.stopPrank();

        //attacker has 10 ether and 500 dai
        deal(address(weth), attacker, 10 ether);
        deal(address(dai), attacker, 500 ether);

        deal(address(dai), address(insurance), 10_000 ether); //insurance fund has 10k dai
        deal(address(dai), alice, 10_000 ether); //alice has 10k dai

        //alice is lending 10k dai
        vm.startPrank(alice);
        dai.approve(address(lending), 10_000 ether);
        lending.depositLend(10_000 ether); //lending gets 10k dai from alice
        vm.stopPrank();

        //attacker has a small bad debt position
        vm.startPrank(attacker);
        weth.approve(address(lending), 1 ether);
        lending.depositCollateral(1 ether);
        lending.borrow(2000 ether);
        vm.stopPrank();

        //price go down which creates the bad debt
        vm.prank(deployer);
        lending.setPrice(1500e8);

        //atacker liquidates himself and add himself to insurance fund
        vm.startPrank(attacker);
        dai.approve(address(lending), 1500 ether * 98 / 100);
        lending.liquidate(attacker);
        insurance.addBadDebtAccount(attacker);
        vm.stopPrank();
    }

    function test_solve() external {
        vm.startPrank(attacker);

        // -----------------------
        // Write your exploit here

        // -----------------------

        vm.stopPrank();

        vm.prank(deployer);
        insurance.reimburse();

        assertEq(dai.balanceOf(address(insurance)), 0, "!dai");
    }
}
