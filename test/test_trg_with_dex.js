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
    deployXLibrary,
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
    let owner, alice, bob, carol, tgrftm, tgrhtz, votes;
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
  
  async function eventTrigger(factory, tx, eventName, args) {
    await expect(tx)
      .to.emit(factory, eventName)
      .withArgs(...args);
  }
  
  function expectEqual(a, b) {
    expect(a).to.be.eq(b);
  }
  
  function expectNotEqual(a, b) {
    expect(a).to.be.not.eq(b);
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
    console.log("\n\tsum_balances: %s, pending_burn: %s, totalSupply: %s", 
    user_burn.sum_balances, user_burn.pending_burn, await tgr.totalSupply());

    // console.log("\towner: %s, alice: %s, bob: %s, carol: %s",
    // await tgr.balanceOf(owner.address), await tgr.balanceOf(alice.address), await tgr.balanceOf(bob.address), await tgr.balanceOf(carol.address) );

    await tgr.checkForConsistency();
    console.log("\tConsistency checked!");
}

async function transfer(sender, recipient, amount) {
  let balance = await tgr.balanceOf(sender.address);
  if (ethToWei(amount) > balance) amount = weiToEth(balance);
  console.log("\t%s is transferring %s %s TGR ...".yellow, sender.name, recipient.name, amount);
  tx = tgr.connect(sender).transfer(recipient.address, ethToWei(amount));
  (await tx).wait();
  console.log("\tTransfer done".green);
}

describe("====================== Stage 1: Test TGR Pulses ======================\n".yellow, async function () {
    it("Main contracts are deployed.\n".green, async function () {
        // For the sake of transfer test, the pools tgrftm, tgrhtz and votes are wallet accounts.
        // This way we can simulate a transfer from/to/between those pools.

        [owner, alice, bob, carol, tgrftm, tgrhtz, votes] = await ethers.getSigners();
        owner.name = "Owner"; alice.name = "Alice"; bob.name = "Bob"; carol.name = "Carol";
        tgrftm.name = "TgrFtm"; tgrhtz.name = "TgrHtz"; votes.name = "Votes";

        console.log("\tOwner address: ".cyan, owner.address);
        console.log("\tAlice address: ".cyan, alice.address);
        console.log("\tBob address: ".cyan, bob.address);
        console.log("\tCarol address: ".cyan, carol.address);
        console.log("\tTgrFtm address: ".cyan, tgrftm.address);
        console.log("\tTgrHtz address: ".cyan, tgrhtz.address);
        console.log("\tVotes address: ".cyan, votes.address);

        wireLib = await deployWireLibrary(owner);
        console.log("\tWireLibrary deployed at: %s", wireLib.address);

    		const AnalyticMath = await ethers.getContractFactory("AnalyticMath", owner);
		    analyticMath = await AnalyticMath.deploy();
        await analyticMath.init();
		    console.log("\tAnalyticMath contract was deployed at: ", analyticMath.address);

        tgr = await deployTGR(owner, analyticMath.address, wireLib.address);
        console.log("\tTGR contract deployed at: %s", tgr.address);
        console.log("\tOwner's balance: %s", await tgr.balanceOf(owner.address));

        await showVirtualBurn();

        await mintBlocks(50);
        await tgr.pulse_user_burn();
        await showVirtualBurn();

        await transfer(owner, alice, 10);
        await mintBlocks(5);
        await tgr.pulse_user_burn();
        await showVirtualBurn();

        await transfer(owner, bob, 1000);
        await mintBlocks(50);
        await tgr.pulse_user_burn();
        await showVirtualBurn();

        await transfer(owner, carol, 5000);
        await mintBlocks(50);
        await tgr.pulse_user_burn();
        await showVirtualBurn();

        await mintBlocks(50);
        await tgr.pulse_user_burn();
        await showVirtualBurn();

        await transfer(owner, carol, 100);
        await mintBlocks(50);
        await tgr.pulse_user_burn();
        await showVirtualBurn();

        await transfer(carol, carol, 100);
        await mintBlocks(50);
        await tgr.pulse_user_burn();
        await showVirtualBurn();

        await transfer(carol, alice, 100);
        await mintBlocks(50);
        await tgr.pulse_user_burn();
        await showVirtualBurn();

        await transfer(owner, tgrftm, 100);
        await mintBlocks(50);
        await tgr.pulse_user_burn();
        await showVirtualBurn();

        await transfer(tgrftm, tgrhtz, 101);
        await mintBlocks(50);
        await tgr.pulse_user_burn();
        await showVirtualBurn();

        await transfer(owner, votes, 10000);
        await showVirtualBurn();
        await mintBlocks(20);
        await tgr.pulse_vote_burn();
        await showVirtualBurn();


    });

});


