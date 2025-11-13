//! tools for image manipulation

const std = @import("std");
const core = @import("core");
const Image = core.Image;

/// Takes an Image struct mirrors it vertically.
pub fn mirror_x(image: *Image) !void {
    //temporary buffer to store pixels during the swap
    //allocator must be used because pixel size is not comp-time
    const temp_pixel = try image.allocator.alloc(u8, image.channels);
    defer image.allocator.free(temp_pixel);

    var y: usize = 0;
    while (y < image.height): (y+=1) {

        var x: usize = 0;
        while (x < (image.width / 2) ): (x+=1)  {

            // horizontal swapping
            // x <-> w - x - 1 
            const pixel_right = try image.get_pixel( image.width - x - 1 , y);
            const pixel_left = try image.get_pixel(x,y);

            @memcpy(temp_pixel, pixel_right);

            try image.set_pixel(pixel_left, image.width - x - 1, y);
            try image.set_pixel(temp_pixel, x, y);
        }
    }

    //This is what I was attempting at first :D

            // // horizontal swapping
            // // x <-> w - x - 1 
            // const pixel_vals = try image.get_pixel( image.width - x - 1 , y);
            // const temp_pixel_vals = try image.get_pixel(x,y);
            // try image.set_pixel(pixel_vals, x, y);
            // try image.set_pixel(temp_pixel_vals, image.width - x - 1, y);
    //here, temp is not copying the pixel, its a slice. Hence, when I set (x,y), that pixel is gone
    //hence need a buffer to store the pixel separately
    //I AM STILL NOT USED TO ZIG SLICES, LOL

}
