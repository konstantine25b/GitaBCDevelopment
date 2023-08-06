// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

   interface IProjectSubmitContractCall {
    function receiveProjectData(string memory, string memory, string memory) external payable;
    function isProjectReceived() external view returns (bool);
   }

contract KnowledgeAssessment {

    
    struct Student {
        string name;
        uint256 id;
        uint256[] testScores;
    }

    mapping(address => Student) public students;
    address[] public studentAddresses;

    address public owner;

    event StudentAdded(address indexed studentAddress, string name, uint256 id);
    event TestScoreRecorded(address indexed studentAddress, uint256 score);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addStudent(string memory _name, uint256 _id) external {
        require(bytes(_name).length > 0, "Name cannot be empty");
        students[msg.sender].name = _name;
        students[msg.sender].id = _id;
        studentAddresses.push(msg.sender);

         emit StudentAdded(msg.sender, _name, _id);
    }

    function recordTestScore(uint256 _score) external {
        require(_score >= 0 && _score <= 100, "Invalid test score");
        students[msg.sender].testScores.push(_score);

         emit TestScoreRecorded(msg.sender, _score);
    }
     function getStudentTestScores(address _studentAddress) external view returns (uint256[] memory) {
        return students[_studentAddress].testScores;
    }


    function getTestScores(address _studentAddress) external view returns (uint256[] memory) {
        return students[_studentAddress].testScores;
    }

    function verifyTestScores(address _studentAddress) external view onlyOwner returns (uint256[] memory) {
        return students[_studentAddress].testScores;
    }
   
    function callOtherContract(address _otherContract, address _studentAddress) external  returns (bool success, uint256[] memory scores) {
    bytes memory data = abi.encodeWithSignature("getStudentScores(address)", _studentAddress);
    bytes memory result;
    (success, result) = _otherContract.call(data);

    if (success) {
        (scores) = abi.decode(result, (uint256[]));
    } else {
        revert("Call to other contract failed");
    }
}

    function payAssessmentFee() external payable {
        require(msg.value > 0, "Payment amount must be greater than 0");
        // Implement payment handling logic here
    }

    // Fallback and receive functions for ETH handling
    fallback() external payable {
       
    }

    receive() external payable {
        
    }

     function projectSubmitted(string memory _codeFileHash,string memory _topicName, string memory _authorName, address _sendHashTo) external payable onlyOwner{
        IProjectSubmitContractCall(_sendHashTo).receiveProjectData{value: msg.value, gas: 1000000}(_codeFileHash, _topicName, _authorName);
    }

    function projectReceived()public view onlyOwner returns(bool){
        return  IProjectSubmitContractCall(0x1298aFF3Bf44B87bfF03f864e09F2B86f91BE16F).isProjectReceived();
    }
}


contract  ResultAdding{
    mapping(address => uint256[]) private studentScores;

    function addStudentScores(address _studentAddress, uint256[] memory _scores) external {
        studentScores[_studentAddress] = _scores;
    }

    function getStudentScores(address _studentAddress) external view returns (uint256[] memory) {
        return studentScores[_studentAddress];
    }
    
}