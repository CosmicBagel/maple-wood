const std = @import("std");

const gl = @import("zgl");

const WINAPI = @import("std").os.windows.WINAPI;
const zigwin32 = @import("zigwin32");
const win32 = struct {
    usingnamespace zigwin32.zig;
    usingnamespace zigwin32.foundation;
    usingnamespace zigwin32.ui.windows_and_messaging;
    usingnamespace zigwin32.system.library_loader;
    usingnamespace zigwin32.ui.input.keyboard_and_mouse;
};
const win32Error = win32.WIN32_ERROR;
// const windows = win32.ui.windows_and_messaging;
// have to declare this for zigwin32 as it checks the root module if UNICODE is defined
pub const UNICODE = true;

const print = std.debug.print;

const MyError = error{
    Win32Error,
};

// TODO: have this change between win32 and wayland based on compile target
pub fn main() !void {
    print("start\n", .{});
    try initWindows();
    // try initWayland();
    print("end\n", .{});
}

fn win32ErrorCheck(lastFunctionName: []const u8, chillErrors: anytype) !void {
    const ArgsType = @TypeOf(chillErrors);
    const args_type_info = @typeInfo(ArgsType);
    if (args_type_info != .Struct) {
        @compileError("expected tuple or struct argument, found " ++ @typeName(ArgsType));
    }

    const winErr = win32.GetLastError();
    if (winErr != win32Error.NO_ERROR) {
        inline for (chillErrors) |chillErr| {
            if (winErr == chillErr) {
                try win32ShowError(false, lastFunctionName, winErr);
                break;
            }
        } else {
            try win32ShowError(true, lastFunctionName, winErr);
            return MyError.Win32Error;
        }
        win32.SetLastError(win32.WIN32_ERROR.NO_ERROR);
    }
}

fn win32ShowError(showMessageBox: bool, lastFunctionName: []const u8, winErr: win32Error) !void {
    var buffer: [1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    const str = try std.fmt.allocPrint(
        allocator,
        "win32 error: {s} - {any} (0x{x:0>8})\n",
        .{ lastFunctionName, winErr, @intFromEnum(winErr) },
    );
    print("{s}", .{str});

    if (showMessageBox) {
        // windows api operates on utf-16 strings
        const utf16str = try std.unicode.utf8ToUtf16LeAllocZ(allocator, str);
        _ = win32.MessageBoxW(
            null,
            utf16str,
            win32.L("win32 error"),
            win32.MESSAGEBOX_STYLE{},
        );
    }
}

// basicly what the MAKEINTATOM macro from winbase.h does
pub fn make_into_atom(i: u16) ?[*:0]align(1) const u16 {
    return @ptrFromInt(@as(usize, i));
}

fn initWindows() !void {
    std.time.sleep(1 * std.time.ns_per_s);
    // sometimes there's just an error sitting there for some reason
    try win32ErrorCheck("initWindows - start", .{win32Error.ERROR_SXS_KEY_NOT_FOUND});

    const hInstance = win32.GetModuleHandleW(null);
    if (hInstance == null) {
        print("GetModuleHandleW returned null hInstance\n", .{});
    } else {
        print("GetModuleHandleW success!\n", .{});
    }
    try win32ErrorCheck("GetModuleHandleW", .{});

    // const hCursor = win32.LoadCursor(null, win32.IDC_ARROW);
    const windowClass = win32.WNDCLASSEXW{
        .style = win32.WNDCLASS_STYLES{},
        .lpfnWndProc = windowEventHandler,
        .lpszClassName = win32.L("yeet"),
        .lpszMenuName = null,
        .hInstance = hInstance,
        .hIcon = null,
        .hCursor = null,
        .hbrBackground = null,
        .hIconSm = null,
        .cbSize = @sizeOf(win32.WNDCLASSEX),
        .cbClsExtra = 0,
        .cbWndExtra = 0,
    };

    const windowClassId = win32.RegisterClassExW(&windowClass);
    try win32ErrorCheck("RegisterClassExW", .{});
    if (windowClassId == 0) {
        print("Failed to register window class\n", .{});
        return MyError.Win32Error;
    }
    print("Class registered!\n", .{});

    const hwnd = win32.CreateWindowExW(
        win32.WINDOW_EX_STYLE{},
        // win32.MAKEINTATOM
        make_into_atom(windowClassId),
        // win32.L("yeet"),
        win32.L("maple"),
        win32.WS_OVERLAPPEDWINDOW,
        // win32.WINDOW_STYLE{},

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
    try win32ErrorCheck("CreateWindowExW", .{win32Error.ERROR_INVALID_WINDOW_HANDLE});
    print("IsWindow: {any}\n", .{win32.IsWindow(hwnd) > 0});

    const showWindowResult = win32.ShowWindow(
        hwnd,
        win32.SHOW_WINDOW_CMD{ .SHOWNORMAL = 1 },
    );
    try win32ErrorCheck("ShowWindow", .{win32Error.ERROR_INVALID_WINDOW_HANDLE});
    print("showWindowResult: {d}\n", .{showWindowResult});

    print("\n\n{any}\n\n", .{windowClass});

    // TODO: why does it need this loop here :( need to be able to return for
    // initalization and move on to vulkan stuff
    var msg = win32.MSG{
        .hwnd = null,
        .lParam = 0,
        .wParam = 0,
        .time = 0,
        .pt = win32.POINT{ .x = 0, .y = 0 },
        .message = 0,
    };
    while (win32.GetMessageW(
        &msg,
        null,
        0,
        0,
    ) > 0) {
        try win32ErrorCheck("GetMessageW", .{
            win32Error.ERROR_INVALID_WINDOW_HANDLE,
            win32Error.ERROR_INVALID_PARAMETER,
        });
        _ = win32.TranslateMessage(&msg);
        try win32ErrorCheck("TranslateMessage", .{});
        _ = win32.DispatchMessage(&msg);
        try win32ErrorCheck("DispatchMessage", .{
            win32Error.ERROR_INVALID_WINDOW_HANDLE,
            win32Error.ERROR_ACCESS_DENIED,
        });
    }
}

fn windowEventHandler(hWnd: win32.HWND, uMsg: u32, wParam: win32.WPARAM, lParam: win32.LPARAM) callconv(WINAPI) win32.LRESULT {
    // _ = hWnd;
    // _ = wParam;
    // _ = lParam;

    if (win32.IsWindow(hWnd) == 0) {
        print("warning: window handle passed to windowEventHandler is invalid\n", .{});
    }

    win32ErrorCheck("windowEventHandler", .{
        win32Error.ERROR_ACCESS_DENIED,
        win32Error.ERROR_INVALID_WINDOW_HANDLE,
    }) catch {
        print("win32error\n", .{});
    };
    switch (uMsg) {
        win32.WM_DESTROY => {
            win32.PostQuitMessage(0);
            return 0;
        },
        win32.WM_KEYDOWN => {
            if (wParam == @intFromEnum(win32.VK_ESCAPE) or wParam == @intFromEnum(win32.VK_Q)) {
                win32.PostQuitMessage(0);
                return 0;
            }
        },
        else => {},
    }
    return win32.DefWindowProcW(hWnd, uMsg, wParam, lParam);
    // return uMsg;
}

fn initWayland() !void {
    // https://zig.news/leroycep/wayland-from-the-wire-part-1-12a1
    // https://zig.news/leroycep/wayland-from-the-wire-part-2-1gb7
    // get display path
    // send some packets to it to setup shared memory space
    // create window
    // create framebuffer in shared memory space
}
