// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract HW1 is ERC721 {
    // 1. Create a ERC721 token with name and symbol.
    constructor() ERC721("Don't send NFT to me", "NONFT") {}

    // 2. Have the mint function to mint a new token
    function mint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }

    // 3. The NFT image is always the same.
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        return '{ "image": "https://imgur.com/IBDi02f" }';
    }
}

contract NFTReceiver is IERC721Receiver, HW1 {
    uint256 private nonce = 0;
    address hw1;

    constructor(address _hw1) {
        hw1 = _hw1;
    }

    function onERC721Received(address, address from, uint256 tokenId, bytes calldata data)
        external
        override
        returns (bytes4)
    {
        // 1. check the sender (ERC721 contract) is the same as your ERC721 contract
        // 2. if not, please transfer this token back to the original owner.
        // 3. and also mint your HW1 token to the original owner.
        if (msg.sender != address(hw1)) {
            // Transfer the token back to the original owner
            IERC721(msg.sender).safeTransferFrom(address(this), from, tokenId, data);

            // Mint a HW1 token to the original owner
            uint256 randomTokenId = uint256(keccak256(abi.encodePacked(block.timestamp, nonce)));
            HW1(hw1).mint(from, randomTokenId);
            nonce++;
        }

        return this.onERC721Received.selector;
    }
}

contract OtherNFT is ERC721 {
    constructor(address owner) ERC721("OtherNFT", "ONFT") {
        _safeMint(owner, 1);
    }
}
