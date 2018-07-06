// Abstract contract for the ERC Dauth Access Delegation Standard
pragma solidity ^0.4.24;

contract ERCDauth {

    /* AuthInfo: User can add an AuthInfo to authorize third-party contract
     *  - grantee: third-party contract's address
     *  - invokes: methods which third-party contract can invoke
     *  - expireTimestamp: the expireTimestamp that the authority expires
     *  - startTimestamp: the authority start timestamp
     */
    struct AuthInfo {
        address grantee;
        string[] invokes;
        uint expireTimestamp;
        uint startTimestamp;
    }

    // user's address -> an array of AuthInfo
    mapping (address=>AuthInfo[]) userAuth;

    // all methods that can be authorized to the third-party contract
    string[] allowedInvokes;

    /// @notice check the invoke method authority for third-party contract
    /// @param _user the user address that the third-party contract agents
    /// @param _invoke the invoke method that the third-party contract wants to access
    /// @return Whether the authority was valid or not
    function checkAuth(address _user, string _invoke) internal returns (bool success);

    /// @notice authorize a third-pary contract to access the user's resource
    /// @param _grantee the third-party contract address
    /// @param _invokes the invoke methods that the third-party contract can access
    /// @param _expireTimestamp the authorization expireTimestamp
    function grantAuth(address _grantee, string _invokes, uint _expireTimestamp) public returns (bool success);

    /// @notice alter a third-pary contract's authority
    /// @param _grantee the third-party contract address
    /// @param _invokes the invoke methods that the third-party contract can access
    /// @param _expireTimestamp the authorization expireTimestamp
    function alterAuth(address _grantee, string _invokes, uint _expireTimestamp) public returns (bool success);

    /// @notice delete a third-pary contract's authority
    /// @param _grantee the third-party contract address
    function deleteAuth(address _grantee) public returns (bool success);

    event GrantAuth(address _user, address _grantee, string _invokes, uint _expireTimestamp);
    event DeleteAuth(address _user, address _grantee);
}
