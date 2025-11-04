//! This the image loading library
//! It opens an image with stb library and parses the data to zig types  

const std = @import("std");
const core = @import("core");
const Image = core.Image;

//import stb header file for loading and writing image
const c = @cImport({
    @cInclude("stb/stb_image.h");
    @cInclude("stb/stb_image_write.h");
});


///function to load an image
pub fn load_img(allocator: std.mem.Allocator, image_path: [*c]const u8, desired_channels: u8 ) !Image {

    std.log.info("Loading image...\n", .{});

    var width: c_int = 0;
    var height: c_int = 0;
    var orig_channels: c_int = 0;
    // const desired_channels: c_int = 1;

    const data = c.stbi_load(
        image_path,
        &width,
        &height,
        &orig_channels,
        desired_channels,
    );

    // stbi_load returns null on failure
    if (data == null) {
        const stb_error_msg: [*c]const u8 = c.stbi_failure_reason(); 
        std.log.err("Loading failed: {s}", .{stb_error_msg});
        return error.ImageLoadFailed;
    }

    //free memory
    defer c.stbi_image_free(data);

    //figure out how many channels were loaded
    //if desired_channel is set to 0; stbi_load loads all channels available in the image
    const loaded_channels: u8 = if (desired_channels == 0) @intCast(orig_channels) else desired_channels;

    std.log.info("Image loaded successfully!\n", .{});
    std.log.info("  Width: {d}\n", .{width});
    std.log.info("  Height: {d}\n", .{height});
    std.log.info("  Image Channels: {d}\n", .{orig_channels});
    std.log.info("  Loaded Channels: {d}\n", .{loaded_channels});

    //converting data to slice
    std.log.info("Parsing Image...\n", .{});

    //convert c ints to zig usize
    const z_width: usize = @intCast(width);
    const z_height: usize = @intCast(height);
    const img_size: usize =  z_width * z_height * loaded_channels ; 

    //converting c array (data) to zig slice
    const img_data: []u8 = data[0..img_size];

    //allocating memory and saving the data in it for main
    const allocated_img_data = try allocator.alloc(u8, img_size);
    @memcpy(allocated_img_data, img_data);


    std.log.info("Parsed successfully!\n", .{});

    return Image {
        .data = allocated_img_data,
        .width = @intCast(width),
        .height = @intCast(height),
        .channels = @intCast(loaded_channels), 
        .allocator = allocator,
    };


}

///takes an Image struct object and a string literal image_path
///and writes a PNG image to the path with stbi_write_png
pub fn write_img(image: Image, path: [*c] const u8) !void {
    const width: c_int = @intCast(image.width);
    const height: c_int = @intCast(image.height);
    const channels: c_int = @intCast(image.channels);
    const stride_in_bytes = width * channels;
    const ptr_to_data = image.data.ptr;

    std.log.info("Writing image...\n", .{});
    const err =  c.stbi_write_png(path, width, height, channels, ptr_to_data, stride_in_bytes);
    if (err == 0) {
        return error.ImageWriteFailed;
    }
    std.log.info("Image written successfully to {s}\n", .{path});
}


