// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.2;

interface IChronicle {
    function read() external view returns (uint256 value);
}

// https://github.com/chronicleprotocol/self-kisser/blob/main/src/ISelfKisser.sol
interface ISelfKisser {
    /// @notice Kisses caller on oracle `oracle`.
    function selfKiss(address oracle) external;
}

contract Convert {
    IChronicle public chronicle; // the price feed we will use
    ISelfKisser public selfKisser;
    address public owner;

    constructor() {
        /**
         * @notice The SelfKisser granting access to Chronicle oracles.
         * SelfKisser_1: 0xc0fe3a070Bc98b4a45d735A52a1AFDd134E0283f
         * Network: Arbitrum Sepolia
         */
        selfKisser = ISelfKisser(
            address(0xc0fe3a070Bc98b4a45d735A52a1AFDd134E0283f)
        );

        /**
         * Network: Arbitrum Sepolia
         * Aggregator: ARB/USD
         * Address: 0x91Fa05bCab98aD3DdEaE33DF7213EE8642e3c66c
         */
        chronicle = IChronicle(
            address(0x91Fa05bCab98aD3DdEaE33DF7213EE8642e3c66c)
        );
        selfKisser.selfKiss(address(chronicle));
        owner = msg.sender;
    }

    function _read() internal view returns (uint256 val) {
        val = chronicle.read();
    }

    function tokenAmount(uint256 amountWei) public view returns (uint256) {
        // Send amountETH, how many ARB I have
        uint256 arbUsd = _read(); // Price feed has 10**18 decimal places
        uint256 amountUSD = (amountWei * arbUsd) / 10 ** 18; // Price is 10**18
        uint256 amountArb = amountUSD / 10 ** 18; // Divide to convert from wei to ETH
        return amountArb;
    }
}
