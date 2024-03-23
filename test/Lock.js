const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const hre = require("hardhat");
describe("Lock", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployPills() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const Pills = await ethers.getContractFactory("Pills");
    const pills = await Pills.deploy();

    return { pills, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should deploy", async function () {
      const { pills, owner, otherAccount } = await loadFixture(deployPills);
    });
    describe("Minting", function () {
      it("should be minted", async function () {
        const { pills, owner, otherAccount } = await loadFixture(deployPills);
        const mintValue = BigInt(0.005 * 10 ** 18);
        // Call the mintPill function with 0.1 ether
        await pills.connect(owner).mintPill({ value: mintValue });
        await pills.connect(owner).mintPill({ value: mintValue });
        await pills.connect(owner).mintPill({ value: mintValue });

        // Assert that the total supply has increased by 1
        expect(await pills.totalSupply()).to.equal(3);
      });
    });

    describe("Batch minting", function () {
      it("should be minted", async function () {
        const { pills, owner, otherAccount } = await loadFixture(deployPills);
        const mintValue = BigInt(3 * 0.005 * 10 ** 18);
        // Call the mintPill function with 0.1 ether
        await pills.connect(owner).mintBatch(5, { value: mintValue });

        // Assert that the total supply has increased by 1
        expect(await pills.totalSupply()).to.equal(5);
      });
    });
  });
});
