const std = @import("std");

const core = @import("core");
const toolbox = @import("toolbox");
const image_io = @import("image_io");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {

        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) @panic("Memory leak!!!");
        }


    const desired_channel: u8 = 0; //1 for grey_scale, 0 for all channels
    var img = try image_io.load_img(allocator, "test/char.jpg", desired_channel);
    defer img.deinit(); 

    const roi = core.Rect {
        .x = 0,
        .y = 0,
        .width = 20,
        .height = 32,
    };
    
    var img2 = try core.Image.init(allocator, roi.width, roi.height, img.channels);
    defer img2.deinit(); 

    try toolbox.crop(&img2, &img, roi);

    try toolbox.invert(&img2);


    try image_io.write_img(img2, "test/char_crop.jpg");



}
