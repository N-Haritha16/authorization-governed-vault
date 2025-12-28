const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deployer:", deployer.address);

  const Auth = await hre.ethers.deployContract(
    "AuthorizationManager",
    [deployer.address]
  );
  await Auth.waitForDeployment();

  const Vault = await hre.ethers.deployContract(
    "SecureVault",
    [Auth.target]
  );
  await Vault.waitForDeployment();

  await Auth.setVault(Vault.target);

  console.log("AuthorizationManager:", Auth.target);
  console.log("SecureVault:", Vault.target);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
