const std = @import("std");

const win32 = @import("zigwin32");
const windows = win32.ui.windows_and_messaging;
// have to declare this for zigwin32 as it checks the root module if UNICODE is defined
pub const UNICODE = true;

const print = std.debug.print;
pub fn main() !void {
    // initWayland();
    initWindows();
}

fn initWindows() void {

    //win32.foundation.HINSTANCE this type
    const hInstance = GetModuleHandle(null);
    // win32.
    const windowClass = windows.WNDCLASS{
        .style = windows.WNDCLASS_STYLES{},
        .lpfnWndProc = functionPointerToWindowProc,
    };
    // windows.CreateWindowEx(dwExStyle: WINDOW_EX_STYLE, lpClassName: ?[*:0]align(1)const u8, lpWindowName: ?[*:0]const u8, dwStyle: WINDOW_STYLE, X: i32, Y: i32, nWidth: i32, nHeight: i32, hWndParent: ?HWND, hMenu: ?HMENU, hInstance: ?HINSTANCE, lpParam: ?*anyopaque)
    print("{any}", .{windowClass});
}

fn initWayland() void {
    // https://zig.news/leroycep/wayland-from-the-wire-part-1-12a1
    // https://zig.news/leroycep/wayland-from-the-wire-part-2-1gb7
    // get display path
    // send some packets to it to setup shared memory space
    // create window
    // create framebuffer in shared memory space
}
