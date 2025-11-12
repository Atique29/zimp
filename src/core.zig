//! This module provides image struct, error values for the library

const std = @import("std");

//IMPLEMENT ERRORS!!


/// image data struct
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
        // 1. calling init() should completely setup the image object
        // 2. if allocation for data is done else where (e.g, main),
        //    free() would have to be called explicitly there.
        //    Then, if I call deinit(), i am calling free on data
        //    thats already been freed, leading to error
        const data = try allocator.alloc(u8, width * height * channels);
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

};
