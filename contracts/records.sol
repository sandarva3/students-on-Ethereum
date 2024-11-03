// SPDX-License-Identifier: SEE LICENSE IN LICENSE

pragma solidity >= 0.8.0;

contract StudentRecords{
    using SafeMath for uint;

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
    mapping(uint => uint) maxAttendance;
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

    event studentRegistered(
        uint id,
        string name,
        uint roll,
        uint sem,
        address walletKey
        );
    event nameUpdated(
        uint id,
        string oldName,
        string newName
    );
    event rollUpdated(
        uint id,
        uint oldRoll,
        uint newRoll
    );
    event semUpdated(
        uint id,
        uint oldSem,
        uint newSem
    );
    event gradeUpdated(
        uint id,
        string oldGrade,
        string newGrade
    );
    event deposited(
        uint amount,
        address from
    );
    event etherSent(
        uint amount,
        string name,
        uint id,
        address _address
    );



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

        emit studentRegistered(studentCount, name, rollno, sem, key);
        return (studentCount, true);
    }

    function getStudent(uint id) public view checkStudent(id) returns(string memory, uint, uint){
        return(students[id].name, students[id].rollNo, students[id].semester);
    }

    function getStudentFullInfo(uint id) public view onlyOwner checkStudent(id)
    returns(
        uint,
        string memory,
        uint,
        uint,
        string memory,
        uint,
        address,
        bool
    )
    {
         uint currentSem = students[id].semester;
         return(
            students[id].id,
            students[id].name,
            students[id].rollNo,
            currentSem,
            students[id].grade[currentSem],
            students[id].attendance[currentSem],
            students[id].studentWallet,
            students[id].isRegistered
         );
    }

    function getWallet(uint id) public view returns(address){
        return(students[id].studentWallet);
    }

    function updateName(uint id, string memory name) public onlyOwner checkStudent(id) returns(bool){
        emit nameUpdated(id, students[id].name, name);
        students[id].name = name;
        return true;
    }

    function updateRoll(uint id, uint roll) public onlyOwner checkStudent(id) returns(bool){
        require(checkRoll(roll), "The Roll no already exist.");
        emit rollUpdated(id, students[id].rollNo, roll);
        students[id].rollNo = roll;
        return true;
    }

    function updateSem(uint id, uint sem) public onlyOwner checkStudent(id) returns(bool){
        emit semUpdated(id, students[id].semester, sem);
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
        emit gradeUpdated(id, students[id].grade[sem], _grade);
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

    function viewEther() public view onlyOwner returns(uint){
        return address(this).balance;
    }
    
    function deposit(uint amount) public payable onlyOwner returns(bool){ //In web3 js interface we specify value in calling deposit()
        require(amount > 0, "Amount must be greater than zero");
        emit deposited(amount, _owner);

        return true;
    }

    function sendEther(uint amount, uint id) public onlyOwner returns(bool){
        require(amount > 0, "Amount must be greater than zero");
        require(address(this).balance > amount, "Insufficient balance in contract.");

        address receiver = students[id].studentWallet;
        (bool success, ) = receiver.call{value: amount} ("");
        require(success, "Transfer failed");
        emit etherSent(amount, students[id].name, id, receiver);

        return true;
    }

    function setAttendance(uint value, uint sem) public onlyOwner returns(bool){
        maxAttendance[sem] = value;
        return true;
    }

    function sendPrize(uint id) internal{
        address receiver = students[id].studentWallet;
        (bool success, ) = receiver.call{value: 5*1 ether} ("");
        require(success, "Transfer Failed.");
    }

    function distributePrize(uint sem) public onlyOwner returns(bool){
        require(maxAttendance[sem] > 0, "Max-Attendance for this semester is not set.");
        uint count;
        uint index;
        for(uint i = 1; i <= studentCount; i++){
            uint _sem = students[i].semester;
            if(_sem == sem){
                count += 1;
              //  totalStudents.push(i);
            }
        }

        uint[] memory totalStudents = new uint[](count);

        for(uint i = 1; i <= studentCount; i++){
            uint _sem = students[i].semester;
            if(_sem == sem){
                totalStudents[index] = i;
                index += 1;
            }
        }

        count = 0;
        index = 0;

        for(uint i = 0; i < totalStudents.length; i++){
            uint id = totalStudents[i];
            uint _attendance = students[id].attendance[sem];
            if(_attendance == maxAttendance[sem]){
                count += 1;
            }
        }

        uint[] memory boringStudents = new uint[](count);
        for(uint i = 0; i < totalStudents.length; i++){
            uint id = totalStudents[i];
            uint _attendance = students[id].attendance[sem];
            if(_attendance == maxAttendance[sem]){
                boringStudents[index] = id;
                index += 1;
            }
        }

        uint totalBorers = boringStudents.length;
        uint requiredAmount = totalBorers.mul(5*1 ether);

        require(address(this).balance >= requiredAmount, "Insufficient Balance.");

        for(uint i = 0; i < totalBorers; i++){
            uint id = boringStudents[i];
            sendPrize(id);
        }

        return true;
    }

    function removeStudent(uint id) public checkStudent(id) returns(bool){
    
    }

}


library SafeMath { 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the benefit
        // is lost if 'b' is also tested.
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        assert(c / a == b); // Ensures no overflow occurred
        return c;
    }
}
