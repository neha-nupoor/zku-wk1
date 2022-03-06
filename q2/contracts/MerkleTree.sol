
// SPDX-License-Identifier: MIT
// contracts/GameItem.sol
pragma solidity ^0.8.0;

contract MerkleTree {
    bytes32[] public hashes;
    uint32 public pow; // variable to calculate the window size of the hashes array.

    uint256 private len = hashes.length; // len is the actual length of leaves inside the array.
    bytes32 private _merkleRoot; // variable holds the merkleRoot. 

    function _increaseWindowSize() private {
        for (uint256 i = len; i<2**pow; i++) {
            hashes.push(0);
        }
    }

    function _calculateHash(address sender, address player, uint256 tokenId, string memory tokenURI) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(sender, player, tokenId, tokenURI));
    }

    function _addHashToLeaf(bytes32 leafHash) private {
        // basic logic: For even txn which is the power of 2, [4,8,16,...], increase the window size by the next power of 2.
        // if 8th element is added, and 9th txn comes in, first add 0s from 9 -> 15 then add leaf at 9th place. 
        // subsequent txns are just updating the 0s in the current window.
        // there could be further improvements here, by duplicating the window in case of a non balanced leaf.
        // another improvement is to update the Merkle hash of only the path which is impacted by the leaf's addition. 
        // However, that would require a pre-seeded array of leafs [thoughts regarding scalability?], 
        // and appending the mid layer hashes to end of array/some other DS.
        // 

        // base case.
        // for first txn, we push the leaf. the hash is the element itself.
        // increment length & power.
        if (len == 0) {
            hashes.push(leafHash);
            hashes.push(0);
            len++;
            pow++;
        } else {
            // if the number of elements are 2^pow (for example: 8)
            // then this incoming txn is going to be the 9th one.
            // we increment the power, and add len -> 2^pow 0s to make the leaves a power of 2 always, to balance merkle tree.
            // Ex: before adding the 9th element, we add 9->15 0s in the hashes array.
            // then we place the 9th element in th hash at `len` position[0-indexed array]
            if (len == 2**pow) {
                pow++;
                _increaseWindowSize();
                hashes[len++] = leafHash;
            } else {
            // if the num of elements are not 2^pow, then we have space in the window to directly place the hash.
            // Ex: if len == 9, the incoming txn is 10th. the window is already padded and exists in the leaf array.
                hashes[len++] = leafHash;
            }
        } 
    }

    function _createMerkleTree () private returns (bytes32 merkleRoot) {
        uint256 n = hashes.length;
        bytes32[] memory midHash = hashes; // this is the midlayer array where hashes of top layers are calculated.
        while (n > 1) { // for n == 1, midHash is hashes, so first element is the hash itself.
            uint256 j = 0;
            // we create a temp array to keep the hashes.
            // midHash itself can be reused, but I have not implemeted it.
            // this could save potential gas.
            bytes32[] memory res = new bytes32[](n); 
            for (uint256 i = 0; int256(i) <= int256(n) - 2; i += 2) {
                res[j] = keccak256(
                        abi.encodePacked(midHash[i], midHash[i + 1])
                    );  
                j++;
            }
            n = n/2;
            midHash = res;
            
        }
        _merkleRoot = midHash[0];
        return _merkleRoot;
    }

    function getMerkleRoot() public view returns (bytes32) {
        // returns the merkle root.
        return _merkleRoot;
    }

    // public fn to add leaf to the m-tree
    function addLeafToMerkleTree(address sender, address player, uint256 tokenId, string memory tokenURI) public {
        bytes32 _leafCommit = _calculateHash(sender, player, tokenId, tokenURI);
        _addHashToLeaf(_leafCommit);
        _createMerkleTree();
    }

    // TBD: create a function for verifying merkle tree using openzeppelin's verifier contract
}