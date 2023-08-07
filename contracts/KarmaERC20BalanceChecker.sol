// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract KarmaERC20BalanceChecker {

  function singleBalance(address user, address token) public view returns (uint256) {
    if (token == address(0)) {
      return user.balance;
    }
    uint256 tokenCode;
    assembly { tokenCode := extcodesize(token) }
    if (tokenCode == 0) {
      return 0;
    }
    try IERC20(token).balanceOf(user) returns (uint256 balance) {
      return balance;
    } catch {
      return 0;
    }
  }

  function bulkBalance(address[] memory users, address token) external view returns (uint256[] memory) {
      uint256[] memory addrBalances = new uint256[](users.length);
      for (uint256 i = 0; i < users.length; i++) {
          addrBalances[i] = singleBalance(users[i], token);
      }
      return addrBalances;
  }
}

