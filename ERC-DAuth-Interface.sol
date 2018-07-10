/* Abstract contract for the ERC DAuth protocol: Access Delegation Standard
 * https://github.com/DIA-Network/ERC-DAuth
 * Author: Xiaoyu Wang <wxygeek@gmail.com> Bicong Wang <bicongwang@gmail.com>
 */

pragma solidity ^0.4.24;

contract DAuthInterface {

    /*  Required
        AuthInfo: The struct contains user authorization information
                 User can add an AuthInfo to authorize the client contract
     *  - funcNames: a list of function names callable by the granted contract
     *  - expireAt: the authorization expire timestamp in seconds
     */
    struct AuthInfo {
        string[] funcNames;
        uint expireAt;
    }

    // Required
    // userAuth maps (authorizer address, grantee contract address) pair to the user’s authorization AuthInfo object
    mapping(address => mapping(address => AuthInfo)) userAuth;

    // Required
    // All methods that are allowed other contracts to call
    // The callable function MUST verify the grantee’s authorization
    string[] callableFuncNames;

    /// Optional
    /// @notice update the callable function list for the client contract by the resource contract's administrator
    /// @param _invokes the invoke methods that the client contract can call
    /// @return Whether the callableFuncNames is updated or not
    function updateCallableFuncNames(string _invokes) public returns (bool success);

    /// Required
    /// @notice check the invoke method authority for the client contract
    /// @param _authorizer the user address that the client contract agents
    /// @param _invoke the invoke method that the client contract wants to call
    /// @return Whether the grantee request is authorized or not
    function verify(address _authorizer, string _invoke) internal returns (bool success);

    /// Required
    /// @notice delegate a client contract to access the user's resource
    /// @param _grantee the client contract address
    /// @param _invokes the callabled methods that the client contract can access
    /// @param _expireAt the authorization expire timestamp in seconds
    /// @return Whether the grant is successful or not
    function grant(address _grantee, string _invokes, uint _expireAt) public returns (bool success);

    /// Optional
    /// @notice alter a client contract's delegation
    /// @param _grantee the client contract address
    /// @param _invokes the callabled methods that the client contract can access
    /// @param _expireAt the authorization expire timestamp in seconds
    /// @return Whether the regrant is successful or not
    function regrant(address _grantee, string _invokes, uint _expireAt) public returns (bool success);

    /// Required
    /// @notice delete a client contract's delegation
    /// @param _grantee the client contract address
    /// @return Whether the revoke is successful or not
    function revoke(address _grantee) public returns (bool success);

    // Required
    // This event MUST trigger when the authorizer grant a new authorization, when grant or regrant processes successfully
    event Grant(address _authorizer, address _grantee, string _invokes, uint _expireAt);

    // Required
    // This event MUST trigger when the authorizer revoke a specific authorization successfully
    event Revoke(address _authorizer, address _grantee);
}
