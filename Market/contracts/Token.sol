// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20{
    address public owner;
    address public marketplace;

    // Initial supply of 80.000.000
    uint public pendingMint = 8 * 10 ** 7;

    mapping(address => uint) private blockedTokens;

    // ************* MODIFIERS ********************

    modifier onlyOwner() { require(msg.sender == owner, "Isn't the owner"); _; }

    // ************ CORE FUNCTIONS ****************

    constructor() ERC20("MyMarket Token", "MMT") {
        owner = msg.sender;
    }

    function setMarketplaceContract(address _marketplace) public onlyOwner returns(bool) {
        marketplace = _marketplace;
        return true;
    }

    /** Mint the pending tokens for rewards to the juries.
     *  When is executing the pending amount return to zero.
     */
    function mint() public onlyOwner {
        _mint(owner, pendingMint);   
        pendingMint = 0;     
    }

    /** Bloking of tokens to can be a jury member.
     */
    function blockTokens(uint _amount) public returns(bool) {
        require(balanceOf(msg.sender) >= _amount, "Insufficient fonds");

        // Make de transfer and the change of balances
        transferFrom(msg.sender, owner, _amount);
        blockedTokens[msg.sender] = _amount;

        return true;
    }

    /** Do withdraw of blocked tokens.
     *  If the new balance is bellow for minimal requiere to be jury member, this possition is lose.
     */
    function withdrawTokens(uint _amount) public returns(uint) {
        require(blockedTokens[msg.sender] >= _amount, "Insufficient fonds");
        
        transferFrom(owner, msg.sender, _amount);
        blockedTokens[msg.sender] -= _amount;

        return blockedTokens[msg.sender];
    }

    /** Update the address with permission to mint the pending tokens.
     *  Only executable by the actual owner.
     */
    function updateMinter(address _newMinter) public onlyOwner returns(bool) {
        owner = _newMinter;
        return true;
    }

}