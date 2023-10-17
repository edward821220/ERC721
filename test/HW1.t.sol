// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {Test, console2} from "../lib/forge-std/src/Test.sol";
import "../src/HW1.sol";

contract HW1Test is Test {
    error ERC721InvalidSender(address sender);

    HW1 hw1;
    NFTReceiver receiver;
    OtherNFT otherNFT;
    address user1 = makeAddr("Alice");
    address user2 = makeAddr("Bob");

    function setUp() public {
        hw1 = new HW1();
        receiver = new NFTReceiver(address(hw1));
        otherNFT = new OtherNFT(user1);
    }

    function testHW1() public {
        uint256 tokenId = 1;
        uint256 tokenId2 = 2;

        vm.startPrank(user1);
        hw1.mint(user1, tokenId);

        // mint 後是否 owner 為 user1
        assertEq(hw1.ownerOf(tokenId), user1);
        // name 和 symbol 是否正確
        assertEq(keccak256(bytes(hw1.name())), keccak256("Don't send NFT to me"));
        assertEq(keccak256(bytes(hw1.symbol())), keccak256("NONFT"));

        // 如果之前這個 tokenId 有被 mint 過則 revert error
        vm.expectRevert(abi.encodeWithSelector(ERC721InvalidSender.selector, address(0)));
        hw1.mint(user1, tokenId);

        // mint 另一顆來檢查是否都是相同的 meta data
        hw1.mint(user1, tokenId2);
        assertEq(keccak256(bytes(hw1.tokenURI(tokenId))), keccak256(bytes(hw1.tokenURI(tokenId2))));

        vm.stopPrank();
    }

    function testNFTReceiver() public {
        uint256 tokenId = 1;

        vm.startPrank(user1);
        // 如果是 hw1 這個 NFT 的話，Receiver 可以接收
        hw1.mint(user1, tokenId);
        hw1.safeTransferFrom(user1, address(receiver), tokenId);
        assertEq(hw1.ownerOf(tokenId), address(receiver));
        assertEq(hw1.balanceOf(address(receiver)), 1);

        // 如果是收到其他 NFT 的話要退還，所以最後的 owner 還是 user1 自己並且 receiver 不會有 OtherNFT 的 balance
        otherNFT.safeTransferFrom(user1, address(receiver), tokenId);
        assertEq(otherNFT.ownerOf(tokenId), address(user1));
        assertEq(otherNFT.balanceOf(address(receiver)), 0);

        // 退還時還要給一顆 HW1 NFT
        assertEq(hw1.balanceOf(user1), 1);
        vm.stopPrank();
    }
}