describe("====================== Stage 2: Deploy contracts ======================\n".yellow, async function () {
    it("Main contracts are deployed.\n".green, async function () {

        // Factory Deployment.
        factory = await deployFactory(owner, wireLib.address);
        console.log("\tFactory deployed at %s", factory.address);

        console.log("\tXFactory contract was deployed at: %s", factory.address);
        console.log("\t!!! Pair's bytecode hash = \n\t", (await factory.INIT_CODE_PAIR_HASH()).substring(2));
        console.log("\t!!! Please make sure the pairFor(...) function of XLibrary.sol file has the same hash.");

        // WBNB Deployment.
        wbnb = await deployWBNB(owner);
        console.log("\tWBNB deployed at: %s", wbnb.address);

        center = await deployCenter(owner, wireLib.address);
        center.address = center.address;
        console.log("\tContralCenter deployed at %s", center.address);

        crossLib = await deployXLibrary(owner);
        console.log("\tXLibrary deployed at %s", crossLib.address);

        // RouterLibrary Deployment for Maker and Taker.
        routerLib = await deployRouterLibrary(owner);
        console.log("\tRouterLibrary deployed at %s", routerLib.address);

        // Maker Deployment.
        maker = await deployMaker(owner, wbnb.address, wireLib.address, routerLib.address);
        console.log("\tMaker deployed at %s", maker.address);

        // Taker Deployment.
        taker = await deployTaker(owner, wbnb.address, wireLib.address, routerLib.address);
        console.log("\tTaker deployed at %s", taker.address);

        // Referral Deployment.
        referral = await deployReferral(owner);
        console.log("\tReferral deployed at %s", referral.address);

        // Mock Token Deployment.
        mock = await deployMockToken(owner, "Mock", "MCK");
        console.log("\tmock deployed at %s", mock.address);

        // Mock Token Deployment.
        mock2 = await deployMockToken(owner, "Mock2", "MCK2");
        console.log("\tmock2 deployed at %s", mock2.address);

    });

    describe("====================== Stage 3: Test CrossFactory ======================\n".yellow, async function () {
        it("\tInitial values were checked.\n".green, async function () {
            let feeTo = await factory.feeTo();
            expectEqual(feeTo, zero_address);
            console.log("\tInitial feeTo value is zero address.");
        
            let pairsLength = await factory.allPairsLength();
            expectEqual(pairsLength, 0);
            console.log("\tThere, initially, are no pairs created.");
        
            let factoryOwner = await factory.getOwner();
            console.log("\tOwner is deployer.");
            expectEqual(factoryOwner, owner.address);
            console.log("\tOwner address: %s", factoryOwner.address);
        });
      
        it("\tsetFeeTo function was checked.\n".green, async function () {
            let tx = factory.connect(alice).setFeeTo(bob.address);
            await expectRevertedWith(tx, "Caller != owner");
            console.log("\tAlice, a non-owner, setting feeTo to Bob reverted with <Caller != owner>");
        
            tx = factory.setFeeTo(owner.address);
            await expectNotReverted(tx);
            console.log("\tThe current owner could set feeTo to Bob.");
      
        });     

      });
      

});