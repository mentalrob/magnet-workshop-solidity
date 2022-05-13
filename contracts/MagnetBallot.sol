pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract MagnetBallot is AccessControl {
    struct Workshop {
        string name;
        string organizer;
        address moderator;
        uint upvote;
        uint downvote;
        uint voteEndAt;
    }

    IERC20 public magnetToken;
    Workshop[] public proposedWorkshops;
    mapping(address => mapping(uint => bool)) voted;
    bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");

    event WorkshopProposed(string indexed name, string indexed organizer, address indexed moderator);

    constructor(address _magnetTokenAddress) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MODERATOR_ROLE, msg.sender);
        magnetToken = IERC20(_magnetTokenAddress);
    }

    function proposeWorkshop(string calldata name, string calldata organizer, uint voteTimeAsHours) external {
        require(hasRole(MODERATOR_ROLE, msg.sender), "Only moderators");
        uint voteTimeAsSeconds = voteTimeAsHours * 60 * 60;
        Workshop memory ws = Workshop(name, organizer, msg.sender, 0, 0, block.timestamp + voteTimeAsSeconds);
        proposedWorkshops.push(ws);
        emit WorkshopProposed(name,organizer,msg.sender);
    }

    function voteWorkshop(uint id, bool upvote) external {
        Workshop storage ws = proposedWorkshops[id];
        require(block.timestamp < ws.voteEndAt, "Voting ended");
        require(!voted[msg.sender][id], "You already voted");

        uint votingPower = magnetToken.balanceOf(msg.sender);
        if(upvote) {
            ws.upvote += votingPower;
        }else{
            ws.downvote += votingPower;
        }

        voted[msg.sender][id] = true;
    }
}