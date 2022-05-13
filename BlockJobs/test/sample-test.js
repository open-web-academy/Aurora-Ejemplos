const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Market", function () {
  it("Should return the new greeting once it's changed", async function () {
    const Market = await ethers.getContractFactory("Market");
    const market = await Market.deploy("Hello, world!");
    await market.deployed();

    expect(await market.greet()).to.equal("Hello, world!");

    const setGreetingTx = await market.setGreeting("Hola, mundo!");

    // wait until the transaction is mined
    await setGreetingTx.wait();

    expect(await market.greet()).to.equal("Hola, mundo!");
  });
});
