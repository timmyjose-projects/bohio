const os = @import("std").os;

pub fn homeDir() ?[]const u8 {
    return os.getenv("HOME");
}

pub fn clutchHome() ?[]const u8 {
    return "TODO";
}
