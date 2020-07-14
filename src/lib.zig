const std = @import("std");
const builtin = @import("builtin");
const unix = @import("./os/unix.zig");
const windows = @import("./ps/windows.zig");

/// Get the home directory for the current user
/// in a platform-independent way.
pub fn homeDir() ?[]const u8 {
    switch (builtin.os.tag) {
        .windows => return windows.homeDir(),
        else => return unix.homeDir(),
    }
}

/// Get the clutch directory.
pub fn clutchHome() ?[]const u8 {
    switch (builtin.os.tag) {
        .windows => return windows.clutchHome(),
        else => return unix.clutchHome(),
    }
}

test "homeDir()" {
    if (homeDir()) |dir| {
        std.debug.print("Home directory = {}\n", .{homeDir()});
    } else {
        std.debug.print("Unable to get home directory\n", .{});
    }
}

test "clutchHome()" {
    if (clutchHome()) |clutch_home| {
        std.debug.print("Clutch Home directory = {}\n", .{clutch_home});
    } else {
        std.debug.print("Unable to get clutch home directory\n", .{});
    }
}
