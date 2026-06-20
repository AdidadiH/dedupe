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
    {
        var found = true;
        std.Io.Dir.cwd().access(init.io, args[1], .{}) catch |e| switch (e) {
            error.FileNotFound => found = false,
            else => return,
        };
        if (!found) {
            std.debug.print("\n\x1b[0;31;1mERROR: Invalid path!\n\nUsage:\n       dedupe path/to/file\x1b[0m\n\n", .{});
            return;
        }
    }
    const srcPath = args[1];

    //read in source file
    const srcFile = try std.Io.Dir.cwd().openFile(init.io, srcPath, .{});
    defer srcFile.close(init.io);

    var src_file_buffer: [4096]u8 = undefined;
    var src_reader = srcFile.reader(init.io, &src_file_buffer);

    {
        //NOTE: temporary, only for testing that it works
        var line_no: usize = 0;
        while (try src_reader.interface.takeDelimiter('\n')) |line| {
            line_no += 1;
            std.debug.print("{d}--{s}\n", .{ line_no, line });
        }
    }
}
