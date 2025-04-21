const builtin = @import("builtin");
const std = @import("std");
const c = std.c;
const linux = std.os.linux;

pub const LinuxSplice = struct {
    pub const can_use: bool = builtin.os.tag == .linux;

    pub fn splice(
        fd_in: c.fd_t,
        off_in: ?*i64,
        fd_out: c.fd_t,
        off_out: ?*i64,
        len: usize,
        flags: usize,
    ) !usize {
        if (!can_use) return error.UnsupportedPlatform;
        const rc = linux.syscall6(
            .splice,
            @as(usize, @intCast(fd_in)),
            @as(usize, @intFromPtr(off_in)),
            @as(usize, @intCast(fd_out)),
            @as(usize, @intFromPtr(off_out)),
            len,
            flags,
        );

        return switch (linux.E.init(rc)) {
            .SUCCESS => rc,
            .AGAIN => error.again,
            .INVAL => error.invalid_splice,
            .SPIPE => error.bad_fd_offset,
            .BADF => error.bad_file_descriptors,
            .NOMEM => error.SystemResources,
            else => |err| std.posix.unexpectedErrno(err),
        };
    }
};
