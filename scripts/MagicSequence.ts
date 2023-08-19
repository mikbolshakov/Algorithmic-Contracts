import { ethers } from "hardhat";

const UINT32_MAX = ethers.BigNumber.from(2 ** 32 - 1);

const calculation = (input: number): string => {
  const HASH = ethers.utils.solidityKeccak256(["uint256"], [input]);
  const UINT256_CAST = ethers.BigNumber.from(HASH);

  const RSHIFT = UINT256_CAST.shr(224);
  const UINT32_CAST = RSHIFT.and(UINT32_MAX);
  const BYTES4 = ethers.utils.hexZeroPad(ethers.utils.hexlify(UINT32_CAST), 4);

  return BYTES4;
};

const main = () => {
  const HASHES = ["Oxbeced095", , "9x42a7b7dd", "9x45e010b9", "Oxa86c339e"];

  for (const hash of HASHES) {
    console.log("Run")
    for (let i = 0; i <= UINT32_MAX.toNumber(); i++) {
        if (i % 1000000 == 0) console.log(i)
      if (calculation(i) == hash) {
        console.log(`Number to produce hash ${hash} is ${i}`);
        break;
      }
    }
  }
};

main();
