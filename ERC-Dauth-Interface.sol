// Abstract contract for the ERC Dauth Access Delegation Standard
pragma solidity ^0.4.24;

contract ERCDauth {

    /* AuthInfo: User can add an AuthInfo to authorize third-party contract
     *  - invokes: methods which third-party contract can invoke
     *  - expireAt: the expire timestamp that the authority expires
     */
    struct AuthInfo {
        string[] invokes;
        uint expireAt;
    }

    // (user's address && grantee's address) -> AuthInfo
    mapping(address => mapping(address => AuthInfo)) userAuth;

    // all methods that can be authorized to the third-party contract
    string[] allowedInvokes;

    /// @notice check the invoke method authority for third-party contract
    /// @param _authorizer the user address that the third-party contract agents
    /// @param _invoke the invoke method that the third-party contract wants to access
    /// @return Whether the authority was valid or not
    function verify(address _authorizer, string _invoke) internal returns (bool success);

    /// @notice authorize a third-pary contract to access the user's resource
    /// @param _grantee the third-party contract address
    /// @param _invokes the invoke methods that the third-party contract can access
    /// @param _expireAt the authorization expire timestamp
    function grant(address _grantee, string _invokes, uint _expireAt) public returns (bool success);

    /// @notice alter a third-pary contract's authority
    /// @param _grantee the third-party contract address
    /// @param _invokes the invoke methods that the third-party contract can access
    /// @param _expireAt the authorization expire timestamp
    function regrant(address _grantee, string _invokes, uint _expireAt) public returns (bool success);

    /// @notice delete a third-pary contract's authority
    /// @param _grantee the third-party contract address
    function revoke(address _grantee) public returns (bool success);

    event Grant(address _authorizer, address _grantee, string _invokes, uint _expireAt);
    event Revoke(address _authorizer, address _grantee);
}
