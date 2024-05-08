// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from 'forge-std/Test.sol';
import {FundMe} from '../../src/FundMe.sol';
import {DeployFundMe} from '../../script/DeployFundMe.s.sol';
import {FundFundMe, WithdrawFundMe} from '../../script/Interactions.s.sol';
import {StdCheats} from "forge-std/StdCheats.sol";

contract InteractionsTest is StdCheats, Test {
    FundMe public fundMe;

    address USER = makeAddr('user');
    // address public constant USER = address(1);
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant SEND_VALUE = 0.1 ether; // 100000000000000000
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        uint256 preUserBalance = address(USER).balance;
        uint256 preOwnerBalance = address(fundMe.getOwner()).balance;
        uint256 preFundMeBalance = address(fundMe).balance;
        console.log("InteractionsTest.t.sol - address(this):", address(this));
        console.log("InteractionsTest.t.sol - USER:", USER);
        console.log("InteractionsTest.t.sol - OWNER FUNDME:", fundMe.getOwner());
        console.log("InteractionsTest.t.sol - OWNER BALANCE:", preOwnerBalance);
        console.log('InteractionsTest.t.sol - fundMePreBalance   :', preFundMeBalance);
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));
        uint256 afterFundMeBalance = address(fundMe).balance;
        console.log('InteractionsTest.t.sol - fundMeAfterBalance :', afterFundMeBalance);
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));
        uint256 afterUserBalance = address(USER).balance;
        uint256 afterOwnerBalance = address(fundMe.getOwner()).balance;
        //uint256 afterWithdrawBalance = address(fundMe).balance;
        console.log('InteractionsTest.t.sol - SEND_VALUE          :', SEND_VALUE);
        console.log('InteractionsTest.t.sol - afterUserBalance    :', afterUserBalance);
        console.log('InteractionsTest.t.sol - afterOwnerBalance   :', afterOwnerBalance);
        console.log('InteractionsTest.t.sol - afterfundMeBalance  :', address(fundMe).balance);
        assert(address(fundMe).balance == 0);
        // assertEq(afterUserBalance + SEND_VALUE, preUserBalance);
        // assertEq(preOwnerBalance + SEND_VALUE, afterOwnerBalance);
    }
}