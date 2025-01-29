**Simple (Proof-of-Concept) Proof-of-Work algorithm**

Generates a hash of the given type rotating a nonce until it finds a hash where first N(Difficulty) bytes match last N(Difficulty) bytes

Benchmarks (It's quirky because Zig standard library is not mature enough yet):

```
Blake3: 104 hashes in 5 minutes
Blake2b: 210 hashes in 5 minutes
Sha1: 142 hashes in 5 minutes
Sha3-256: 36 hashes in 5 minutes
Sha2-256: 53 hashes in 5 minutes
```

Difficulty:

6 would take 5 minutes for average ASIC to mine (Blake2b)
7 would take about a day for an ASIC to mine (Blake2b)
8 would take about a year for an ASIC to mine (Blake2b)

In current code difficulty is set to 3 which allows it to generate hashes very frequently (around 0.5 hashes per second for blake2b)
