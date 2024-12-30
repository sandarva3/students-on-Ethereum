const Web3 = require("web3");

let web3;
let studentRecords;

// Connect directly to Ganache
window.addEventListener("load", async () => {
    web3 = new Web3("http://127.0.0.1:8545"); // Direct connection to Ganache RPC
    
    const contractAddress = "0x0457a80E41be16F7e858a591D626521c372d796f"; // Replace with your contract address
    const contractABI = [/* ABI from StudentRecords.json */];

    studentRecords = new web3.eth.Contract(contractABI, contractAddress);
});

// Example function to register a student
async function registerStudent() {
    const accounts = await web3.eth.getAccounts(); // Fetch accounts from Ganache
    const name = document.getElementById("name").value;
    const rollNo = document.getElementById("rollNo").value;
    const semester = document.getElementById("semester").value;
    const wallet = accounts[0]; // Use the first account from Ganache

    try {
        await studentRecords.methods.registerStudent(name, rollNo, semester, wallet)
            .send({ from: accounts[0] });
        alert("Student registered successfully!");
    } catch (error) {
        console.error(error);
        alert("Error registering student.");
    }
}

// Example function to fetch student info
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
