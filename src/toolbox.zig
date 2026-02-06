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
            const pixel_right: []u8 = image.get_pixel( image.width - x - 1 , y).?;
            const pixel_left: []u8 = image.get_pixel(x,y).?;

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
            const pixel_bottom: []u8 = image.get_pixel( x, image.height - y - 1).?;
            const pixel_top: []u8 = image.get_pixel(x,y).?;

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
            const pixel_bottom: []u8 = image.get_pixel( 
                image.width - x - 1,
                image.height - y - 1
            ).?;
            const pixel_top: []u8 = image.get_pixel(x,y).?;

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
            const pixel_val: []u8 = image.get_pixel(x, y).?;
            for (pixel_val) |*val| {
                val.* = 255 - val.*;
            }
        }
    }
}


/// Takes source, destination Image structs and a Region of Interest (ROI) Rect struct,
/// crops the image according to the ROI
pub fn crop(dest_image: *Image, src_image: *Image, roi: Rect) !void {
    // this function needs a dest_image parameter unlike the ones above
    // cuz i am not sure about changing the width and height of source image
    // if i did that, what about the memory allocated for the src image? its larger than 
    // the memory required for the cropped image. Seems wasteful
    
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
    //here y = 0 is the first row of dest_image
    //copy one row of ROI at a time
    var y: usize = 0;
    while (y < roi.height): (y+=1) {

        //get the index of the start and end pixel of the ROI row in src_image.data
        const src_y: usize = y + roi.y;
        const src_start_index: usize = (src_y * src_image.width + roi.x) * src_image.channels;
        const src_end_index: usize = src_start_index + roi.width * src_image.channels;
        const row_data: [] u8 = src_image.data[src_start_index..src_end_index];

        //get the index of the start and end pixel of the ROI row in dest_image.data
        //start with the first element of each row (x = 0)
        const dest_start_index: usize = (y * dest_image.width) * dest_image.channels; 
        const dest_end_index:  usize = dest_start_index + dest_image.width * dest_image.channels;
        //copy the data
        @memcpy(dest_image.data[dest_start_index..dest_end_index], row_data);

    }
}

///Takes an Image struct and copies the content
pub fn copy(dest_image: *Image, src_image: *Image) !void {
    //use crop to copy 
    //ROI is the whole src_image
    try crop(dest_image, src_image, .{
        .x = 0,
        .y = 0,
        .width = src_image.width,
        .height = src_image.height,
    });
}

/// Takes an RGB source image and converts to grayscale
pub fn rgb2gray(src_image: *Image, dest_image: *Image)!void {
    
    //check that properties of src_image are correct
    if (src_image.channels < 3){
        std.log.err("rgb2gray: Number of channels of the source image must be " ++
        "greated than 3. Given image has {d} channels.", .{src_image.channels});
    }
    //check that properties of dest_image are correct
    if (dest_image.channels != 1){
        std.log.err("rgb2gray: Number of channels of the destination image is " ++
        "{d} instead of being 1", .{dest_image.channels});
        return error.DestChannelError;
    }

    if (dest_image.width != src_image.width){
        std.log.err("rgb2gray: Width of the destination image ({d}) doesn't " ++
        "match the width of source image ({d})", .{dest_image.width, src_image.width});
        return error.DestWidthError;
    }

    if (dest_image.height != src_image.height){
        std.log.err("rgb2gray: Height of the destination image ({d}) doesn't " ++
        "match the height of source image ({d})", .{dest_image.height, src_image.height});
        return error.DestWidthError;
    }

    var y: usize = 0;
    while (y < src_image.height): (y+=1) {
        var x: usize = 0;
        while (x < src_image.width): (x+=1) {

            const pixel_val: []u8 = src_image.get_pixel(x, y).?;

            //formula for conversion: ITU-R BT.709 : 0.2126 * R + 0.7152 * G + 0.0722 * B
            const grayscale_pixel_val: f32 = 0.2126 * @as(f32, @floatFromInt(pixel_val[0])) + 
                                            0.7152 * @as(f32, @floatFromInt(pixel_val[1])) +
                                            0.0722 * @as(f32, @floatFromInt(pixel_val[2]));

            const grayscale_pixel_val_u8 = @as(u8, @intFromFloat(grayscale_pixel_val));

            // wrap this single value with in an array 
            // so that zig can coerce it into a slice for the set_pixel function 
            // when a pointer of the array is passed (with &)
        
            const grayscale_pixel_val_u8_array = [_]u8 {grayscale_pixel_val_u8};

            try dest_image.set_pixel(&grayscale_pixel_val_u8_array, x, y);


        }
    }






    


}





