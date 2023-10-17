// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {Test, console2} from "../lib/forge-std/src/Test.sol";
import "../src/ERC721.sol";

contract ERC721Test is Test {
    error ERC721InvalidSender(address sender);

    HW1 hw1;
    address user1 = makeAddr("Alice");
    address user2 = makeAddr("Bob");

    function setUp() public {
        hw1 = new HW1();
    }

    function testHW1() public {
        uint256 tokenId = 1;
        uint256 tokenId2 = 2;

        vm.startPrank(user1);
        hw1.mint(tokenId);

        // mint 後是否 owner 為 user1
        assertEq(hw1.ownerOf(tokenId), user1);
        // name 和 symbol 是否正確
        assertEq(keccak256(bytes(hw1.name())), keccak256("Don't send NFT to me"));
        assertEq(keccak256(bytes(hw1.symbol())), keccak256("NONFT"));

        // 如果之前這個 tokenId 有被 mint 過則 revert error
        vm.expectRevert(abi.encodeWithSelector(ERC721InvalidSender.selector, address(0)));
        hw1.mint(tokenId);

        // mint 另一顆來檢查是否都是相同的 meta data
        hw1.mint(tokenId2);
        assertEq(keccak256(bytes(hw1.tokenURI(tokenId))), keccak256(bytes(hw1.tokenURI(tokenId2))));

        vm.stopPrank();
    }
}
