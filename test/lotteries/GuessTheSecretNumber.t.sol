// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "source/lotteries/GuessTheSecretNumber.sol";

contract GuessTheSecretNumberTest is Test {

  GuessTheSecretNumberChallenge guessTheSecretNumberChallenge;

  address account1;
  address account2;
  uint8   answer;

  function setUp() public {
    account1 = vm.addr(1);
    vm.label(account1, "Account1[address]");
    vm.deal(account1, 10 ether);

    guessTheSecretNumberChallenge = new GuessTheSecretNumberChallenge{value: 1 ether}();
    vm.label(address(guessTheSecretNumberChallenge), "GuessTheSecretNumberChallenge[contract]");
    vm.startPrank(account1);
    answer = crackHash();
  }

  function testIncorrectGuess() public {
    // incorrect guess, costs 1 ether each
    guessTheSecretNumberChallenge.guess{value: 1 ether}(1);
    guessTheSecretNumberChallenge.guess{value: 1 ether}(43);

    uint expectedAccountBalance = 8 * (1 ether);
    assertEq((account1.balance), expectedAccountBalance );
    uint expectedContractBalance = 3 * (1 ether);
    assertEq(address(guessTheSecretNumberChallenge).balance, expectedContractBalance );

    console.log(account1.balance);
    console.log(address(guessTheSecretNumberChallenge).balance);
  }

  /*
  Going to have to front run and brute force this..
  -- an uint8, so an 8 bit integer gives 2^8 or 256 possible numbers.
  -- at 1 ether per guess it would work out very expensive, so best to front run to get the answer.
  -- we have the hash value from the source code, so can run the hash function in a loop until we find match
  -- then we can simply call the guess with the correct input
  */

  // this is the same as the code in the contract, we just loop until we match
  function crackHash() public pure returns (uint8 hashInput) {
    bytes32 answerHash = 0xdb81b4d58595fbbbb592d3661a34cdca14d7ab379441400cbfa1b78bc447c365;
    for (uint8 i = 0; i < 256; i++) {
      if (keccak256(abi.encodePacked(i)) == answerHash) { return i; }
    }
  }

  function testCorrectGuess() public {
    console.log(answer);

    // correct guess, costs 1 ether, returns 2
    guessTheSecretNumberChallenge.guess{value: 1 ether}(answer);

    uint expectedAccountBalance = 11 * (1 ether);
    assertEq((account1.balance), expectedAccountBalance );
    uint expectedContractBalance = 0;
    assertEq(address(guessTheSecretNumberChallenge).balance, expectedContractBalance );

    console.log(account1.balance);
    console.log(address(guessTheSecretNumberChallenge).balance);
  }

  function testIsComplete() public {
    console.log(answer);

    guessTheSecretNumberChallenge.guess{value: 1 ether}(answer);
    assertTrue(guessTheSecretNumberChallenge.isComplete());

    console.log(account1.balance);
    console.log(address(guessTheSecretNumberChallenge).balance);
  }

  fallback() external payable { }
  receive() external payable { }
}

