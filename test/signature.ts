import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Signature } from "../typechain-types";
import { ethers } from "hardhat";
import { expect } from "chai";

describe("SalaryIssuance Test", () => {
  let signers: SignerWithAddress[];
  let owner: SignerWithAddress;
  let newOwner: SignerWithAddress;
  let signatureContract: Signature;
//   before(async () => {
//     signers = await ethers.getSigners();
//     owner = signers[0];
//     newOwner = signers[1];
//   });

  it("Deploys, grant role and transfer tokens to contract", async () => {
    const Factory = await ethers.getContractFactory("Signature");
    const sigContract = await Factory.deploy();
    expect(sigContract.address).to.not.eq(ethers.constants.AddressZero);
    signatureContract = sigContract as Signature;
  });
  

  it('should allow executing a transaction by the owner', async function () {
    const [signer] = await ethers.getSigners();

    // Сообщение, которое вы хотите подписать
    const message = 'Hello, world!';

    // Получите хеш сообщения
    const messageHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(message));

    // Создайте подпись
    const signature = await signer.signMessage(ethers.utils.arrayify(messageHash));

    // Разберите подпись на v, r и s
    const { v, r, s } = ethers.utils.splitSignature(signature);

    // Верификация подписи
    const recoveredAddress = ethers.utils.recoverAddress(messageHash, { v, r, s });
    expect(recoveredAddress).to.equal(signer.address);
//     const destination = owner.address;
//     const value = ethers.utils.parseEther('1.0');
//     const data = '0x';

//     await signatureContract.connect(owner).executeTransaction(destination, value, data)
//     await expect(signatureContract.connect(newOwner).executeTransaction(destination, value, data))
//           .to.be.revertedWith('Not an owner');
      });

//   it('should allow the new owner to accept ownership', async function () {
//     const messageHash = await signatureContract.generateHash(owner.address);
//     const signature = await owner.signMessage(ethers.utils.arrayify(messageHash));
//     const { v, r, s } = ethers.utils.splitSignature(signature);

//     await signatureContract.connect(owner).acceptOwnership(owner.address, v, r, s)

//     expect(await signatureContract.owner()).to.equal(newOwner.address);
//     expect(await signatureContract.previousOwner()).to.equal(owner.address);
//   });
  

//   it('should prevent non-owners from accepting ownership', async function () {
//     const messageHash = await signatureContract.generateHash(owner.address);
//     const signature = await owner.signMessage(ethers.utils.arrayify(messageHash));
//     const { v, r, s } = ethers.utils.splitSignature(signature);

//     await expect(signatureContract.connect(owner).acceptOwnership(owner.address, v, r, s))
//       .to.be.revertedWith('You haven\'t provided a signature from the owner');
//   });
});


