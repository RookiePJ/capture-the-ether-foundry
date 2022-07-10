// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "source/warmUp/CallMe.sol";

contract CallMeTest is Test {

  CallMeChallenge callMeChallenge;
  address account1 = vm.addr(1);

  function setUp() public {
    callMeChallenge = new CallMeChallenge();
    vm.label( address(callMeChallenge), "CallMeChallenge");
    vm.label( account1, "Account 1");
  }

  function testCallMe() public {
    bool beforeResult;
    bool afterResult;

    vm.startPrank(address(account1));

    beforeResult = callMeChallenge.isComplete();  // test the inital state - should be false
    assertEq(beforeResult, false);

    callMeChallenge.callme();

    afterResult = callMeChallenge.isComplete();  // test the state after - should be true
    assertEq(afterResult, true);
  }

}

