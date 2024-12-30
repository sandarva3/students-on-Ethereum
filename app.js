const Web3 = require("web3");

let web3;
let studentRecords;

window.addEventListener("load", async () => {
    web3 = new Web3("http://127.0.0.1:8545");
    
    const contractAddress = "0x0457a80E41be16F7e858a591D626521c372d796f";
    const contractABI = [
        {
            "inputs": [ 
                { "internalType": "string", "name": "name", "type": "string" },
                { "internalType": "uint256", "name": "rollno", "type": "uint256" },
                { "internalType": "uint256", "name": "sem", "type": "uint256" },
                { "internalType": "address", "name": "key", "type": "address" }
            ],
            "name": "registerStudent",
            "outputs": [
                { "internalType": "uint256", "name": "", "type": "uint256" },
                { "internalType": "bool", "name": "", "type": "bool" }
            ],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                { "internalType": "uint256", "name": "id", "type": "uint256" }
            ],
            "name": "getStudent",
            "outputs": [
                { "internalType": "string", "name": "", "type": "string" },
                { "internalType": "uint256", "name": "", "type": "uint256" },
                { "internalType": "uint256", "name": "", "type": "uint256" }
            ],
            "stateMutability": "view",
            "type": "function"
        }
    ];
    

    studentRecords = new web3.eth.Contract(contractABI, contractAddress);
});

async function registerStudent() {
    const accounts = await web3.eth.getAccounts();
    const name = document.getElementById("name").value;
    const rollNo = document.getElementById("rollNo").value;
    const semester = document.getElementById("semester").value;
    const wallet = accounts[0];

    try {
        await studentRecords.methods.registerStudent(name, rollNo, semester, wallet)
            .send({ from: accounts[0] });
        alert("Student registered successfully!");
    } catch (error) {
        console.error(error);
        alert("Error registering student.");
    }
}

async function getStudent() {
    const id = document.getElementById("studentId").value;

    try {
        const result = await studentRecords.methods.getStudent(id).call();
        document.getElementById("studentInfo").innerText = 
            `Name: ${result[0]}, Roll No: ${result[1]}, Semester: ${result[2]}`;
    } catch (error) {
        console.error(error);
        alert("Error fetching student information.");
    }
}
