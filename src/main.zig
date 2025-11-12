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


    const desired_channel: u8 = 0; //1 for grey_scale
    const img = try image_io.load_img(allocator, "test/eeprom.jpg", desired_channel);
    defer img.deinit(); 

    try image_io.write_img(img, "test/final_cos^2y^2_cont_48.png");



}
