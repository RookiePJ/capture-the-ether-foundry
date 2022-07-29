#!/bin/bash

# simple shell script help generate new test contracts - replacing text is a base file (base.test.txt)
# rename (refactor) variable in existng test contracts to create new tests

# usage - for a contract called TokenSale.sol;
# ./generateTestContract.bash TokenSale tokenSale

set -x

contractName=$1 
instanceName=$2


testContractFilename=${contractName}.t.sol

# the new test contract from the base.test.txt
cp base.test.txt $testContractFilename

# now replace both the CONTRACT_NAME and INSTANCE_NAME
sed -i.bk -- "s/CONTRACT_NAME/${contractName}/g" ${testContractFilename}
sed -i.bk -- "s/INSTANCE_NAME/${instanceName}/g" ${testContractFilename}
rm *.bk

echo "New contract ${testContractFilename} has been created..."

forge test --mc ${contractName} -vvvv
