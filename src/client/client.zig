const std = @import("std");
const core = @import("core");

const DIFFICULTY: u8 = 3;

const HASH_TYPE = core.HASH_TYPE;
const DifficultHash = core.DifficultHash;

pub fn main() !void {
    const duration = std.time.ns_per_s * 300; // 5 minutes
    var timer = try std.time.Timer.start();

    var mined_hashes: u16 = 0;

    while (timer.read() < duration) {
        // Generates random hex string to hash
        const input = blk: {
            var input: [48]u8 = undefined;
            std.crypto.random.bytes(&input);
            break :blk std.fmt.bytesToHex(input, .upper);
        };

        const mined_hash = DifficultHash.compute(DIFFICULTY, &input);

        std.debug.print("\nSuccessfully found a hash!\nInput: {s}\nNonce: {}\nHash: {s}\nHash (integer array): {any}\n\n", .{ input, mined_hash.nonce, std.fmt.bytesToHex(mined_hash.hash, .lower), mined_hash.hash });

        // Testing validation function
        try mined_hash.validate(&input);

        mined_hashes += 1;
    }
    std.debug.print("\nHarvest is over!\nComputed: {} hashes\nDifficulty: {}\nAlgorithm: {}\nTime elapsed: {} s\n", .{ mined_hashes, DIFFICULTY, HASH_TYPE, timer.read() / std.time.ns_per_s });
}
