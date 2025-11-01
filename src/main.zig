const std = @import("std");
const imgz = @import("img_loader");

pub fn main() !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    const desired_channel: u8 = 1; //grey_scale
    const img_data = try imgz.load_img("src/stb/char.jpg", desired_channel);

    for (img_data) |pixel_val| {
        try stdout.print("{d} ", .{pixel_val});
    }

    try stdout.print("\n", .{});
    try stdout.flush();


}
