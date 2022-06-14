// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IXdaoAgency {
    event NewAgent(address indexed agent);
    event TaskCreated(address indexed agent, uint taskId);
    event TaskValidated(uint taskId);
    event BidPlaced(uint taskId, address indexed carrer);
    event BidAccepted(uint taskId, address indexed carrer);
    event Slashed(address indexed agent);
    event Stake(address indexed agent, uint amount);
    event UnStake(address indexed agent, uint amount);
    event LevelUpdate(address indexed agent, uint level);
    event TgrBonus(address indexed agent, uint taskId);

    function submitTask(
        TaskDetails memory
    ) external returns (uint taskId);

    function postTask(uint taskId) external;

    function verifyTask(uint taskId) external;

    function compeletTask(uint taskId) external;

    function placeBid(uint taskId) external;

    function stake(uint amount) external;

    function unStake(uint amount) external;

    function enterEscrow(uint taskId) external;

    function getAvaliabeTasks(address agent) external view;
}

struct Agent {
    address account;
    uint level;
    uint stakedAmount;
}

enum TaskStatus {
    Pending,
    Verified,
    Posted,
    Assigned,
    Complete,
    Incomplete,
    Cancelled
}

enum JobBidType {
    FirstPerson,    // first person can complete the job.
    OneWinner,      // a selected bidder from multiple bidders can complete the job.
    MultiWinner     // multiple bidders are selected and the reward is splitted evenly
}

struct TaskDetails {
    string name;
    string summary;
    uint reward;
    uint bonus;
    uint8 minLevel;
    uint8 maxCompletions;
    JobBidType jobType;
    TaskStatus status;
    uint8[] skillSet;
    address owner;
    uint dueTime;
    uint verifiedTime;
}

struct Task {
    string title;
    string description;
    uint price;
    Agent agent;
    Agent[] validators;
    address[] carriers;
    /** Status
    0: agent submitted jobs where they choose someone to complete
    1: continuous “faucet” jobs where anyone can complete them all the time up to an amount of accounts per block
    2: jobs where multiple people are selected but split the money evenly
    3: jobs where multiple people complete the job but only one wins
     */
    uint8 submission;
    uint8[] skillSet;
    uint bonus;
    bool requireValidate;
    uint maxCarriers;
    uint expiredTime;
}

contract XdaoAgency is IXdaoAgency, UUPSUpgradeable, Ownable, Initializable {
    IERC20 public tgr;

    mapping(address => bool) public isAgent;
    mapping(address => Agent) public agentInfo;
    mapping(uint => TaskDetails) public tasks;
    mapping(uint => uint) public taskVerifiersCount;
    mapping(address => uint[]) private userTasks;
    mapping(address => mapping(uint => bool)) public agentVerifiedTask;
    mapping(uint => address[]) public doers;
    mapping(uint => address[]) public bidders;
    mapping(uint => mapping(address => bool)) public bidden;

    uint currentTaskId = 0;
    uint NumVerificationsNeeded = 11;

    event TaskCreated(uint id, string name, uint reward, uint status, uint minLevel, address creator);
    event TaskVerified(uint id);
    event TaskPosted(uint id);
    event TaskAssigned(uint id, address doer);

    modifier onlyAgent() {
        require(isAgent[msg.sender], "No Agent");
        _;
    }

    function setNumVerificationsNeeded(uint _num) external onlyOwner {
        NumVerificationsNeeded = _num;
    }

    function initialize(IERC20 _tgr) public initializer {
        tgr = _tgr;
    }

    function _isTask(uint _id) internal view returns (bool) {
        return _id < currentTaskId;
    }

    function submitTask(
        TaskDetails memory _task
    ) external override onlyAgent returns (uint taskId) {

        currentTaskId++;
        _task.status = TaskStatus.Pending;
        _task.owner = msg.sender;
        tasks[currentTaskId] = _task;

        emit TaskCreated(currentTaskId, _task.name, _task.reward, uint(TaskStatus.Pending), _task.minLevel, msg.sender);

        return 0;
    }

    function verifyTask(uint _taskId) external override onlyAgent {
        require (_isTask(_taskId), "V: Invalid ID");
        require (agentInfo[msg.sender].level >= tasks[_taskId].minLevel, "V: Level!");
        require (!agentVerifiedTask[msg.sender][_taskId], "V: Already");
        require (tasks[_taskId].status == TaskStatus.Pending, "V: Invalid Req");

        agentVerifiedTask[msg.sender][_taskId] = true;
        taskVerifiersCount[_taskId] += 1;

        if (taskVerifiersCount[_taskId] >= 11) {
            tasks[_taskId].status = TaskStatus.Verified;
            tasks[_taskId].verifiedTime = block.timestamp;
            emit TaskVerified(_taskId);
        }
    }

    function postTask(uint _id) external override {
        require (tasks[_id].owner == msg.sender, "P: Access denied");
        require (tasks[_id].status == TaskStatus.Verified, "P: Invalid status");
        require (block.timestamp >= tasks[_id].verifiedTime + 24 hours, "P: Wait pls");

        tasks[_id].status = TaskStatus.Posted;
        emit TaskPosted(_id);
    }

    function compeletTask(uint _id) external override onlyAgent {

    }

    function placeBid(uint _id)
        external
        override
    {
        require (tasks[_id].status == TaskStatus.Posted, "B: Not verified");
        require (agentInfo[msg.sender].level >= tasks[_id].minLevel, "B: No level");

        if (tasks[_id].jobType == JobBidType.FirstPerson) {
            tasks[_id].status = TaskStatus.Assigned;
            doers[_id].push(msg.sender);

            emit TaskAssigned(_id, msg.sender);
        } else {
            require (!bidden[_id][msg.sender], "B: Already bidden");

            bidders[_id].push(msg.sender);
            bidden[_id][msg.sender] = true;
        }
    }

    function assignTask(uint _id, uint[] memory _bidders) external onlyAgent {
        require (tasks[_id].owner == msg.sender, "A: Access denied");
        require (tasks[_id].status == TaskStatus.Posted, "A: Invalid status");

        uint i;
        for (i = 0; i < _bidders.length; i+=1) {
            uint id = _bidders[i];
            doers[_id].push(bidders[_id][id]);

            emit TaskAssigned(_id, bidders[_id][id]);
        }

        tasks[_id].status = TaskStatus.Assigned;
    }

    function completeTask(uint _id) external {

    }

    function stake(uint amount) external override onlyAgent {}

    function unStake(uint amount) external override onlyAgent {}

    function enterEscrow(uint taskId) external override onlyAgent {}

    function getAvaliabeTasks(address agent) external view override {}

    function _authorizeUpgrade(address) internal override onlyOwner {}
}
