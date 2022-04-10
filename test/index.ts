import { expect } from "chai";
import { ethers } from "hardhat";

describe("NFTStaking", function () {
  it("Should return the new greeting once it's changed", async function () {
    const RewardToken = await ethers.getContractFactory("RewardToken");
    const rewardToken = await RewardToken.deploy("Hello, world!");
    await rewardToken.deployed();
  });
});
