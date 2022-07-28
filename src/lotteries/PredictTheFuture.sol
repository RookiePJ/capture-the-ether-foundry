pragma solidity ^0.8.13;

contract PredictTheFutureChallenge {
    address guesser;
    uint8 guess;
    uint256 settlementBlockNumber;

     constructor() payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function lockInGuess(uint8 n) public payable {
        require(guesser == address(0));
        require(msg.value == 1 ether);

        guesser = msg.sender;
        guess = n;
        settlementBlockNumber = block.number + 1;
    }

    function settle() public {
        require(msg.sender == guesser);
        require(block.number > settlementBlockNumber);

        //uint8 answer = uint8(keccak256(block.blockhash(block.number - 1), now)) % 10;
         uint answer = uint8(
            uint256(
              keccak256(abi.encodePacked( blockhash(block.number - 1), block.timestamp))
            )
          ) %10;

        guesser = address(0);
        if (guess == answer) {
             address payable toSendTo = payable(msg.sender);
             toSendTo.transfer(2 ether);
        }
    }
}
