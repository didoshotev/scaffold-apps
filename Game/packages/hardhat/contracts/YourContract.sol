pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";

// import "@openzeppelin/contracts/access/Ownable.sol";
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract YourContract {
    address public owner;
    uint256 public price = 0.025 ether;
    address public beneficiary = 0xb1133778bfdF62d9C042Db0cFDf61c69d642c53b;

    event DiceRoll(address indexed sender, uint256 rollValue, uint256 payout);

    constructor() {
        owner = 0xb1133778bfdF62d9C042Db0cFDf61c69d642c53b;
    }

    function diceRoll() public payable {
        require(msg.value == price, "Incorrect amount given");
        bytes32 predictableRandom = keccak256(
            abi.encodePacked(block.difficulty, msg.sender, address(this))
        );
        uint8 roll = uint8(predictableRandom[0]) % 6;
        uint256 payout = 0;
        console.log("Current roll: ", roll);

        if (roll == 5) {
            // you get 90% of the pot
            payout = (address(this).balance * 90) / 100; 
            (bool sent, ) = msg.sender.call{
                value: payout
            }("");
        } else if (roll >= 4) {
            // you get x2 of the price
            payout = price; 
            (bool sent, ) = msg.sender.call{value: price}("");
            require(sent, "Failed to send Ether!");
            (bool sent2, ) = msg.sender.call{value: price}("");
            if(sent2) { 
                payout += price;
            }
        } else {
            // you lose (money goes to the contract)
            (bool send, ) = beneficiary.call{value: 0.005 ether}("");
        }
        emit DiceRoll(msg.sender, roll, payout);
    }

    // to support receiving ETH by default
    receive() external payable {}

    fallback() external payable {}
}
