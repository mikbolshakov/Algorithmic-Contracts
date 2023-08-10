import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { VerifySignature } from "../typechain-types";
import { ethers } from "hardhat";
import { expect } from "chai";

describe("SalaryIssuance Test", () => {
  let signers: SignerWithAddress[];
  let owner: SignerWithAddress;
  let signatureContract: VerifySignature;
  before(async () => {
    signers = await ethers.getSigners();
    owner = signers[0];
  });

  it("Should deploy", async () => {
    const Factory = await ethers.getContractFactory("VerifySignature");
    const sigContract = await Factory.deploy();
    expect(sigContract.address).to.not.eq(ethers.constants.AddressZero);
    signatureContract = sigContract as VerifySignature;
  });

    it('Should verify', async function () {
      const messageHash = await signatureContract.generateHash(owner.address);
      // ethereum.enable()
      // p = ethereum.request({method: 'personal_sign', params: [owner.address, messageHash]})

      const signature = await owner.signMessage(ethers.utils.arrayify(messageHash));
      const { r, s, v } = ethers.utils.splitSignature(signature);

      expect(await signatureContract.verify(owner.address, signature)).to.eq(true);
    });
});
