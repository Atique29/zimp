//! Tools for image manipulation

const std = @import("std");
const core = @import("core");
const Image = core.Image;
const Rect = core.Rect;

//I dont have to check the validity of Image in these functions first
//because if the creation of it was invalid, zig would have raised errors
//right??

/// Takes an Image struct mirrors it vertically
pub fn mirror_x(image: *Image) !void {
    //temporary buffer to store pixels during the swap
    //allocator must be used because pixel size is not comp-time
    const temp_pixel: []u8 = try image.allocator.alloc(u8, image.channels);
    defer image.allocator.free(temp_pixel);

    var y: usize = 0;
    while (y < image.height): (y+=1) {

        var x: usize = 0;
        while (x < (image.width / 2) ): (x+=1)  {

            // horizontal swapping
            // x <-> w - x - 1 
            const pixel_right: []u8 = try image.get_pixel( image.width - x - 1 , y);
            const pixel_left: []u8 = try image.get_pixel(x,y);

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


/// Takes an Image struct mirrors it horizontally
pub fn mirror_y(image: *Image) !void {
    //temporary buffer to store pixels during the swap
    //allocator must be used because pixel size is not comp-time
    const temp_pixel: [] u8 = try image.allocator.alloc(u8, image.channels);
    defer image.allocator.free(temp_pixel);

    var x: usize = 0;
    while (x < image.height): (x+=1) {

        var y: usize = 0;
        while (y < (image.height / 2) ): (y+=1)  {

            // vertical swapping
            // y <-> w - y - 1 
            const pixel_bottom: []u8 = try image.get_pixel( x, image.height - y - 1);
            const pixel_top: []u8 = try image.get_pixel(x,y);

            @memcpy(temp_pixel, pixel_bottom);

            try image.set_pixel(pixel_top, x, image.width - y - 1);
            try image.set_pixel(temp_pixel, x, y);
        }
    }
}


/// Takes an Image struct mirrors it both horizontally and vertically
pub fn mirror_xy(image: *Image) !void {
    //temporary buffer to store pixels during the swap
    //allocator must be used because pixel size is not comp-time
    const temp_pixel: []u8 = try image.allocator.alloc(u8, image.channels);
    defer image.allocator.free(temp_pixel);

    var x: usize = 0;
    while (x < image.height): (x+=1) {

        var y: usize = 0;
        while (y < (image.height / 2) ): (y+=1)  { // iterating over the upper half

            // x <-> w - x - 1 
            // y <-> w - y - 1 
            const pixel_bottom: []u8 = try image.get_pixel( 
                image.width - x - 1,
                image.height - y - 1
            );
            const pixel_top: []u8 = try image.get_pixel(x,y);

            @memcpy(temp_pixel, pixel_bottom);

            try image.set_pixel(pixel_top, image.width - x - 1, image.width - y - 1);
            try image.set_pixel(temp_pixel, x, y);
        }
    }
}


///Takes an Image struct and inverts the pixels
pub fn invert(image: *Image) !void {

    //loop through all pixels and invert them
    var y: usize = 0;

    while (y < image.height): (y+=1) {

        var x: usize = 0;
        while (x < (image.width) ): (x+=1)  {

            //this slice directly points to the pixel in image.data
            //so we can just iterate over its pointer to modify the pixel
            const pixel_val: []u8 = try image.get_pixel(x, y);
            for (pixel_val) |*val| {
                val.* = 255 - val.*;
            }
        }
    }
}


/// Takes an Image and a Region of Interest (ROI) Rect struct,
/// crops the image according to the ROI
pub fn crop(dest_image: *Image, src_image: *Image, roi: Rect) !void {
    // this function needs a dest_image parameter unlike the ones above
    // due to the allocated memory for src_image 
    
    //check if roi is within bounds
    if ((roi.x + roi.width > src_image.width) or (roi.y + roi.height > src_image.height)) {
        std.log.err("crop: Region of Interest (ROI) for cropping is out of bounds", .{});
        return error.OutOfBoundsROI;
    }

    //check if the roi size matches the size of dest_image
    if ((roi.width != dest_image.width) or (roi.height != dest_image.height)) {
        std.log.err("crop: The size of Region of Interest (ROI) is not equal to the " ++
        "size of destination image", .{});
        return error.DestImageNotEqualROI;
    }

    //check if the channel size of src image matches that of dest image
    if (src_image.channels != dest_image.channels) {
        std.log.err("crop: source image and destination image have different #channels", .{});
        return error.ImageChannelsNotEqual;
    }

    //copy the ROI pixels from src to dest 
    var y: usize = 0;
    while (y < roi.height): (y+=1) {
        var x: usize = 0;
        while (x < roi.width): (x+=1) {

            //get the pixel from src image
            const src_pixel_val: []u8 = try src_image.get_pixel(roi.x + x, roi.y + y);
            
            //set the pixel in dest image
            try dest_image.set_pixel(src_pixel_val, x, y);

        }
    }
}
























