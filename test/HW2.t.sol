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

    function setUp() public {
        uint256 forkId = vm.createFork(
            "https://soft-tiniest-flower.ethereum-sepolia.discover.quiknode.pro/82c8473640e5def9bb007aef0253d95cdc3f7c09"
        );
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

        // 執行打開盲盒的 function 後檢查是否是正確的 tokenURI
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
