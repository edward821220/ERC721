// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract HW1 is ERC721 {
    // 1. Create a ERC721 token with name and symbol.
    constructor() ERC721("Don't send NFT to me", "NONFT") {}

    // 2. Have the mint function to mint a new token
    function mint(uint256 tokenId) public {
        _safeMint(msg.sender, tokenId);
    }

    // 3. The NFT image is always the same.
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        return '{ "image": "https://imgur.com/IBDi02f" }';
    }
}

contract NFTReceiver is IERC721Receiver, HW1 {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4)
    {
        // 1. check the sencder(ERC721 contract) is the same as your ERC721 contract

        // 2. if not, please transfer this token back to the original owner.

        // 3. and also mint your HW1 token to the original owner.
    }
}
