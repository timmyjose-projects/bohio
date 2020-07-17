const std = @import("std");
const process = std.process;
const os = std.os;
const fs = std.fs;
const Allocator = std.mem.Allocator;
const builtin = @import("builtin");
const posix = @import("./os/posix.zig");
const windows = @import("./os/windows.zig");

pub const BohioError = error{
    CouldNotGetCurrentWorkingDirectory,
    HomeNotFound,
    ClutchHomeNotFound,
};

/// Get the home directory for the current user in a platform-independent way.
/// Returns the path of the current user's home directory if known.
///
/// # Unix
///
/// Returns the value of the `HOME` environment variable
///
/// # Windows
///
/// Returns the value of the `USERPROFILE` environment variable
///
/// # Errors
///
///  BohioError
///
pub fn homeDir(allocator: *Allocator) ?[]const u8 {
    switch (builtin.os.tag) {
        .windows => return windows.homeDir(allocator) catch null,
        else => return posix.homeDir(allocator) catch null,
    }
}

/// Get the clutch directory, using the following heuristics:
///
/// - The value of the `CLUTCH_HOME` environment variable, if it is
///   an absolute path.
/// - The value of the current working directory joined with the value
///   of the `CLUTCH_HOME` environment variable, if `CLUTCH_HOME` is a
///   relative directory.
/// - The `.clutch` directory in the user's home directory, as reported
///   by the `homeDir` function.
///
/// # Errors
///
///  BohioError
///
pub fn clutchHome(allocator: *Allocator) ?[]const u8 {
    switch (builtin.os.tag) {
        .windows => return windows.clutchHome(allocator) catch null,
        else => return posix.clutchHome(allocator) catch null,
    }
}

test "homeDir()" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = &arena.allocator;

    const home = homeDir(allocator) orelse "N/A";
    defer allocator.free(home);
    std.debug.print("Home directory = {}\n", .{home});
}

test "clutchHome()" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = &arena.allocator;

    const clutch_home = clutchHome(allocator) orelse "N/A";
    defer allocator.free(clutch_home);
    std.debug.print("Clutch Home directory = {}\n", .{clutch_home});
}
