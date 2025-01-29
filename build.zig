const std = @import("std");

pub fn build(b: *std.Build) void {
    const native_target = b.standardTargetOptions(.{});
    const targets = [_]std.Build.ResolvedTarget{
        b.resolveTargetQuery(.{
            .cpu_arch = .x86_64,
            .os_tag = .windows,
        }),
        b.resolveTargetQuery(.{
            .cpu_arch = .aarch64,
            .os_tag = .windows,
        }),

        b.resolveTargetQuery(.{
            .cpu_arch = .x86_64,
            .os_tag = .linux,
        }),
        b.resolveTargetQuery(.{
            .cpu_arch = .aarch64,
            .os_tag = .linux,
        }),

        b.resolveTargetQuery(.{
            .cpu_arch = .x86_64,
            .os_tag = .macos,
        }),
        b.resolveTargetQuery(.{
            .cpu_arch = .aarch64,
            .os_tag = .macos,
        }),
    };

    const optimize = b.standardOptimizeOption(.{});

    const core = b.addModule("core", .{
        .root_source_file = b.path("src/core/root.zig"),
        .target = native_target,
        .optimize = optimize,
    });

    for (targets) |target| {
        var name_buf: [64]u8 = undefined;
        const result = std.fmt.bufPrint(&name_buf, "client-{s}+{s}", .{ @tagName(target.result.os.tag), @tagName(target.result.cpu.arch) }) catch {
            std.debug.print("Failed to format a name for `client`\n", .{});
            continue;
        };

        const client = b.addExecutable(.{ .name = result[0..result.len], .root_source_file = b.path("src/client/client.zig"), .target = target, .optimize = optimize, .strip = true, .single_threaded = true });

        client.root_module.addImport("core", core);
        b.installArtifact(client);
    }

    const unit_tests = b.addTest(.{
        .root_source_file = b.path("src/tests.zig"),
        .target = native_target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
