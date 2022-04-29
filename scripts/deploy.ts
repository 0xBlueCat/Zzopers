// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function deployRandom():Promise<string>{
  const random = await hre.ethers.getContractFactory("contracts/random.sol:Random");
  const r = await random.deploy();
  await r.deployed();
  console.log("Random deployed to:", r.address)
  return r.address;
}

async function main() {
  await deployRandom();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
