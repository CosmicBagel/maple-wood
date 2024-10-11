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
        .lpszClassName = win32.L("yeet"),
        .lpszMenuName = null,
    };

    _ = win32.RegisterClass(&windowClass);

    const hwnd = win32.CreateWindowEx(
        win32.WINDOW_EX_STYLE{},
        win32.L("yeet"),
        win32.L("yeet"),
        win32.WS_OVERLAPPEDWINDOW,

        // size and pos
        win32.CW_USEDEFAULT,
        win32.CW_USEDEFAULT,
        win32.CW_USEDEFAULT,
        win32.CW_USEDEFAULT,

        // more bs
        null,
        null,
        hInstance,
        null,
    );

    if (hwnd == null) {
        @panic("hwnd is null, fuck you");
    }

    _ = win32.ShowWindow(hwnd, win32.SHOW_WINDOW_CMD{ .SHOWNORMAL = 0 });

    print("\n\n{any}\n\n", .{windowClass});
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
