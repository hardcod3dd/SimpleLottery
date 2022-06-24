// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

/**
 * @title Simple lottery contract from hardcod3d.eth
 */
 

contract Lottery{
    
    // set variables
    address payable[] public players; 
    address payable public owner; 
    // mapping so only one user can enter
    mapping(address => bool) public hasEntered;
    // can reset  ?
    bool public started;
    
    // set owner
    constructor(){
        owner = payable(msg.sender); 
    }
    // onlyowner modifier 
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // check if the addres entered the lottery
    modifier checkEntered {
        require(hasEntered[msg.sender] == false);
        _;
    }

    // receive to get eth.require value
        receive () payable external checkEntered {
        require(msg.value == 1 ether);
        require(started == true);
        require(msg.sender != owner);
        players.push(payable(msg.sender));
        hasEntered[msg.sender] = true;
    }
    
    // function to reset status
    function resetEntered() external {
        require(started == false);
        hasEntered[msg.sender] = false;
    }

    function startEntry() external onlyOwner{
        started = true;
    }

    // return balance
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
    
    // helper function that returns a big random integer not safe or random. should be using chainlnk
    function random() internal view returns(uint){
       return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }
    
    
    // selecting the winner.resetting variable and set started false
    function pickWinner() external {
        require(started == true);
        require (players.length >= 10);
        uint r = random();
        address payable winner;
        
        uint index = r % players.length;
    
        winner = players[index]; // this is the winner
        
        uint managerFee = (getBalance() * 10 ) / 100; // manager fee is 10%
        uint winnerPrize = (getBalance() * 90 ) / 100;     // winner prize is 90%

        // transferring the entire contract's balance to the winner
        owner.transfer(managerFee);
        winner.transfer(winnerPrize);
        
        // resetting the lottery for the next round
        players = new address payable[](0);
        started = false;
    }

}
