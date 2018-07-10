/*
    Implements EIP20DAuth Client to invoke EIP20DAuth contract.
*/
pragma solidity ^0.4.24;

import "./EIP20DAuth.sol";


contract Client {

    address private owner;
    EIP20DAuth private eip20DAuth;

    constructor() public {
        owner = msg.sender;     // Default Owner: Contract Deployer
    }

    /* Modifiers:
        Authorization Call Handler MUST be invoked only by owner.
    */
    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }
    function setOwner (address _owner) onlyOwner() public {
        owner = _owner;
    }

    function setEip20DAuth(address _dauthAddress) onlyOwner() public {
        eip20DAuth = EIP20DAuth(_dauthAddress);
    }

    // Delegate the _from user to transfer tokens
    function transferFromAgent(address _from, address _to, uint256 _value) onlyOwner() public returns (bool success) {
        return eip20DAuth.transfer(_to, _value, _from);
    }

    // Delegate the _from user to approve tokens
    function approveAgent(address _authorizer, address _spender, uint256 _value) onlyOwner() public returns (bool success) {
        return eip20DAuth.approve(_spender, _value, _authorizer);
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return eip20DAuth.balanceOf(_owner);
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return eip20DAuth.allowance(_owner, _spender);
    }
}
