// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

// Note this solution is mostly unworkable since solidiy has changed to way 
// arrays work, as we now use push and pop.  Code is for example only.

import "forge-std/Test.sol";
import "source/math/Mapping.sol";

contract MappingTest is Test {

  MappingChallenge mappingChallenge;

  address account1;
  address account2;

  function setUp() public {
    account1 = vm.addr(1);
    vm.label(account1, "Account1[address]");
    vm.deal(account1, 1 ether);

    mappingChallenge = new MappingChallenge();
    vm.label(address(mappingChallenge), "MappingChallenge[contract]");
    vm.startPrank(account1);
  }

  function testCorrectMappingInserts() public {
     mappingChallenge.set(100);
     mappingChallenge.set(101);
     mappingChallenge.set(102);
     mappingChallenge.set(103);
     mappingChallenge.set(104);

    uint256 expectedMapResult = 103;
    uint256 actualResult = mappingChallenge.get(3);
    assertEq(actualResult, expectedMapResult);

    console.log(expectedMapResult);
    console.log(actualResult);
  }

  
  function testAttackByOverflowing() public {
     // to attack this we need to overflow the storage slots as eventually it will rewrite the slot 
     // where isComplete is located.
     // the issue is that we cannot directly insert at an index using push - so would have to loop

     uint256 maxUintLen = type(uint256).max;
     for (uint longloop = 0; longloop < maxUintLen; longloop++) {  // takes too long as costs too much gas!
         mappingChallenge.set(1);                                  
     }

     // then overwrite 
     mappingChallenge.set(1);
     assertTrue(mappingChallenge.isComplete());

     console.log(maxUintLen);
     console.log(mappingChallenge.isComplete());
  }

  fallback() external payable { }
  receive() external payable { }
}

