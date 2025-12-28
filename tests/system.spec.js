const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Authorization-governed vault", function () {
  it("accepts deposits", async function () {
    const [signer] = await ethers.getSigners();

    const AuthorizationManager = await ethers.getContractFactory("AuthorizationManager");
    const SecureVault = await ethers.getContractFactory("SecureVault");

    // simple setup: manager expects vault address, but in tests we deploy in order
    const dummyVault = await SecureVault.deploy(ethers.ZeroAddress);
    await dummyVault.waitForDeployment();

    const manager = await AuthorizationManager.deploy(
      await dummyVault.getAddress(),
      signer.address
    );
    await manager.waitForDeployment();

    const vault = await SecureVault.deploy(await manager.getAddress());
    await vault.waitForDeployment();

    await signer.sendTransaction({
      to: await vault.getAddress(),
      value: ethers.parseEther("1")
    });

    const balance = await vault.balances(signer.address);
    expect(balance).to.equal(ethers.parseEther("1"));
  });
});
