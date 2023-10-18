// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Chainlink.sol";

contract HW2 is ERC721 {
    uint256 totalSupply;
    mapping(uint256 => bool) openTokens;
    VRFv2Consumer consumer;

    constructor() ERC721("HW2Token", "HW2") {
        totalSupply = 500;
        consumer = new VRFv2Consumer(6100);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        if (openTokens[tokenId]) {
            return "https://raw.githubusercontent.com/edward821220/NFT721/main/src/metadata/hw2-open.json";
        }
        return "https://raw.githubusercontent.com/edward821220/NFT721/main/src/metadata/hw2-hide.json";
    }

    function openToken(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "You are not the owner of this token.");
        openTokens[tokenId] = true;
    }

    function mint(address to) public {
        require(totalSupply > 0, "No tokens left.");
        totalSupply--;
        // 產生新的隨機數
        consumer.requestRandomWords();
        // 將隨機數當作 tokenId 產生 NFT
        _mint(to, consumer.s_requestId());
    }
}
