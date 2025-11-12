//! doing the fun stuff!
const std = @import("std");
const core = @import("core");
const Image = core.Image;


/// This creates a jun grayscale image. The function  
/// takes a pointer to an Image struct and fills its pixel data with cosine (x^2 + y^2),
/// where x,y are normalized to 0 -- 2 * pi 

pub fn radial_cosine(image: *Image) void {

    const pi = std.math.pi;
    // const width_f = @as(f32, image.width);  //why these work but x_f = @as(f32, x) fail below?
    // const height_f = @as(f32, image.height);
    const width_f: f32 = @floatFromInt(image.width);  // Cast to f32 as @cos takes float inputs
    const height_f: f32 = @floatFromInt(image.height);

    var y: usize = 0;
    while (y < image.height) : (y += 1) { //outer loop for each row
        var x: usize = 0;
        while (x < image.width) : (x += 1) { //inner loop for each pixel
            
            //get x and y as f32 for trig
            const x_f: f32 = @floatFromInt(x);
            const y_f: f32 = @floatFromInt(y);


            //normalize to 0 - 2pi
            const norm_x = (x_f / width_f) * 2.0 * pi;
            const norm_y = (y_f / height_f) * 2.0 * pi;

            //scaling by 0.08 to keep val within ~ 2*pi
            //which gives ~ one cycle of cosine
            //try changing it to 0.8!
            const val: f32 = (norm_y * norm_y + norm_x * norm_x) * 0.08;  
            const pixel_val: f32 = @cos(val);
            //do negative pixel values make sense?
            //shift the output of cos upward by one and then normalize
            const pos_pixel_val = (pixel_val + 1) / 2; 
            //convert to 0-255 grayscale values
            const pixel_u8: u8 = @intFromFloat(pos_pixel_val * 255);

            // if ( pixel_u8 == 0  and y == 0) {
            //     std.debug.print(" ({any},{any}) : ({any},{any})\n", .{x, y, pixel_val, pixel_u8});
            //
            // }

            //calculate the 1D index and set the data
            const index = y * image.width + x;
            image.data[index] = pixel_u8;
        }
    }
}
