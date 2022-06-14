const { ethers, waffle, network, upgrades } = require("hardhat");
const { expect, util } = require("chai");
const { utils, BigNumber } = require("ethers");
require("colors");

const {
    deployWireLibrary,
    deployTGR,
    deployWBNB,
    deployFactory,
    deployFarmLibrary,
    deployFarm,
    deployCenter,
    deployCrossLibrary,
    deployRouterLibrary,
    deployMaker,
    deployTaker,
    deployXCrss,
    deployReferral,
    deployMockToken,
    deployRCrss,
    deployRSyrup,
    deployRepay,
    verifyContract,
    verifyUpgradeable,
    getCreate2Address,
    sqrt,
  } = require("./utils");
    const { assert } = require("console");
    const { yellow, cyan } = require("colors");
    const { zeroAddress } = require("ethereumjs-util");
    const { doesNotMatch } = require("assert");
    const zero_address = "0x0000000000000000000000000000000000000000";
    
    let wireLib, factory, wbnb, center, crossLib, routerLib, maker, taker, tgr, mock, mock2, farm, farmLib, xCrss, referral, rCrss, rSyrup, repay;
    let crss_bnb, crss_mck, crss_mck2;
    let owner, alice, bob, carol, dev, buyback, liquidity, treasury;
    let tx;
    
    const FeeMagnifier = Number(1e5); // 
    const DECIMALS = 18;
    const INITIAL_SUPPLY = 1e6;

function weiToEthEn(wei) {
  return Number(utils.formatUnits( BigInt(wei).toString(), DECIMALS)).toLocaleString("en");
}

function weiToEth(wei) {
  return Number(utils.formatUnits( BigInt(wei).toString(), DECIMALS));
}

function ethToWei(eth) {
  return utils.parseUnits(eth.toString(), DECIMALS);
}

function mega(wei) {
  return Number(utils.formatUnits( BigInt(wei/1e6).toString(), DECIMALS)).toString() + "M";
}

function uiAddr(address) {
  return "{0x" + address.substring(2, 6).concat("...") + "}";
}

function stringify(strValue) {
  return strValue.toString();
}

async function expectRevertedWith(tx, withMsg) {
  await expect(tx).to.be.revertedWith(withMsg);
}

async function expectNotReverted(tx) {
  await expect(tx).to.be.not.reverted;
}

async function expectReverted(tx) {
  await expect(tx).to.be.reverted;
}

async function mintBlocks(blocks) {
    let bn0 = (await ethers.provider.getBlock("latest")).number;
    for (let n = 0; n < blocks; n++) {
      await network.provider.send("evm_mine");
    }
    let bn1 = (await ethers.provider.getBlock("latest")).number;
    console.log("\t%s/%s blocks minted".green, bn1 - bn0, blocks);
}

async function mintTime(seconds) {
    let tm0 = (await ethers.provider.getBlock("latest")).timestamp;
    await network.provider.send("evm_increaseTime", [seconds]);
    console.log("\t%s seconds minted.", (await ethers.provider.getBlock("latest")).timestamp - tm0);
}

async function showVirtualBurn() {
    let user_burn = await tgr.user_burn();
    console.log("\n\tsum_balances: %s, pending_burn: %s, latestRound: %s", 
    user_burn.sum_balances, user_burn.pending_burn, user_burn.latestRound);
    
    console.log("\towner: %s, alice: %s, bob: %s, carol: %s",
    await tgr.balanceOf(owner.address), await tgr.balanceOf(alice.address), await tgr.balanceOf(bob.address), await tgr.balanceOf(carol.address) );

    await tgr.checkForConsistency();
    console.log("\tConsistency checked!");
}

describe("====================== Stage 1: ======================\n".yellow, async function () {
    it("Main contracts are deployed.\n".green, async function () {
        [owner, alice, bob, carol] = await ethers.getSigners();
        owner.name = "Owner"; alice.name = "Alice"; bob.name = "Bob"; carol.name = "Carol";

        console.log("\tOwner address: ".cyan, owner.address);
        console.log("\tAlice address: ".cyan, alice.address);
        console.log("\tBob address: ".cyan, bob.address);
        console.log("\tCarol address: ".cyan, carol.address);

		const AnalyticMath = await ethers.getContractFactory("AnalyticMath", owner);
		analyticMath = await AnalyticMath.deploy();
        await analyticMath.init();
		console.log("\tAnalyticMath contract was deployed at: ", analyticMath.address);

        tgr = await deployTGR(owner, analyticMath.address);
        console.log("\tTGR contract deployed at: %s", tgr.address);
        console.log("\tOwner's balance: %s", await tgr.balanceOf(owner.address));

        await showVirtualBurn();

        await mintBlocks(5);
        await tgr.pulse_user_burn();
        await showVirtualBurn();

        await tgr.connect(owner).transfer(alice.address, ethToWei(10));
        await mintBlocks(5);
        await tgr.pulse_user_burn();
        await showVirtualBurn();


    });

});

