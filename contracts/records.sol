// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >= 0.8.0;

contract StudentRecords{


    struct Student {
        uint id;
        string name;
        uint rollNo;
        uint semester;
        mapping(uint => string) grade;
        mapping(uint => uint) attendance;
        address studentWallet;
        bool isRegistered;
    }
    mapping(uint => Student) students; //To map each id to student, automatically stored on storage.
    uint public studentCount;//Global variable, automatically stored on storage & assigned 0.
    
    address public _owner;

    constructor(){
        _owner = msg.sender;
    }


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


    function registerStudent(string memory name, uint rollno, uint sem, address key) public onlyOwner returns(uint, bool){
        require(checkAddress(key), "The provided wallet key already exist");
        require(checkRoll(rollno), "Student with given Roll no already exist");
        studentCount++;

        students[studentCount].id = studentCount;
        students[studentCount].name = name;
        students[studentCount].rollNo = rollno;
        students[studentCount].semester = sem;
        students[studentCount].attendance[sem] = 0;
        students[studentCount].studentWallet = key;
        students[studentCount].isRegistered = true;

        return (studentCount, true);
    }

    function getStudent(uint id) public view checkStudent(id) returns(string memory, uint, uint){
        return(students[id].name, students[id].rollNo, students[id].semester);
    }

    //function getStudentFullInfo(uint id)

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

    function updateSem(uint id, uint sem) public onlyOwner checkStudent(id) returns(bool){
        students[id].semester = sem;
        return true;
    }

    function addGrade(uint id, uint sem, string memory _grade) public onlyOwner checkStudent(id) checkSem(id, sem) returns(bool){
        students[id].grade[sem] = _grade;
        return true;
    }

    function getGrade(uint id, uint sem) public view checkStudent(id) checkSem(id, sem) returns(string memory a){
        return students[id].grade[sem];
    }

    //Semester wise grade
    function updateGrade(uint id, uint sem, string memory _grade) public onlyOwner checkStudent(id) returns(bool){
        require(bytes(students[id].grade[sem]).length != 0, "No grade. First add grade");
        students[id].grade[sem] = _grade;
        return true;
    }

    //Semester wise attendance
    function updateAttendance(uint id, uint sem) public onlyOwner checkStudent(id) checkSem(id, sem) returns(bool){
        students[id].attendance[sem] += 1;
        return true;
    }

    function getAttendance(uint id, uint sem) public view checkStudent(id) checkSem(id, sem) returns(uint){
        return students[id].attendance[sem];
    }

    function balanceOf(uint id) public checkStudent(id) view returns(uint){
        address stuAddress = students[id].studentWallet;
        return(address(stuAddress).balance);
    }

    function checkRoll(uint roll) public view onlyOwner returns(bool){
        uint count = 0;
        for(uint i = 1; i <= studentCount; i++){
            if(students[i].rollNo == roll){
                count++;
            }
        }
        if(count != 0){
            return false;
        }
        else{
            return true;
        }
    }

    function checkAddress(address stuAddress) public view onlyOwner returns(bool){
        uint count = 0;
        for(uint i = 1; i <= studentCount; i++){
            if(students[i].studentWallet == stuAddress){
                count++;
            }
        }
        if(count != 0){
            return false;
        }
        else{
            return true;
        }
    }
}