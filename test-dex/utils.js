const { ethers, run, upgrades } = require("hardhat");
const { getAddress, keccak256, solidityPack } = require("ethers/lib/utils");

const ONE = ethers.BigNumber.from(1);
const TWO = ethers.BigNumber.from(2);

exports.deployWireLib = async function (deployer) {
  const WireLib = await ethers.getContractFactory("WireLib", {
    signer: deployer,
  });
  const wireLib = await WireLib.deploy();
  await wireLib.deployed();

  return wireLib;
};

exports.deployFactory = async function (deployer, feeToSetter, wireLib) {
  const Factory = await ethers.getContractFactory("XDAOFactory", {
    signer: deployer,
    libraries: {
      WireLib: wireLib,
    },
  });

  const factory = await Factory.connect(deployer).deploy(feeToSetter);
  await factory.deployed();

  return factory;
};

exports.deployWBNB = async function (deployer) {
  const WBNB = await ethers.getContractFactory("WBNB");
  const wbnb = await WBNB.connect(deployer).deploy();
  await wbnb.deployed();

  return wbnb;
};

exports.deployGovLib = async function (deployer) {
  const GovernanceLib = await ethers.getContractFactory("GovLib", {
    signer: deployer,
  });
  const governanceLib = await GovernanceLib.deploy();
  await governanceLib.deployed();

  return governanceLib;
};


exports.deployTGR = async function (deployer, wireLib, governanceLib) {
  const TGRToken = await ethers.getContractFactory("TGRToken", {
    signer: deployer,
    libraries: {
      WireLib: wireLib,
      GovLib: governanceLib,
    },
  });

  const crssToken = await TGRToken.connect(deployer).deploy();
  await crssToken.deployed();

  return crssToken;
};

exports.deployMockToken = async function (deployer, name, symbol) {
  const MockToken = await ethers.getContractFactory("MockToken");
  const mock = await MockToken.connect(deployer).deploy(name, symbol);
  await mock.deployed();

  return mock;
};

exports.verifyContract = async function (contract, params) {
  try {
    // Verify
    console.log("Verifying: ", contract);
    await run("verify:verify", {
      address: contract,
      constructorArguments: params,
    });
  } catch (error) {
    if (error && error.message.includes("Reason: Already Verified")) {
      console.log("Already verified, skipping...");
    } else {
      console.error(error);
    }
  }
};

exports.deployMaker = async function (deployer, wbnb, wireLib) {
  const Router = await ethers.getContractFactory("Maker", {
    signer: deployer,
    libraries: {
      WireLib: wireLib,
    },
  });

  const router = await Router.connect(deployer).deploy(wbnb);
  await router.deployed();

  return router;
};

exports.deployTaker = async function (deployer, wbnb, wireLib) {
  const Router = await ethers.getContractFactory("Taker", {
    signer: deployer,
    libraries: {
      WireLib: wireLib,
    },
  });

  const router = await Router.connect(deployer).deploy(wbnb);
  await router.deployed();

  return router;
};

exports.verifyUpgradeable = async function (address) {
  try {
    // Verify
    const contract = await upgrades.erc1967.getImplementationAddress(address);
    console.log("Verifying: ", contract);
    await run("verify:verify", {
      address: contract,
    });
  } catch (error) {
    if (error && error.message.includes("Reason: Already Verified")) {
      console.log("Already verified, skipping...");
    } else {
      console.error(error);
    }
  }
};

exports.deployFarmLib = async function (deployer) {
  const FarmLib = await ethers.getContractFactory("FarmLib", {
    signer: deployer,
  });
  const farmLib = await FarmLib.deploy();
  await farmLib.deployed();

  return farmLib;
};

exports.deployFarm = async function (deployer, crssAddr, crssPerBlock, startBlock, wireLib, farmLib) {
  const XDAOFarm = await ethers.getContractFactory("XDAOFarm", {
    signer: deployer,
    libraries: {
      WireLib: wireLib,
      FarmLib: farmLib
    },
  });

  const crossFarm = await XDAOFarm.connect(deployer).deploy(crssAddr, crssPerBlock, startBlock);
  await crossFarm.deployed();

  return crossFarm;
};

exports.deployXTGR = async function (deployer, name, symbol, wireLib) {
  const XTGRToken = await ethers.getContractFactory("XTGRToken", {
    signer: deployer,
    libraries: {
      WireLib: wireLib
    },
  });

  const xTGRToken = await XTGRToken.connect(deployer).deploy(name, symbol);
  await xTGRToken.deployed();

  return xTGRToken;
};

exports.deployReferral = async function (deployer) {
  const Referral = await ethers.getContractFactory("TGRReferral", {
    signer: deployer,
  });

  const referral = await Referral.connect(deployer).deploy();
  await referral.deployed();
  
  return referral;
};

exports.deployRTGR = async function (deployer) {
  const RTGRToken = await ethers.getContractFactory("RTGRToken", {
    signer: deployer,
  });

  const rTGRToken = await RTGRToken.connect(deployer).deploy();
  await rTGRToken.deployed();
  
  return rTGRToken;
};

exports.deployRSyrup = async function (deployer, crssAddr) {
  const RSyrup = await ethers.getContractFactory("RSyrupBar", {
    signer: deployer,
  });

  const rSyrup = await RSyrup.connect(deployer).deploy(crssAddr);
  await rSyrup.deployed();
  
  return rSyrup;
};

exports.deployRepay = async function (deployer, crssAddr, rTGRAddr, rSyrupAddr, crssPerBlock, startBlock, wireLib) {
  const Repay = await ethers.getContractFactory("Repay", {
    signer: deployer,
    libraries: {
      WireLib: wireLib
    },
  });

  const repay = await Repay.connect(deployer).deploy(crssAddr, rTGRAddr, rSyrupAddr, crssPerBlock, startBlock);
  await repay.deployed();
  
  return repay;
};

exports.getCreate2Address = function (factoryAddress, tokens, bytecode) {
  const [token0, token1] = tokens[0] < tokens[1] ? [tokens[0], tokens[1]] : [tokens[1], tokens[0]];
  const create2Inputs = [
    "0xff",
    factoryAddress,
    keccak256(solidityPack(["address", "address"], [token0, token1])),
    keccak256(bytecode),
  ];
  const sanitizedInputs = `0x${create2Inputs.map((i) => i.slice(2)).join("")}`;
  return getAddress(`0x${keccak256(sanitizedInputs).slice(-40)}`);
};

exports.sqrt = function (value) {
  x = value;
  let z = x.add(ONE).div(TWO);
  let y = x;
  while (z.sub(y).isNegative()) {
    y = z;
    z = x.div(z).add(z).div(TWO);
  }
  return y;
};

exports.ZERO_ADDRESS = ethers.constants.AddressZero;
