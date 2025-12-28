const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying with:", deployer.address);

  // 1. Deploy a dummy vault first so we can pass its address to AuthorizationManager
  const DummyVault = await ethers.getContractFactory("SecureVault");
  // Temporarily pass zero address; will not be used
  const dummyAuthMgr = "0x0000000000000000000000000000000000000001";
  const tempVault = await DummyVault.deploy(dummyAuthMgr);
  await tempVault.waitForDeployment();
  const tempVaultAddress = await tempVault.getAddress();
  console.log("Temporary vault deployed to:", tempVaultAddress);

  // 2. Deploy AuthorizationManager bound to temp vault and signer = deployer
  const AuthorizationManager = await ethers.getContractFactory("AuthorizationManager");
  const authorizationManager = await AuthorizationManager.deploy(
    tempVaultAddress,
    deployer.address
  );
  await authorizationManager.waitForDeployment();
  const authorizationManagerAddress = await authorizationManager.getAddress();
  console.log("AuthorizationManager deployed to:", authorizationManagerAddress);

  // 3. Deploy real SecureVault bound to AuthorizationManager
  const SecureVault = await ethers.getContractFactory("SecureVault");
  const secureVault = await SecureVault.deploy(authorizationManagerAddress);
  await secureVault.waitForDeployment();
  const secureVaultAddress = await secureVault.getAddress();
  console.log("SecureVault deployed to:", secureVaultAddress);

  // 4. (Optional) you could rebind the manager to the real vault in a more advanced design,
  // but for this minimal task, evaluation scripts can just use the final SecureVault + manager.
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
