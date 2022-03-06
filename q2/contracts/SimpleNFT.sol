// SPDX-License-Identifier: MIT
// contracts/SimpleNFT.sol
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract SimpleNFT is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter; // ??
    Counters.Counter private _tokenIds; // setting up _tokenIds which is Counters.Counter type.

    MerkleTree private mTree;

    constructor() ERC721("KittieNFT", "Mew") {
        mTree = new MerkleTree();
    } // constructor which created 1 collectible.

    function tokenURI(uint256 tokenId)
        public
        pure
        override
        returns (string memory)
    {
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "My721Token #', tokenId.toString(), '"',
                '"description": "desciptive token uri for token id: #', tokenId.toString(), '"',
            '}'
        );

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }

    
    function _mintNewNFT(address player, string memory tokenUri)
        public 
        returns  ( uint256 )
    {
        _tokenIds.increment(); // increments the tokenId
        uint256 tokenId = _tokenIds.current(); // the latest incremented id is the new item id.
        _mint(player, tokenId); // mints the nft with that item id, on the player's address. Can be msg.sender if nothing is sent.
        _setTokenURI(tokenId, tokenUri); // for the newly minted token, sets the uri to the one provided by the player.
        
        mTree.addLeafToMerkleTree(msg.sender, player, tokenId, tokenUri); // add the leaf data to a merkle tree
        return tokenId; // return the token id
    }
}
