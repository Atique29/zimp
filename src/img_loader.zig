//! This the image loading library
//! It opens an image with stb library and parses the data in zig types 
const std = @import("std");

const c = @cImport({
    @cInclude("stb/stb_image.h");
});

pub fn load_img(image_path: [*c]const u8, desired_channels: u8 ) ![]u8 {

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;
    try stdout.print("Loading image...\n", .{});
    try stdout.flush();


    var width: c_int = 0;
    var height: c_int = 0;
    var channels: c_int = 0;
    // const desired_channels: c_int = 1;

    const data = c.stbi_load(
        image_path,
        &width,
        &height,
        &channels,
        desired_channels,
    );

    // stbi_load returns null on failure
    if (data == null) {
        // const reason = c.stbi_failure_reason();
        // try stdout.print("Failed to load image: {s}\n", .{reason});
        // try stdout.flush();
        // return;
        @panic("Load failed");
    }

    //free memory
    defer c.stbi_image_free(data);

    try stdout.print("Image loaded successfully!\n", .{});
    try stdout.print("  Width: {d}\n", .{width});
    try stdout.print("  Height: {d}\n", .{height});
    try stdout.print("  Channels: {d}\n", .{channels});
    try stdout.print("data type: {any}\n", .{@TypeOf(data)});
    try stdout.flush();

    //converting data to slice
    try stdout.print("Parsing Image...\n", .{});
    try stdout.flush();
    const img_size: usize = @intCast( width * height * desired_channels );
    const img_data: []u8 = data[0..img_size];
    try stdout.print("All Done!\n", .{});
    try stdout.flush();

    return img_data;


}






































