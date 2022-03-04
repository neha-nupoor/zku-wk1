pragma circom 2.0.0;

include "./node_modules/circomlib/circuits/mimcsponge.circom";

// Helper template that computes hashes of the next tree layer
template TreeLayer(height) {
  var nItems = 1 << height;
  signal input ins[nItems * 2];
  signal output outs[nItems];

  component hash[nItems];
  for(var i = 0; i < nItems; i++) {
    hash[i] = MiMCSponge(2, 220, 1);
    hash[i].ins[0] <== ins[i * 2];
    hash[i].ins[1] <== ins[i * 2 + 1];
    hash[i].k <== 0;
    hash[i].outs[0] ==> outs[i];
  }
}

// Builds a merkle tree from leaf array
template MerkleTree(levels) {
  signal input leaves[1 << levels];
  signal output root;

  component layers[levels];
  for(var level = levels - 1; level >= 0; level--) {
    layers[level] = TreeLayer(level);
    for(var i = 0; i < (1 << (level + 1)); i++) {
      layers[level].ins[i] <== level == levels - 1 ? leaves[i] : layers[level + 1].outs[i];
    }
  }
  root <== levels > 0 ? layers[0].outs[0] : leaves[0];
}

component main {public [leaves]} = MerkleTree(3);

// [ERROR] snarkJS: circuit too big for this power of tau ceremony. 9240*2 > 2**12 
// -> fixed by changing the power to a bigger one when starting a power ceremony: snarkjs powersoftau new bn128 $POWER (13) ...
// Initally changed the power to double(24) and it was taking too long. With 2**15[32,768] it should work.

//  compile circuit
// circom merkle.circom --r1cs --wasm --sym --c

// ptau
// snarkjs powersoftau new bn128 15 pot12_0000.ptau -v
// snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v


// phase2
// snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
// snarkjs groth16 setup merkle.r1cs pot12_final.ptau merkle_0000.zkey
// snarkjs zkey contribute merkle_0000.zkey merkle_0001.zkey --name="1st Contributor Name" -v
// snarkjs zkey export verificationkey merkle_0001.zkey verification_key.json


// generate proof
// snarkjs groth16 prove merkle_0001.zkey witness.wtns proof.json public.json

// verify proof
// snarkjs groth16 verify verification_key.json public.json proof.json




