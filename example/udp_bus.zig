// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

const std = @import("std");
const py = @import("pydust");

const root = @This();

/// A minimalist UDP communication bus for Python
pub const UdpBus = py.class(struct {
    const Self = @This();
    
    pub const __doc__ = "A UDP socket communication bus";
    
    socket: std.posix.socket_t,
    address: std.net.Address,
    
    pub fn __init__(self: *Self, args: struct { host: []const u8, port: u16 }) !void {
        // Parse the address
        self.address = try std.net.Address.parseIp(args.host, args.port);
        
        // Create UDP socket
        self.socket = try std.posix.socket(
            self.address.any.family,
            std.posix.SOCK.DGRAM,
            std.posix.IPPROTO.UDP,
        );
    }
    
    pub fn __del__(self: *Self) void {
        std.posix.close(self.socket);
    }
    
    /// Bind the socket to the configured address
    pub fn bind(self: *Self) !void {
        try std.posix.bind(self.socket, &self.address.any, self.address.getOsSockLen());
    }
    
    /// Set receive timeout in seconds
    pub fn set_recv_timeout(self: *Self, args: struct { seconds: u32 }) !void {
        const timeout = std.posix.timeval{
            .sec = @intCast(args.seconds),
            .usec = 0,
        };
        try std.posix.setsockopt(
            self.socket,
            std.posix.SOL.SOCKET,
            std.posix.SO.RCVTIMEO,
            std.mem.asBytes(&timeout),
        );
    }
    
    /// Send data to a specified address
    pub fn send_to(self: *Self, args: struct { data: []const u8, host: []const u8, port: u16 }) !usize {
        const dest_addr = try std.net.Address.parseIp(args.host, args.port);
        const sent = try std.posix.sendto(
            self.socket,
            args.data,
            0,
            &dest_addr.any,
            dest_addr.getOsSockLen(),
        );
        return sent;
    }
    
    /// Receive data from the socket (blocking)
    pub fn recv(self: *Self, args: struct { buffer_size: u32 = 1024 }) !py.PyBytes {
        const buffer = try py.allocator.alloc(u8, args.buffer_size);
        defer py.allocator.free(buffer);
        
        const received = try std.posix.recv(self.socket, buffer, 0);
        return py.PyBytes.create(buffer[0..received]);
    }
    
    /// Receive data and sender address from the socket (blocking)
    pub fn recv_from(self: *Self, args: struct { buffer_size: u32 = 1024 }) !struct { data: py.PyBytes, host: py.PyString, port: u16 } {
        const buffer = try py.allocator.alloc(u8, args.buffer_size);
        defer py.allocator.free(buffer);
        
        var src_addr: std.posix.sockaddr = undefined;
        var src_addr_len: std.posix.socklen_t = @sizeOf(std.posix.sockaddr);
        
        const received = try std.posix.recvfrom(
            self.socket,
            buffer,
            0,
            &src_addr,
            &src_addr_len,
        );
        
        const addr = std.net.Address.initPosix(@alignCast(&src_addr));
        
        // Format IP address properly - extract octets from the address
        const ip_int = addr.in.sa.addr;
        const a = @as(u8, @truncate(ip_int & 0xFF));
        const b = @as(u8, @truncate((ip_int >> 8) & 0xFF));
        const c = @as(u8, @truncate((ip_int >> 16) & 0xFF));
        const d = @as(u8, @truncate((ip_int >> 24) & 0xFF));
        
        var ip_buf: [16]u8 = undefined;
        const ip_str = try std.fmt.bufPrint(&ip_buf, "{d}.{d}.{d}.{d}", .{a, b, c, d});
        
        return .{
            .data = try py.PyBytes.create(buffer[0..received]),
            .host = try py.PyString.create(ip_str),
            .port = addr.getPort(),
        };
    }
});

comptime {
    py.rootmodule(root);
}
