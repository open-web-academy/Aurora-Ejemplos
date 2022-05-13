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

    const TokenSwap = await hre.ethers.getContractFactory("TokenSwap");
    const contract = await TokenSwap
        .connect(deployerWallet)
        .deploy();
    await contract.deployed();

    console.log("TokenSwap deployed to:", contract.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
