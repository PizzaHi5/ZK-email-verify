# Building a ZK proof for DKIM signatures

## Description
This repo takes a raw email as input and builds a ZK proof of the DKIM outputting a verifier solidity contract. 

### Motivation
Email providers are all centrally run entities that use any means necessary to break even/make money on an email service. Data privacy is not allowed. 

# Table of Contents
[Installation](#installation)
[Process Begin](#the-process)
[Compute and Compile the Witness](#compile-and-compute-the-witness)
[Proving and Verification keys](#generating-the-proving-and-verification-keys)


## Installation
Followed the ZK-Email example [project](https://prove.email/blog/twitter)
- We removed the twitter regex/inputs/outputs since we are interested in the DKIM ZKP

[Guide](https://docs.circom.io/getting-started/installation/#installing-dependencies)

```
yarn init -y
```

```
yarn add @zk-email/circuits @zk-email/helpers @zk-email/contracts
```

# The Process
Get a raw email (.eml)

Make sure the fs directory is correct in input2.ts

```
npx ts-node input2.ts
``` 

Outputs: Generates a input.json

Delete the twitter_idx_score on the bottom of the input.json output file

## Compile and Compute the witness
### Compile the circuit
```
circom -l node_modules circuits/blackbyrdverifier.circom -o --r1cs --wasm --sym --c
```

Outputs: blackbyrdverifier_cpp, blackbyrdverifier_js, blackbyrdverifier.r1cs, and blackbyrdverifier.sym. 

This is a RAM expensive operation. I was not able to compile the 800k constraint circuit with my 16GB RAM laptop. Optionally: Add ```--O0```. Use ```circom --help``` for more options. My circuit ended up with 2 million constraints using --O0.

### Compute the witness
```
node blackbyrdverifier_js/generate_witness.js blackbyrdverifier_js/blackbyrdverifier.wasm input.json witness.wtns
```

## Generating the proving and verification keys

```
npm install -g snarkjs
```

### Download the phase 1 powersofTau
Fetch finalized powersofTau versions based on your circuit contraints [here](https://github.com/iden3/snarkjs?tab=readme-ov-file#7-prepare-phase-2) based on the amount of constraints your circuit has (recommended)

Or generate your own using a publically distributed phase 1. This is an [example](https://github.com/avvydomains/powers-of-tau)

### Prepare for phase 2
```
snarkjs powersoftau prepare phase2 powersOfTau28_hez_final_22.ptau pot22_final.ptau -v
```

This is a CPU expensive operation. Has taken my laptops +8hrs to start a 4 mil constraint phase 2. 

### Contribute to phase 2
This step differs from the guide. I got error saying the .wasm was an incorrect input parameter. I used the command below to generate our first zkey.
```
snarkjs groth16 setup blackbyrdverifier.r1cs proving/pot22_final.ptau blackbyrdverifier_0000.zkey
```

For production applications, make sure you add your own contribution to the trusted setup phase 2!

```
snarkjs zkey contribute blackbyrdverifier_0000.zkey blackbyrdverifier_0001.zkey --name='1st Contributor Name' -v
```

### Apply the final beacon
Add the final beacon to the contributed phase 2 setup zkey. This will finalize phase 2!

```
snarkjs zkey beacon blackbyrdverifier_0000.zkey blackbyrd_final.zkey 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon phase2"
```

### Export the verification key
Generate the verification key as input for verification

```
snarkjs zkey export verificationkey blackbyrd_final.zkey
```

Generate the solidity contract to deploy on-chain!

```
snarkjs zkey export solidityverifier blackbyrd_final.zkey verifier.sol
```

