/*
Implements EIP20 token standard with Dauth
.*/

pragma solidity ^0.4.24;

import "./EIP20Interface.sol";
import "../ERC-Dauth-Interface.sol";

import "github.com/Arachnid/solidity-stringutils/strings.sol";


contract EIP20Dauth is EIP20Interface, ERCDauth {

    using strings for *;

    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show.
    string public symbol;                 //An identifier: eg SBX

    constructor(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
    ) public {
        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
        totalSupply = _initialAmount;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes

        allowedInvokes = ["transfer", "transferFrom", "approve"]; // Set allowed invoke methods
    }

    function verify(address _authorizer, string _invoke) internal returns (bool success) {
        require(userAuth[_authorizer][msg.sender].invokes.length > 0, "Unauthorized");

        if (now < userAuth[_authorizer][msg.sender].expireAt) {
            for (uint i = 0; i < userAuth[_authorizer][msg.sender].invokes.length; i++) {
                if (userAuth[_authorizer][msg.sender].invokes[i].toSlice().equals(_invoke.toSlice())) {
                    return true;
                }
            }
        }

        revert("Unauthorized");
    }

    function grant(address _grantee, string _invokes, uint _expireAt) public returns (bool success) {
        require(now < _expireAt, "Invalid expire timestamp");

        var invokesSlice = _invokes.toSlice();
        var delim = " ".toSlice();
        var invokeParts = new string[](invokesSlice.count(delim) + 1);

        for(uint i = 0; i < invokeParts.length; i++) {
            invokeParts[i] = invokesSlice.split(delim).toString();

            bool isAllowedInvoke = false;
            for (uint j = 0; j < allowedInvokes.length; j++) {
                if (allowedInvokes[j].toSlice().equals(invokeParts[i].toSlice())) {
                    isAllowedInvoke = true;
                    break;
                }
            }
            require(isAllowedInvoke, "Invalid invoke method");
        }

        require(invokeParts.length > 0, "Invalid invoke methods");

        userAuth[msg.sender][_grantee] = AuthInfo(invokeParts, _expireAt);

        emit Grant(msg.sender, _grantee, _invokes, _expireAt);

        return true;
    }

    function regrant(address _grantee, string _invokes, uint _expireAt) public returns (bool success) {
        return grant(_grantee, _invokes, _expireAt);
    }

    function revoke(address _grantee) public returns (bool success) {
        require(userAuth[msg.sender][_grantee].invokes.length > 0, "Invalid grantee");

        delete userAuth[msg.sender][_grantee];

        emit Revoke(msg.sender, _grantee);

        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        return _transfer(msg.sender, _to, _value);
    }

    function transfer(address _to, uint256 _value, address _authorizer) public returns (bool success) {
        verify(_authorizer, "transfer");

        return _transfer(_authorizer, _to, _value);
    }

    function _transfer(address sender, address _to, uint256 _value) internal returns (bool success) {
        require(balances[sender] >= _value);
        balances[sender] -= _value;
        balances[_to] += _value;
        emit Transfer(sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        return _transferFrom(msg.sender, _from, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value, address _authorizer) public returns (bool success) {
        verify(_authorizer, "transferFrom");

        return _transferFrom(_authorizer, _from, _to, _value);
    }

    function _transferFrom(address sender, address _from, address _to, uint256 _value) internal returns (bool success) {
        uint256 allowance = allowed[_from][sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][sender] -= _value;
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        return _approve(msg.sender, _spender, _value);
    }

    function approve(address _spender, uint256 _value, address _authorizer) public returns (bool success) {
        verify(_authorizer, "approve");

        return _approve(_authorizer, _spender, _value);
    }

    function _approve(address sender, address _spender, uint256 _value) internal returns (bool success) {
        allowed[sender][_spender] = _value;
        emit Approval(sender, _spender, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}
