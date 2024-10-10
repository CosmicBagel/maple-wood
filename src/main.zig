const std = @import("std");

const WINAPI = @import("std").os.windows.WINAPI;
const zigwin32 = @import("zigwin32");
const win32 = struct {
    usingnamespace zigwin32.zig;
    usingnamespace zigwin32.foundation;
    usingnamespace zigwin32.ui.windows_and_messaging;
    usingnamespace zigwin32.system.library_loader;
};
// const windows = win32.ui.windows_and_messaging;
// have to declare this for zigwin32 as it checks the root module if UNICODE is defined
pub const UNICODE = true;

const print = std.debug.print;
pub fn main() !void {
    // initWayland();
    initWindows();
}

fn initWindows() void {
    //win32.foundation.HINSTANCE this type
    // win32.system.library_loader.GetModuleHandle(lpModuleName: ?[*:0]const u8)
    // win32.system.library_loader.GetModuleHandle(lpModuleName: ?[*:0]const u16)
    const hInstance = win32.GetModuleHandle(null);
    const windowClass = win32.WNDCLASS{
        .style = win32.WNDCLASS_STYLES{},
        .lpfnWndProc = windowEventHandler,
        .hInstance = hInstance,
        .cbClsExtra = 0,
        .cbWndExtra = 0,
        .hIcon = win32.LoadIconW(null, win32.IDI_APPLICATION),
        .hCursor = win32.LoadCursorW(null, win32.IDC_ARROW),
        .hbrBackground = null,
        .lpszMenuName = win32.L("yeet"),
        .lpszClassName = null,
    };
    // windows.CreateWindowEx(dwExStyle: WINDOW_EX_STYLE, lpClassName: ?[*:0]align(1)const u8, lpWindowName: ?[*:0]const u8, dwStyle: WINDOW_STYLE, X: i32, Y: i32, nWidth: i32, nHeight: i32, hWndParent: ?HWND, hMenu: ?HMENU, hInstance: ?HINSTANCE, lpParam: ?*anyopaque)
    print("{any}", .{windowClass});
}

fn windowEventHandler(_: win32.HWND, _: u32, _: win32.WPARAM, _: win32.LPARAM) callconv(WINAPI) win32.LRESULT {
    return 0;
}

fn initWayland() void {
    // https://zig.news/leroycep/wayland-from-the-wire-part-1-12a1
    // https://zig.news/leroycep/wayland-from-the-wire-part-2-1gb7
    // get display path
    // send some packets to it to setup shared memory space
    // create window
    // create framebuffer in shared memory space
}
