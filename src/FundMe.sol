// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";
import {console} from 'forge-std/console.sol';

error FundMe__NotOwner();

/**
 * @title A sample Funding Contract
 * @author Patrick Collins
 * @notice This contract is for creating a sample funding contract
 * @dev This implements price feeds as our library
 */
contract FundMe {
    // Type Declarations
    using PriceConverter for uint256;

    // State variables
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18; // 5e18
    // Could we make this constant?  /* hint: no! We should make it immutable! */
    address private /* immutable */ i_owner;
    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;
    AggregatorV3Interface private s_priceFeed;

    // Events (we have none!)
    
    // Modifiers
    modifier onlyOwner() {
        // require(msg.sender == i_owner);
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }
    
    // Functions Order:
    //// constructor
    //// receive
    //// fallback
    //// external
    //// public
    //// internal
    //// private
    //// view / pure
    
    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    /// @notice Funds our contract based on the ETH/USD price
    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "You need to spend more ETH!");
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        console.log("FundMe.sol - FUND() MSG.VALUE:  ", msg.value, " FROM ", i_owner);
        console.log("FundMe.sol - FUND() msg.sender: ", msg.sender);
        console.log("FundMe.sol - FUND ADDRESS:      ", address(this));
        console.log("FundMe.sol - FUND BALANCE:      ", address(this).balance);
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }
    
    function withdraw() public onlyOwner {
        for (uint256 funderIndex=0; funderIndex < s_funders.length; funderIndex++){
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
            console.log("FundMe.sol - withdraw() funder    : ", funder);
            console.log("FundMe.sol - wiithdraw() funderindex:", funderIndex);
        }
        s_funders = new address[](0);
        // // transfer
        // payable(msg.sender).transfer(address(this).balance);
        
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        // call
        console.log("FundMe.sol - withdraw() before call addres(this).balance:", address(this).balance);
        (bool callSuccess, ) = i_owner.call{value: address(this).balance}("");
        require(callSuccess, "FundMe.sol - withdraw() Call failed");
        console.log("FundMe.sol - withdraw() after call addres(this).balance:", address(this).balance);
        console.log("FundMe.sol - withdraw() i_owner.balance:", i_owner.balance);
    }
    // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \ 
    //         yes  no
    //         /     \
    //    receive()?  fallback() 
    //     /   \ 
    //   yes   no
    //  /        \
    //receive()  fallback()

    function cheaperWithdraw() public onlyOwner {
        address[] memory funders = s_funders;
        // uint256 fundersLength = s_funders.length;
        // NOTE: mappings can't be in memory
        for (
            uint256 funderIndex = 0;
            // funderIndex < fundersLength;
            funderIndex < funders.length;
            funderIndex++
        ){
            // address funder = s_funders[funderIndex];
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        // (bool callSuccess, ) = payable(msg.sender).call{
        //     value: address(this).balance
        //  }("");
        (bool callSuccess,) = i_owner.call{value: address(this).balance}("");
        require(callSuccess, "FundMe.sol - cheaperWithdraw() Call failed");
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

    /**
     * View /Pure functions (Getters)
     */
    
    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getVersion() public view returns (uint256){
        return s_priceFeed.version();
    }

    function getFunder(uint256 index) external view returns(address){
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }

}

// Concepts we didn't cover yet (will cover in later sections)
// 1. Enum
// 2. Events
// 3. Try / Catch
// 4. Function Selector
// 5. abi.encode / decode
// 6. Hash with keccak256
// 7. Yul / Assembly