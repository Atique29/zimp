const std = @import("std");

const core = @import("core");
const fun = @import("fun");
const image_io = @import("image_io");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {

        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) @panic("Memory leak!!!");
        }

    // var progress = std.Progress{};

    //
    // const desired_channel: u8 = 1; //1 for grey_scale
    // const img = try image_io.load_img(allocator, "test/eeprom.jpg", desired_channel);
    // defer img.deinit(); 
    // std.debug.print("Img:{any} \n", .{img});


    // implement an image thats described by cos(2x+y)
    // (x,y) being the pixel coordinate

    const img_width: usize = 64;
    const img_height: usize = 64;
    const img_data_len: usize = img_height * img_width;

    const data = try allocator.alloc(u8, img_data_len); 
    defer allocator.free(data);
    var img = core.Image.init(allocator, data, img_width, img_height, 1);
    defer img.deinit();
    

    try fun.radial_cosine(&img);

    try image_io.write_img(img, "test/final_cos^2y^2_cont_48.png");




}
