const std = @import("std");
const image_io = @import("image_io");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {

        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) @panic("Memory leak!!!");
        }

    const desired_channel: u8 = 1; //1 for grey_scale
    const img = try image_io.load_img(allocator, "test/eeprom.jpg", desired_channel);
    // std.debug.print("Img:{any} \n", .{img});


    // implement an image thats described by cos(2x+y)
    // (x,y) being the pixel coordinate


    
    // const img_width: u8 = 128;
    // const img_height: u8 = 128;
    // const img_data_len: usize = img_height * img_width;
    // const data = [_] u8 {0} ** img_data_len; //basically duplecating single value array 
                                             //to make a buffer for array 
    //
    // std.debug.print("{any}", .{data});






    try image_io.write_img(img, "test/written7.png");

    img.deinit();



}
