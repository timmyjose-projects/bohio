const std = @import("std");
const Allocator = std.mem.Allocator;
const os = std.os;
const fs = std.fs;
const egg = @import("../lib.zig");

pub fn homeDir() egg.BohioError![]const u8 {
    return if (os.getenv("HOME")) |home| home else error.HomeNotFound;
}

pub fn clutchHome(allocator: *Allocator) egg.BohioError![]const u8 {
    if (os.getenv("CLUTCH_HOME")) |clutch_home| {
        if (fs.path.isAbsolute(clutch_home)) {
            return clutch_home;
        }

        var buf: [fs.MAX_PATH_BYTES]u8 = undefined;
        if (os.getcwd(&buf)) |cwd| {
            return fs.path.joinPosix(allocator, &[_][]const u8{ cwd, clutch_home }) catch |_| {
                return egg.BohioError.ClutchHomeNotFound;
            };
        } else |_| {
            return egg.BohioError.ClutchHomeNotFound;
        }
    }

    const home = try homeDir();
    return fs.path.joinPosix(allocator, &[_][]const u8{ home, ".clutch" }) catch |_| {
        return egg.BohioError.ClutchHomeNotFound;
    };
}
