import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Faucet, Hack } from "../typechain-types";
import { ethers } from "hardhat";
import { expect } from "chai";

describe("Faucet Test", () => {
  let signers: SignerWithAddress[];
  let owner: SignerWithAddress;
  let faucet: Faucet;
  let hack: Hack;
  let balance = ethers.utils.parseEther("1");
  before(async () => {
    signers = await ethers.getSigners();
    owner = signers[0];
  });

  it("Should deploy", async () => {
    const FaucetContract = await ethers.getContractFactory("Faucet");
    const faucetContract = await FaucetContract.deploy({ value: balance });
    expect(faucetContract.address).to.not.eq(ethers.constants.AddressZero);
    expect(await faucetContract.getBalance()).to.eq(balance);
    faucet = faucetContract as Faucet;

    const HackContract = await ethers.getContractFactory("Hack");
    const hackContract = await HackContract.deploy(faucet.address);
    expect(hackContract.address).to.not.eq(ethers.constants.AddressZero);
    hack = hackContract as Hack;
  });

  it("Should hack", async function () {
    expect(await hack.getBalance()).to.eq(0);
    expect(await faucet.getBalance()).to.eq(balance);
    hack.attack();
    expect(await hack.getBalance()).to.eq(balance);
    expect(await faucet.getBalance()).to.eq(0);
  });
});
