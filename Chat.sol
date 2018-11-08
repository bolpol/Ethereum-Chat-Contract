pragma solidity 0.4.25;

/**
    Solidity implimentation of design pattern mediator.
    Chat contract realise simple chat system, where
    users can massege passing in one chat
    
    @author Paul Bolhar - paul.bolhar@gmail.com
*/


interface ChatRoomMediator {
    
     function showMessage(address user, string message);
     event Message(uint256 time, string sender, string text);
}

/**
 * @dev Ownable contract
 *      Simple realisation of standart OZ Ownable contract
 */ 
contract Ownable {
    
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}

/**
 * @dev ChatRoom contract
 *      Chat room base contract, accepting all members messages here
 */
contract ChatRoom is ChatRoomMediator, Ownable {
    
    User user;
    
    function showMessage(address _user, string message) public
    {
        user = User(_user);
        uint256 time = now;
        string memory sender = user.getName();

        emit Message(time, sender, message);
    }
}

/**
 * @dev User contract
 *      Interact with chat room via this contract
 */
contract User is Ownable {
    
    ChatRoomMediator chatMediator;
    
    string private name;

    constructor(address _owner, string _name, address _chatMediator) public {
        owner = _owner;
        name = _name;
        chatMediator = ChatRoomMediator(_chatMediator);
    }

    function getName() 
        public 
        returns(string) 
    {
        return name;
    }

    /**
     * @dev send message to chat
     */
    function send(string message) 
        public 
        onlyOwner 
    {
        chatMediator.showMessage(this, message);
    }
}

/**
 * @dev Chat contract
 *      Init chat and add users
 */
contract Chat {
    
    event NewUser(address indexed user);
    
    // Chat contract address
    address public mediator = new ChatRoom();
 
    mapping (bytes32 => bool) public users;
    
    modifier onlyNotUsers(string _nick) {
        require(users[keccak256(_nick)] != true);
        _;
    }
    
    modifier validNickName(string _nick) {
        require(bytes(_nick).length >= 3 && bytes(_nick).length <= 24);
        _;
    }
    
    /**
     * @dev input your nickname with length more 3 letters 
     * @return address contract User
     */
    function participateInChat(string _nick_name) 
        public
        validNickName(_nick_name)
        onlyNotUsers(_nick_name) 
        returns(address) 
    {
        users[keccak256(_nick_name)] = true;
        address user = new User(msg.sender, _nick_name, mediator);
        emit NewUser(user);
        return user;
    }
}
