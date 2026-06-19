const std = @import("std");
const Io = std.Io;

const dedupe = @import("dedupe");

pub fn main(init: std.process.Init) !void {

    //get args
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    const argc = args.len;

    //check if args correct
    if (argc != 2) {
        std.debug.print("\n\x1b[0;31;1mERROR: Invalid count of arguments!\n\nUsage:\n       dedupe path/to/file\x1b[0m\n\n", .{});
    }

    //check file existens
    var found = true;
    std.Io.Dir.cwd().access(init.io, args[1], .{}) catch |e| switch (e) {
        error.FileNotFound => found = false,
        else => return e,
    };
    if (!found)
        std.debug.print("\n\x1b[0;31;1mERROR: Invalid path!\n\nUsage:\n       dedupe path/to/file\x1b[0m\n\n", .{});
}
