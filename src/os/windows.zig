const os = @import("std").os;

pub fn homeDir() ?[:0]const u16 {
    return os.getenvW("HOME");
}

pub fn clutchHome() ?[:0]const u16 {
    return "TODO";
}
