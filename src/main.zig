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
        //Scan each line and leave out duplicates
        var line_no: usize = 0;
        var duplicates: u16 = 1;
        var prev_line: ?[]u8 = try src_reader.interface.takeDelimiter('\n');
        if (prev_line == null) return;
        while (try src_reader.interface.takeDelimiter('\n')) |line| {
            line_no += 1;

            if (prev_line) |p_line| {
                const prevLine: []u8 = p_line;
                if (!std.mem.eql(u8, prevLine, line)) {
                    std.debug.print("{d: >5} |{d: >3}x| {s}\n", .{ line_no, duplicates, p_line });
                    duplicates = 1;
                } else {
                    duplicates += 1;
                }
            } else {
                return;
            }
            prev_line = line;
        }
    }
}
