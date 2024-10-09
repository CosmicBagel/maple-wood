const std = @import("std");

const win32 = @import("zigwin32");
const windows = win32.ui.windows_and_messaging;

const print = std.debug.print;
pub fn main() !void {
    initWayland();
}

fn initWindows() void {
    // const windowClass = windows.WNDCLASS{};
    // print("{any}", .{windowClass});
}

fn initWayland() void {
    // https://zig.news/leroycep/wayland-from-the-wire-part-1-12a1
    // https://zig.news/leroycep/wayland-from-the-wire-part-2-1gb7
    // get display path
    // send some packets to it to setup shared memory space
    // create window
    // create framebuffer in shared memory space
}
