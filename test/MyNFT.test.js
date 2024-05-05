const { BigNumber, constants } = require("ethers");
const { AddressZero, EtherSymbol } = constants;

const { expect } = require("chai");

require("@nomicfoundation/hardhat-chai-matchers");

let nftToken,
  creator,
  other1,
  other2,
  newCreator,
  transferEventInterface,
  event;

describe("MySoulNFT test", function (accounts) {
  const name = "MySoulNFT";
  const symbol = "MSN";
  const baseURI =
    "https://peach-managing-marmot-708.mypinata.cloud/ipfs/QmUUS9a8V4g4rkX5Xo8AoEPuUP4posYKcrsbkGYU7UDLvM/";

  // beforeEach(async function() {
  it("token setup", async function () {
    [creator, other1, other2, newCreator] = await ethers.getSigners();
    const MySoulNFT = await ethers.getContractFactory("MySoulNFT");
    nftToken = await MySoulNFT.deploy(name, symbol);

    expect(nftToken.address).to.be.not.equal(AddressZero);
    expect(nftToken.address).to.match(/0x[0-9a-fA-F]{40}/);
  });

  it("token has correct name", async function () {
    expect(await nftToken.name()).to.be.equal(name);
  });

  it("token has correct symbol", async function () {
    expect(await nftToken.symbol()).to.be.equal(symbol);
  });

  describe("minting", function () {
    it("user can NOT mint tokens", async function () {
      await expect(
        nftToken.connect(other1).mint(other1.address)
      ).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("creator can mint 1 token for other account", async function () {
      tx = await nftToken.connect(creator).mint(other1.address);

      const receipt = await ethers.provider.getTransactionReceipt(tx.hash);
      transferEventInterface = new ethers.utils.Interface([
        "event Transfer(address indexed from, address indexed to, uint256 indexed tokenId)",
      ]);
      const data = receipt.logs[0].data;
      const topics = receipt.logs[0].topics;
      event = transferEventInterface.decodeEventLog("Transfer", data, topics);
      expect(event.from).to.equal(AddressZero);
      expect(event.to).to.equal(other1.address);
      expect(event.tokenId.toString()).to.equal("1");

      expect(await nftToken.balanceOf(other1.address)).to.be.equal(
        BigNumber.from("1")
      );

      expect(await nftToken.ownerOf("1")).to.be.equal(other1.address);
      expect(await nftToken.tokenURI("1")).to.be.equal(baseURI + "1.json");
    });

    it("creator can mint 1 token for other2 account", async function () {
      await expect(nftToken.connect(creator).mint(other2.address))
        .to.emit(nftToken, "Transfer")
        .withArgs(AddressZero, other2.address, 2);

      expect(await nftToken.balanceOf(other2.address)).to.be.equal(
        BigNumber.from("1")
      );

      expect(await nftToken.totalSupply()).to.be.equal(BigNumber.from("2"));

      expect(await nftToken.ownerOf("2")).to.be.equal(other2.address);

      expect(await nftToken.tokenURI("2")).to.be.equal(baseURI + "2.json");
    });
  });

  describe("transfer", function () {
    it("other2 can transfer their tokens", async function () {
      await nftToken
        .connect(other2)
        .transferFrom(other2.address, other1.address, 2);

      expect(await nftToken.balanceOf(other2.address)).to.be.equal(
        BigNumber.from("0")
      );
      expect(await nftToken.balanceOf(other1.address)).to.be.equal(
        BigNumber.from("2")
      );
      expect(await nftToken.totalSupply()).to.be.equal(BigNumber.from("2"));
      expect(await nftToken.ownerOf("2")).to.be.equal(other1.address);
    });
  });

  describe("hardCap", function () {
    it("reaching hard cap", async function () {
      for (let i = 3; i <= 10; i++) {
        await nftToken.connect(creator).mint(other1.address);
      }
      await expect(
        nftToken.connect(creator).mint(other1.address)
      ).to.be.revertedWithCustomError(nftToken, "maxSupplyReached");
    });
  });

  describe("creator can pause and unpause the contract", function () {
    it("pause the contract", async function () {
      await nftToken.connect(creator).pause();
      expect(await nftToken.paused()).to.be.equal(true);
    });

    it("unpause the contract", async function () {
      await nftToken.connect(creator).unpause();
      expect(await nftToken.paused()).to.be.equal(false);
    });
  });
});
