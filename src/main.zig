const std = @import("std");
const net = std.net;
const io = std.io;
const posix = std.posix;

pub fn main() !void {
    // const allocator = std.heap.page_allocator;
    const address = try net.Address.parseIp4("127.0.0.1", 8080);
    const listener = try posix.socket(posix.AF.INET, posix.SOCK.STREAM, 0);
    defer posix.close(listener);

    const reuse = @as(c_int, 1);
    try posix.setsockopt(listener, posix.SOL.SOCKET, posix.SO.REUSEADDR, &std.mem.toBytes(reuse));

    try posix.bind(listener, &address.any, address.getOsSockLen());

    try posix.listen(listener, 128);
    std.debug.print("Server running at http://{s}:{}\n", .{ "localhost", address.getPort() });

    while (true) {
        var client_addr: std.net.Address = undefined;
        var client_addr_len: posix.socklen_t = @sizeOf(std.net.Address);

        const conn = try posix.accept(listener, &client_addr.any, &client_addr_len, 0);
        defer posix.close(conn);

        std.debug.print("{}\n", .{client_addr.getPort()});

        // Handle request
        const response =
            "HTTP/1.1 200 OK\r\n" ++
            "Content-Type: text/plain\r\n" ++
            "Content-Length: 15\r\n\r\n" ++
            "Hello Zig 0.15!";

        _ = try posix.send(conn, response, 0);
    }
}
