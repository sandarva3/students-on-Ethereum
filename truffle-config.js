module.exports = {
    networks: {
        development: {
            host: "127.0.0.1",     // Localhost (default: none)
            port: 8545,            // Ganache GUI RPC server port
            network_id: "*",       // Match any network id
        },
    },
    compilers: {
        solc: {
            version: "0.8.0",      // Specify your Solidity compiler version
            settings: {
                optimizer: {
                    enabled: true,
                    runs: 200,
                },
                viaIR: true,
            },
        },
    },
};