const std = @import("std");
const Allocator = std.mem.Allocator;
const os = std.os;
const fs = std.fs;
const BohioError = @import("../lib.zig").BohioError;
const egg = @import("../lib.zig");

pub fn homeDir() egg.BohioError![:0]const u16 {
    return if (os.getenvW("HOME")) |home| home else error.HomeNotFound;
}

pub fn clutchHome(allocator: *Allocator) egg.BohioError![:0]const u16 {
    if (os.getenv("CLUTCH_HOME")) |clutch_home| {
        if (fs.path.isAbsolute(clutch_home)) {
            return clutch_home;
        }

        var buf: [fs.MAX_PATH_BYTES]u8 = undefined;
        if (os.getcwd(&buf)) |cwd| {
            return fs.path.joinWindows(allocator, &[_][]const u8{ cwd, clutch_home }) catch |_| {
                return egg.BohioError.ClutchHomeNotFound;
            };
        } else {
            return egg.BohioError.ClutchHomeNotFound;
        }
    }

    const home = try homeDir();
    return fs.path.joinWindows(allocator, &[_][]const u8{ home, ".clutch" }) catch |_| {
        return egg.BohioError.ClutchHomeNotFound;
    };
}
