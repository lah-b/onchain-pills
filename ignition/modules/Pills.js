const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("PillsModuleBaseMainnet", (m) => {
  const pills = m.contract("Pills");

  return { pills };
});
