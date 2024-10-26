// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >= 0.5;

contract StudentRecords{


    struct Student {
        uint id;
        string name;
        uint rollNo;
        uint semester;
        mapping(uint => string) grade;
        uint attendance;
        address studentWallet;
        bool isRegistered;
    }
    mapping(uint => Student) students; //To map each id to student, automatically stored on storage.
    uint public studentCount;//Global variable, automatically stored on storage & assigned 0.
    address _owner = msg.sender;


    modifier onlyOwner {
        require(msg.sender == _owner, "not the owner");
        _;
    }
    modifier checkStudent(uint id){
        require(students[id].isRegistered, "Student not registered");
        _;
    }
    modifier checkSem(uint id, uint sem){
        require(students[id].semester < sem, "Hasn't passed the given semester. Update the semester");
        _;
    }



    function registerStudent(string memory name, uint rollno, uint sem, address key) public returns(bool){
        studentCount++;
        students[studentCount] = Student(studentCount, name, rollno, sem,"", 0, key, true);
        students[studentCount].grade[sem] = "";
        return true;
    }

    function getStudent(uint id) public view returns(string memory, uint, uint){
        return(students[id].name, students[id].rollNo, students[id].semester);
    }

    function getWallet(uint id) public view returns(address){
        return(students[id].studentWallet);
    }

    function updateName(uint id, string memory name) public onlyOwner checkStudent(id) returns(bool){
        students[id].name = name;
        return true;
    }

    function updateRoll(uint id, uint roll) public onlyOwner checkStudent(id) returns(bool){
        students[id].rollNo = roll;
        return true;
    }

    function updateSem(uint id, string memory sem) public onlyOwner checkStudent(id) returns(bool){
        students[id].semester = sem;
        return true;
    }

    function addGrade(uint id, uint sem, string memory _grade) public onlyOwner checkStudent(id) checkSem(id, sem) returns(bool){
        students[id].grade[sem] = _grade;
        return true;
    }

    function updateGrade(uint id, uint sem, string memory _grade) public onlyOwner checkStudent(id) returns(bool){
        require(students[id].grade[sem], "No grade. First add grade");
        students[id].grade[sem] = _grade;
        return true;
    }
}