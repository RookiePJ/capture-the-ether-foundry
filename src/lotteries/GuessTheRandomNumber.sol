// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract GuessTheRandomNumberChallenge {
    uint8 answer;

    //function GuessTheRandomNumberChallenge() public payable {
     constructor() payable {
        require(msg.value == 1 ether);

        answer = uint8(
          uint256(  
            keccak256(abi.encodePacked(
              blockhash(block.number - 1), block.timestamp) 
            )
          )
        );
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function guess(uint8 n) public payable {
        require(msg.value == 1 ether);

        if (n == answer) {
             address payable toSendTo = payable(msg.sender);
             toSendTo.transfer(2 ether);
            //msg.sender.transfer(2 ether);
        }
    }
}
