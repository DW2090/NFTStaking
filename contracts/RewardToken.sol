//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contract/token/ERC20/ERC20.sol";
import "@openzeppelin/contract/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contract/access/AccessControl.sol";

import "hardhat/console.sol";

contract RandomNFT is ERC20, ERC20Burnable, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() ERC20("Reward Token", "RWT") {
        _grantRole(DEFAUT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    };

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }
}
