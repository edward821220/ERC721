// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {Test, console2} from "../lib/forge-std/src/Test.sol";
import "../src/HW2.sol";
import "../src/Chainlink.sol";

contract HW2Test is Test {
    HW2 hw2;
    // 部署到 Sepolia 上並在 Chainlink 上 Approve 過的合約
    VRFv2Consumer consumer = VRFv2Consumer(0x5aF35e00075e1Db601B25Cb8f273601e30CF304F);
    address user = makeAddr("alice");
    address user2 = makeAddr("bob");

    function setUp() public {
        uint256 forkId = vm.createFork("https://eth-sepolia.g.alchemy.com/v2/cz7U-l3BDPzRUp-A-fe7afAZ5TJbdE5E");
        vm.selectFork(forkId);
        hw2 = new HW2();
    }

    function testHW2() public {
        vm.startPrank(user);

        // 連續 mint 兩顆 NFT
        hw2.mint(user);
        uint256 random1 = consumer.s_requestId();
        string memory tokenURI1 = hw2.tokenURI(random1);

        hw2.mint(user);
        uint256 random2 = consumer.s_requestId();
        string memory tokenURI2 = hw2.tokenURI(random2);

        // 檢查兩次 mint 產生的隨機數是否不一樣
        assertTrue(random1 != random2);

        // 檢查兩個 NFT 的 tokenURI 是否相同（一開始都是盲盒狀態）
        assertEq(tokenURI1, tokenURI2);
        assertEq(
            keccak256(bytes(tokenURI1)),
            keccak256(bytes("https://raw.githubusercontent.com/edward821220/NFT721/main/src/metadata/hw2-hide.json"))
        );

        vm.stopPrank();

        // 如果不是擁有者就不能開啟盲盒
        vm.prank(user2);
        vm.expectRevert("You are not the owner of this token!");
        hw2.openToken(random1);

        vm.startPrank(user);

        // 如果發行 NFT 合約後沒超過 30 天就不能開啟盲盒
        vm.expectRevert("You need to wait more than 30 days!");
        hw2.openToken(random1);

        // 正確執行打開盲盒的 function 後檢查是否是正確的 tokenURI
        vm.warp(hw2.createdTime() + 30 days);
        hw2.openToken(random1);
        hw2.openToken(random2);

        assertEq(tokenURI1, tokenURI2);
        string memory openedTokenURI1 = hw2.tokenURI(random1);
        assertEq(
            keccak256(bytes(openedTokenURI1)),
            keccak256(bytes("https://raw.githubusercontent.com/edward821220/NFT721/main/src/metadata/hw2-open.json"))
        );

        // 把存在 solt[6] 的 totalSupply 改成 0，測試是否還可以 mint
        vm.store(address(hw2), bytes32(uint256(6)), bytes32(uint256(0)));
        vm.expectRevert("No tokens left!");
        hw2.mint(user);

        vm.stopPrank();
    }
}
