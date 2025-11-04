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
        data: []u8,
        width: usize,
        height: usize,                
        channels: u8,
    ) Image {

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
        if (self.data.len != 0) {
            self.allocator.free(self.data);
        }
    }

};
