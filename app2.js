let web3;
let studentRecords;

window.addEventListener("load", async () => {
    if (window.ethereum) {
        web3 = new Web3(window.ethereum);
        await window.ethereum.enable(); // Request access to user's wallet
    } else {
        alert("Please install MetaMask!");
    }

    const contractAddress = "0x0457a80E41be16F7e858a591D626521c372d796f"; // Replace with deployed contract address
    const contractABI = [/* ABI JSON from Truffle build */];

    studentRecords = new web3.eth.Contract(contractABI, contractAddress);
});

async function registerStudent() {
    const name = document.getElementById("name").value;
    const rollNo = document.getElementById("rollNo").value;
    const semester = document.getElementById("semester").value;
    const wallet = document.getElementById("wallet").value;

    const accounts = await web3.eth.getAccounts();

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
