const std = @import("std");

const WINAPI = @import("std").os.windows.WINAPI;
const zigwin32 = @import("zigwin32");
const win32 = struct {
    usingnamespace zigwin32.zig;
    usingnamespace zigwin32.foundation;
    usingnamespace zigwin32.ui.windows_and_messaging;
    usingnamespace zigwin32.system.library_loader;
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

fn initWindows() !void {
    // sometimes there's just an error sitting there for some reason
    try win32ErrorCheck("initWindows - start", .{win32Error.ERROR_SXS_KEY_NOT_FOUND});

    const hInstance = win32.GetModuleHandleW(null);
    if (hInstance == null) {
        print("GetModuleHandleW returned null hInstance\n", .{});
    }
    try win32ErrorCheck("GetModuleHandleW", .{});

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
        .cbSize = @sizeOf(win32.WNDCLASSEXW),
        .cbClsExtra = 0,
        .cbWndExtra = 0,
    };

    _ = win32.RegisterClassExW(&windowClass);
    try win32ErrorCheck("RegisterClassExW", .{});

    const hwnd = win32.CreateWindowExW(
        win32.WINDOW_EX_STYLE{},
        win32.L("yeet"),
        null,
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
        try win32ErrorCheck("GetMessageW", .{win32Error.ERROR_INVALID_WINDOW_HANDLE});
        _ = win32.TranslateMessage(&msg);
        try win32ErrorCheck("TranslateMessage", .{});
        _ = win32.DispatchMessage(&msg);
        try win32ErrorCheck("DispatchMessage", .{win32Error.ERROR_ACCESS_DENIED});
    }
}

fn windowEventHandler(hwnd: win32.HWND, uMsg: u32, wParam: win32.WPARAM, lParam: win32.LPARAM) callconv(WINAPI) win32.LRESULT {
    // this is hella spammy, so have it commented out for now
    // win32ErrorCheck("windowEventHandler", .{}) catch {
    //     print("win32error\n", .{});
    // };
    return win32.DefWindowProcW(hwnd, uMsg, wParam, lParam);
}

fn initWayland() !void {
    // https://zig.news/leroycep/wayland-from-the-wire-part-1-12a1
    // https://zig.news/leroycep/wayland-from-the-wire-part-2-1gb7
    // get display path
    // send some packets to it to setup shared memory space
    // create window
    // create framebuffer in shared memory space
}
