// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Convert} from "./Convert.sol";

contract Fundraiser {
    using Convert for uint256;
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    address public immutable i_owner;
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;

    constructor() {
        i_owner = msg.sender;
    }

    function donate(uint256 _amount) public payable {
        require(
            msg.value.getAmount() >= MINIMUM_USD,
            "You need to spend more ETH!"
        );
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == i_owner);
        _;
    }

    function withdraw() external onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "Transfer failed.");
    }
    fallback() external payable {
        donate();
    }

    receive() external payable {
        donate();
    }
}
