//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contract/token/ERC721/ERC721.sol"
import "@openzeppelin/contract/token/ERC721/extensions/ERC721Burnable.sol"
import "@openzeppelin/contract/access/AccessControl.sol"
import "@openzeppelin/contract/utils/Counters.sol"

import "hardhat/console.sol";

contract RandomNFT is ERC721, ERC721Burnable, AccessControl {
    using Counters for Counters.Counter

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Random NFT", "RDN") {
        _grantRole(DEFAUT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    };

    function _baseRUI() internal pure override returns (string memory) {
        return "ipfs::/ipfs_link/";
    }

    function safeMint(address to) public onlyRole(MINTER_ROLE) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    function supportsInterface(bytes32 interfaceId) public view override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId)
    }
}
