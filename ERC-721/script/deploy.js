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

    const NFT721 = await hre.ethers.getContractFactory("NFT721");
    const contract = await NFT721
        .connect(deployerWallet)
        .deploy();
    await contract.deployed();

    console.log("NFT721 deployed to:", contract.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
