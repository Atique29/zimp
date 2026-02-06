//! This module provides image struct, error values for the library

const std = @import("std");

//IMPLEMENT ERRORS!!

/// Region of Interest (ROI) struct 
pub const Rect = struct {
     x: usize,
     y: usize,
     width: usize,
     height: usize,
};

/// Image data struct
pub const Image = struct {
    allocator: std.mem.Allocator,
    data: []u8,
    width: usize,
    height: usize,
    channels: u8,  // when writing back an image that was just loaded this
                   // channel is the desired_channels arg that was passed to stbi_load

    pub fn init( 
        allocator: std.mem.Allocator,
        // data: []u8,
        width: usize,
        height: usize,                
        channels: u8,
    ) !Image {
        //make allocation part of the init process
        //this make sense because:
        // 1. calling Image.init() should completely setup the image object
        // 2. if allocation for data is done else where (e.g, main),
        //    free() would have to be called explicitly there.
        //    Then, if I call Image.deinit(), i am calling free on data
        //    thats already been freed, leading to error
        const data: []u8 = try allocator.alloc(u8, width * height * channels);
        @memset(data, 0); //initiate the image with 0's
        return Image {
                .allocator = allocator,
                .data = data,
                .width = width,
                .height = height,
                .channels = channels,
        };
    }
            
    
    /// frees image data from heap
    pub fn deinit(self: Image) void{
        // if (self.data.len != 0) {
        self.allocator.free(self.data);
        // }
    }

    /// Get pixel information at (x,y).
    /// Takes (x,y) and returns a slice containing the pixel or null if x or y 
    ///out of bounds.
    /// The slice points to the pixel at (x,y) in self.data
    pub fn get_pixel(self: Image, x: usize, y: usize) ?[]u8 {

        //for RGB, a pixel is a set of 3 values
        //for RGBA, its a set of four values
        //so we need to account for the number of channels 
        //in order to find the right pixel in self.data
        //which is a one dimensional representation of data
        
        //if out of bounds, return null
        if (x >= self.width or y >= self.height) {
            return null;
        }

        const pixel_start: usize = ((y * self.width) + x) * self.channels ;  
        //not subtracting 1 because slice indexing is exclusive 
        const pixel_end: usize = pixel_start + self.channels;
        return self.data[pixel_start..pixel_end];

    } 

    /// Set pixel at (x,y).
    /// Takes a slice and a coordinate.
    /// Writes the contents pointed by the slice to self.data
    /// at the given coordinates.
    pub fn set_pixel(self: *Image, pixel_vals: []const u8, x: usize, y: usize) !void {
        // self: *Image, not Image, because this methods gonna modify the data field
        // of self. So we pass self as reference, explicitly. Dropping * does work
        // here tho, owing to data being a slice.

        //check that the boundaries are respected
        if (x >= self.width or y >= self.height) {
            std.log.err("get_pixel: Cant write to pixel at ({d},{d})," ++
            " the coordinates are out of bounds. The final pixel of the image is at ({d}, {d}) ",
            .{x, y, self.width - 1, self.height - 1 });
            return error.GetPixelOutOfBounds;
        }

        //check that pixel_vals contains the values for each channel
        if (pixel_vals.len != self.channels) {
            std.log.err("set_pixel: Input data length ({d}) does not match image channels ({d})", .{
                pixel_vals.len, self.channels,
            });
            return error.PixelLengthMismatch;
        }

        const pixel_start: usize = ((y * self.width) + x) * self.channels ;  
        const pixel_end: usize = pixel_start + self.channels;

        const dest_slice = self.data[pixel_start..pixel_end];
        //using @memmove instead of @memcpy because it seems
        //more general to do so. Some tools may require src and
        //dest to overlap
        @memmove(dest_slice, pixel_vals);

    }

};















