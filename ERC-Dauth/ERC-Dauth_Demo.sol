pragma solidity ^0.4.20;

import "github.com/Arachnid/solidity-stringutils/strings.sol";


contract ERCDauth {
    using strings for *;
    
    /* AuthInfo: User can add an AuthInfo to record third-party authority
     *  - grantee: third-party's address
     *  - invokes: methods which third-party can invoke
     *  - duration: how long the authority will keep
     *  - startTimestamp: the start timestamp
     */
    struct AuthInfo {
        address grantee;
        string[] invokes;
        uint duration;
        uint startTimestamp;
    }
    
    // user's address -> an array of AuthInfo
    mapping (address=>AuthInfo[]) userAuth;
    
    /*
     * use grantee and user's address to check if grantee can invoke some method
     */
    function checkAuth(address grantee, address user, string invoke) internal returns (bool){
        for(uint i; i<userAuth[user].length; i++){
            if (userAuth[msg.sender][i].grantee == grantee && now - userAuth[msg.sender][i].startTimestamp < userAuth[msg.sender][i].duration) {
                for(uint j; j<userAuth[user][i].invokes.length; j++){
                    if (userAuth[user][i].invokes[j].toSlice().equals(invoke.toSlice())){
                        return true;
                    }
                }
            }
        }
    }
    
    function grantAuth(address grantee, string invokes, uint duration) public {
        var s = invokes.toSlice();
        var delim = " ".toSlice();
        var parts = new string[](s.count(delim) + 1);
        for(uint i = 0; i < parts.length; i++) {
            parts[i] = s.split(delim).toString();
        }
        
        var flag = true;
        for(i = 0; i < userAuth[msg.sender].length; i++){
            if (userAuth[msg.sender][i].grantee == grantee){
                userAuth[msg.sender][i].invokes = parts;
                userAuth[msg.sender][i].duration = duration;
                flag = false;
                break;
            }
        }
        if (flag){
            userAuth[msg.sender].push(AuthInfo(grantee, parts, duration, now));
        }
    }
    
    function alterAuth(address grantee, string invokes, uint duration) public {
        grantAuth(grantee, invokes, duration);
    }
    
    function delAuth(address grantee) public {
        uint index;
        for(uint i = 0; i < userAuth[msg.sender].length; i++){
            if (userAuth[msg.sender][i].grantee == grantee){
                index = i;
                break;
            }
        }
        delete userAuth[msg.sender][index];
    }
}


contract Demo is ERCDauth {
    /*
     * when an address invoke this method, it should private if it is a user or a third-party(replace some user), 
     * then this method will run some codes using the user's authority
     */
    function authMethod(address user, bool isUser) public {
        if (!isUser) {
            require(checkAuth(msg.sender, user, 'authMethod'));
        }else{
            user = msg.sender;
        }
        
        // Todo with "user"
    }
}