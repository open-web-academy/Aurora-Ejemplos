require('dotenv').config();
const hre = require("hardhat");

async function main() {

    const provider = hre.ethers.provider;
    const deployerWallet = new hre.ethers.Wallet(process.env.AURORA_PRIVATE_KEY, provider);

    console.log(
        "Deploying contracts with the account:",
        deployerWallet.address
    );

    console.log(
        "Account balance:",
        (await deployerWallet.getBalance()).toString()
    );

    const WalletMultifirma = await hre.ethers.getContractFactory("WalletMultifirma");
    const contract = await WalletMultifirma
        .connect(deployerWallet)
        .deploy();
    await contract.deployed();

    console.log("Market deployed to:", contract.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
