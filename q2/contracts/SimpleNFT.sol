// SPDX-License-Identifier: MIT
// contracts/GameItem.sol
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../contracts/MerkleTree.sol"



contract SimpleNFT is ERC721URIStorage {
    using Counters for Counters.Counter; // ??
    Counters.Counter private _tokenIds; // setting up _tokenIds which is Counters.Counter type.

    MerkleTree private mTree;

    constructor() ERC721("Kittie", "Mew") {
        mTree = new MerkleTree();
    } // constructor which created 1 collectible.

    
    function _mintNewNFT(address player, string memory tokenURI)
        public 
        returns  ( uint256 )
    {
        _tokenIds.increment(); // increments the tokenId
        uint256 tokenId = _tokenIds.current(); // the latest incremented id is the new item id.
        _mint(player, tokenId); // mints the nft with that item id, on the player's address. Can be msg.sender if nothing is sent.
        _setTokenURI(tokenId, tokenURI); // for the newly minted token, sets the uri to the one provided by the player.

        mTree.addLeafToMerkleTree(msg.sender, player, tokenId, tokenURI); // add the leaf data to a merkle tree
        return tokenId; // return the token id
    }
}