// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

/**
 * @title Simple lottery contract from hardcod3d.eth
 */
 

contract Lottery{
    
    // set variables
    address payable[] public players; 
    address public owner; 
    // mapping so only one user can enter
    mapping(address => bool) public hasEntered;
    // can reset  ?
    bool public started;
    
    // set owner
    constructor(){
 
        owner = msg.sender; 
    }
    
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
    
    // helper function that returns a big random integer
    function random() internal view returns(uint){
       return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }
    
    
    // selecting the winner.resetting variable and set started false
    function pickWinner() external onlyOwner {
        require(started == true);
        require (players.length >= 3);
        uint r = random();
        address payable winner;
        
        uint index = r % players.length;
    
        winner = players[index]; // this is the winner
        
        // transferring the entire contract's balance to the winner
        winner.transfer(getBalance());
        
        // resetting the lottery for the next round
        players = new address payable[](0);
        started = false;
    }

}
