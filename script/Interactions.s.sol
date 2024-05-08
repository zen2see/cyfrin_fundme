// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from 'forge-std/Script.sol';
import {DevOpsTools} from 'foundry-devops/src/DevOpsTools.sol';
import {Test} from 'forge-std/Test.sol';
import {console} from 'forge-std/console.sol';
import {FundMe} from '../src/FundMe.sol';

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log('Interactions.s.sol - address(this):', address(this));
        console.log('Interactions.s.sol - fundFundMe() Funded fundMe with  %s', SEND_VALUE);
        console.log('Interactions.s.sol - fundFundMe() mostRecentlyDeployed address:', mostRecentlyDeployed);
        console.log('Interactions.s.sol - fundFundMe() mostRecentlyDeployed address balance:', mostRecentlyDeployed.balance);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            'FundMe',
            block.chainid
        );
        fundFundMe(mostRecentlyDeployed);     
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
        console.log("Interactions.s.sol - withdrawFundMe() Withdraw FundMe balance!");
    }
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            'FundMe',
            block.chainid
        ); 
        withdrawFundMe(mostRecentlyDeployed);   
    }
}