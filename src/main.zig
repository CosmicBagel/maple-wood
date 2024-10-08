const std = @import("std");

const win32 = @import("zigwin32");
const windows = win32.ui.windows_and_messaging;

const print = std.debug.print;
pub fn main() !void {
    const windowClass = windows.WNDCLASS{};
    print("{any}", .{windowClass});
}
