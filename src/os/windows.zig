const std = @import("std");
const Allocator = std.mem.Allocator;
const os = std.os;
const fs = std.fs;
const BohioError = @import("../lib.zig").BohioError;
const egg = @import("../lib.zig");

pub fn homeDir() egg.BohioError![]const u8 {
    return if (os.getenvW(@ptrCast([*:0]const u16, "HOME"))) |home| @bitCast([]const u8, home) else error.HomeNotFound;
}

pub fn clutchHome(allocator: *Allocator) egg.BohioError![]const u8 {
    if (os.getenvW(@ptrCast([*:0]const u16, "CLUTCH_HOME"))) |clutch_home| {
        const clutch_home_val = @bitCast([]const u8, clutch_home);
        if (fs.path.isAbsolute(clutch_home_val)) {
            return clutch_home_val;
        }

        var buf: [fs.MAX_PATH_BYTES]u8 = undefined;
        if (os.getcwd(&buf)) |cwd| {
            return fs.path.joinWindows(allocator, &[_][]const u8{ cwd, clutch_home_val }) catch |_| {
                return egg.BohioError.ClutchHomeNotFound;
            };
        } else |_| {
            return egg.BohioError.ClutchHomeNotFound;
        }
    }

    const home = try homeDir();
    return fs.path.joinWindows(allocator, &[_][]const u8{ home, ".clutch" }) catch |_| {
        return egg.BohioError.ClutchHomeNotFound;
    };
}
