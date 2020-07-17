const std = @import("std");
const Allocator = std.mem.Allocator;
const process = std.process;
const os = std.os;
const fs = std.fs;
const BohioError = @import("../lib.zig").BohioError;
const egg = @import("../lib.zig");

/// Caller needs to free memory
pub fn homeDir(allocator: *Allocator) egg.BohioError![]const u8 {
    return if (process.getEnvVarOwned(allocator, "USERPROFILE")) |home| @bitCast([]const u8, home) else |_| error.HomeNotFound;
}

/// Caller needs to free memory
pub fn clutchHome(allocator: *Allocator) egg.BohioError![]const u8 {
    if (process.getEnvVarOwned(allocator, "CLUTCH_HOME")) |clutch_home| {
        if (fs.path.isAbsolute(clutch_home)) {
            return clutch_home;
        }

        var buf: [fs.MAX_PATH_BYTES]u8 = undefined;
        if (os.getcwd(&buf)) |cwd| {
            return fs.path.joinWindows(allocator, &[_][]const u8{ cwd, clutch_home }) catch |_| {
                return egg.BohioError.ClutchHomeNotFound;
            };
        } else |_| {
            return egg.BohioError.ClutchHomeNotFound;
        }
    } else |_| {
        const home = try homeDir(allocator);
        return fs.path.joinWindows(allocator, &[_][]const u8{ home, ".clutch" }) catch |_| {
            return egg.BohioError.ClutchHomeNotFound;
        };
    }
}
