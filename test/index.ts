import { expect, use } from "chai";
import { ethers } from "hardhat";
import { Contract, BigNumber, Signer } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { solidity } from "ethereum-waffle";
use(solidity);

describe("NFTStaking", function () {
  let owner: SignerWithAddress;
  let alice: SignerWithAddress;
  let bob: SignerWithAddress;
  let res: any;
  let rewardToken: Contract;
  let randomNFT: Contract;
  let nftStaking: Contract;

  beforeEach(async () => {
    const RewardToken = await ethers.getContractFactory("RewardToken");
    const RandomNFT = await ethers.getContractFactory("RandomNFT");
    const NFTStaking = await ethers.getContractFactory("NFTStaking");

    [owner, alice, bob] = await ethers.getSigners();

    rewardToken = await RewardToken.deploy();
    randomNFT = await RandomNFT.deploy();
    await rewardToken.deployed();
    await randomNFT.deployed();

    nftStaking = await NFTStaking.deploy(
      randomNFT.address,
      rewardToken.address
    );
    await nftStaking.deployed();
  });

  describe("Init", async () => {
    it("Should be initialized", async () => {
      expect(rewardToken).to.be.ok;
      expect(randomNFT).to.be.ok;
      expect(nftStaking).to.be.ok;
    });
  });

  describe("NFT mint testing", async () => {
    it("Should be granted Role", async () => {
      await randomNFT.grantRole(ethers.utils.keccak256(ethers.utils.toUtf8Bytes('MINTER_ROLE')), owner.address);
      expect(await randomNFT.hasRole(ethers.utils.keccak256(ethers.utils.toUtf8Bytes('MINTER_ROLE')), owner.address)).to.eq(true);
    });

    it("Twice mining. Balance should be 2", async () => {
      await randomNFT.safeMint(alice.address);
      await randomNFT.safeMint(alice.address);
      expect(await randomNFT.balanceOf(alice.address)).to.eq(ethers.BigNumber.from(2));
      console.log(await randomNFT._tokenIdCounter());
      console.log(await randomNFT.ownedIDs(alice.address, 0));
    });
  });
});
