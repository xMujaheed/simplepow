const std = @import("std");
const builtin = @import("builtin");

pub const HASH_TYPE = std.crypto.hash.blake2.Blake2b(384);

pub const DifficultHash = struct {
    hash: [HASH_TYPE.digest_length]u8,
    difficulty: u8,
    nonce: u64,

    pub fn build(hash: [HASH_TYPE.digest_length]u8, difficulty: u8, nonce: u64) DifficultHash {
        return DifficultHash{ .hash = hash, .difficulty = difficulty, .nonce = nonce };
    }

    pub fn compute(difficulty: u8, input: []const u8) DifficultHash {
        var hash: [HASH_TYPE.digest_length]u8 = undefined;
        var nonce: u64 = 0;

        while (true) {
            // You can use any hash you want
            var hasher = HASH_TYPE.init(.{});

            // Prepend a nonce to input
            hasher.update(&intToBytes(u64, nonce, .little));
            hasher.update(input);
            hasher.final(&hash);

            // First N(DIFFICULTY) bytes
            const prefix = hash[0..difficulty];
            // Last N(DIFFICULTY) bytes
            const suffix = hash[hash.len - difficulty .. hash.len];

            // If first N(DIFFICULTY) bytes are equal to last N(DIFFICULTY) bytes
            if (std.mem.eql(u8, prefix, suffix)) {
                break;
            }

            // Increment a nonce to get a different hash
            nonce += 1;
        }

        // Return a nonce which helped produce the right hash
        return DifficultHash.build(hash, difficulty, nonce);
    }

    pub fn validate(self: DifficultHash, input: []const u8) !void {
        const input_hash = self.hash;
        const difficulty = self.difficulty;
        const nonce = self.nonce;

        // First N(DIFFICULTY) bytes
        const prefix = input_hash[0..difficulty];
        // Last N(DIFFICULTY) bytes
        const suffix = input_hash[input_hash.len - difficulty .. input_hash.len];

        // If first N(DIFFICULTY) bytes are NOT equal to last N(DIFFICULTY) bytes
        if (!std.mem.eql(u8, prefix, suffix)) {
            return error.DifficultyDoesntMatch;
        }

        const computed_hash: [HASH_TYPE.digest_length]u8 = blk: {
            var buf: [HASH_TYPE.digest_length]u8 = undefined;

            var hasher = HASH_TYPE.init(.{});
            hasher.update(&intToBytes(u64, nonce, .little));
            hasher.update(input);
            hasher.final(&buf);

            break :blk buf;
        };

        // If hashes dont match
        if (!std.mem.eql(u8, &computed_hash, &input_hash)) {
            return error.HashDoesntMatch;
        }
    }
};

fn intToBytes(comptime T: type, value: T, endian: std.builtin.Endian) [@sizeOf(T)]u8 {
    return @bitCast(if (endian == builtin.cpu.arch.endian()) value else @byteSwap(value));
}
