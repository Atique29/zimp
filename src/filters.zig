//! filters
const std = @import("std");
const core = @import("core");

const Image = core.Image;

/// Struct to represent filter kernels
pub const Kernel = struct {
    width: usize,
    height: usize,  
    data: []const f32,
    allocator: std.mem.Allocator, 

    pub fn deinit(self: Kernel) void {
        self.allocator.free(self.data);
    }
};


/// Box Blur Kernel of size MxN
pub fn create_box_kernel(allocator: std.mem.Allocator, m: usize, n: usize) !Kernel{
    const size: usize = m * n;
    const data: []f32 = try allocator.alloc(f32, size);
    const val: f32 = 1 / @as(f16, @floatFromInt(size));
    @memset(data, val);
    return .{
        .width = m,
        .height = n, 
        .data = data,
        .allocator = allocator,
    };
}

pub fn create_gaussian_kernel(allocator: std.mem.Allocator, sigma: f32) !Kernel{
    var size: usize = @intFromFloat(@ceil(6 * sigma + 1));
    if (size % 2 == 0) {size+=1;}
    const data: []f32 = try allocator.alloc(f32, size * size);

    const m = @as(f32, @floatFromInt((size - 1) / 2));
    var normalizer_sum: f32 = 0;

    var j: usize = 0; 
    while (j < size) : (j += 1) {
        const y = @as(f32, @floatFromInt(j)) - m; 
        var i: usize = 0; 
        while (i < size) : (i += 1) {
            const x = @as(f32, @floatFromInt(i)) - m;
            const exponent = -(x * x + y * y) / (2 * sigma * sigma);
            const weight = @exp(exponent);
            data[j * size + i] = weight;
            normalizer_sum += weight;
        }
    }

    for (data) |*val| {
        val.* = val.* / normalizer_sum;
    }
    return .{
        .width = size,
        .height =size, 
        .data = data,
        .allocator = allocator,
    };
}


// pub fn linear_spatial_filter_separable(image: *Image, kernel: Kernel) !void {
//
// }







///Convolution of the image and linear filter, naive implementation.
/// Meaning it doesnt use separability
pub fn linear_spatial_filter_naive(image: Image, kernel: Kernel) !Image{

    const result_buffer: [] u8 = try image.allocator.alloc(u8, image.width*image.height*image.channels);
    // defer image.allocator.free(result_buffer);

    const weighted_sum: [] f32 = try image.allocator.alloc(f32, image.channels);
    defer image.allocator.free(weighted_sum);

    const kernel_x_offset = @as(i64, @intCast((kernel.width - 1)/2)); 
    const kernel_y_offset = @as(i64, @intCast((kernel.height - 1)/2)); 
    const img_height_i64: i64 = @intCast(image.height);
    const img_width_i64: i64 = @intCast(image.width);
    //iterate over the pixels & kernel to find the weighted sum per channel
    var y: usize = 0;
    while (y < image.height): (y+=1) {
        var x: usize = 0;
        while (x < image.width): (x+=1)  {

            //initialize sums with 0 
            @memset(weighted_sum, 0);
            // const center_pixel: []u8 = image.get_pixel(@intCast(x),@intCast(y)).?;

            var j: usize = 0;
            while (j < kernel.height): (j+=1) {
                var i: usize = 0;
                while (i < kernel.width): (i+=1){

                    const kernel_weight_at_ij: f32 = kernel.data[j*kernel.width + i];
                    const i_coord: i64 = @as(i64, @intCast(x)) - kernel_x_offset +
                    @as(i64, @intCast(i));
                    const j_coord: i64 = @as(i64, @intCast(y)) - kernel_y_offset +
                    @as(i64, @intCast(j));

                    if (image.get_pixel(i_coord,j_coord)) |pixel| {  //unwrap with if
                        for (pixel, 0..) |channel, channel_idx| {
                            weighted_sum[channel_idx] += kernel_weight_at_ij *
                            @as(f32, @floatFromInt(channel));
                        }
                    }else {
                        //i_coord,j_coord outside the image
                        //if ignored, the output image has low intensity borders
                        //use replicated padding

                        //i_coord is within bounds, j_coord is not
                        if (i_coord >= 0 and i_coord <= img_width_i64 - 1){

                            const replicated_pixel = if (j_coord < 0) image.get_pixel(i_coord, 0).?
                            else image.get_pixel(i_coord, img_height_i64 - 1).?; 

                            for (replicated_pixel, 0..) |channel, channel_idx| {
                                weighted_sum[channel_idx] += kernel_weight_at_ij *
                                @as(f32, @floatFromInt(channel));
                            }
                        }

                        //j_coord is within bounds, i_coord is not
                        if (j_coord >= 0 and j_coord <= img_width_i64 - 1){

                            const replicated_pixel = if (i_coord < 0) image.get_pixel(0, j_coord).?
                            else image.get_pixel(img_width_i64 - 1, j_coord).?; 

                            for (replicated_pixel, 0..) |channel, channel_idx| {
                                weighted_sum[channel_idx] += kernel_weight_at_ij *
                                @as(f32, @floatFromInt(channel));
                            }
                        }

                        //both j_coord and i_coord are out of bounds
                        if ((i_coord<0 and j_coord<0) or (i_coord>=img_width_i64 and j_coord>=img_height_i64)){

                            const replicated_pixel = if (i_coord<0) image.get_pixel(0,0).?
                            else image.get_pixel(img_width_i64 - 1, img_height_i64 - 1).?; 

                            for (replicated_pixel, 0..) |channel, channel_idx| {
                                weighted_sum[channel_idx] += kernel_weight_at_ij *
                                @as(f32, @floatFromInt(channel));
                            }
                        }

                    }

                }
            }

            const pixel_start: usize = ((y * image.width) + x) * image.channels ;  
            for (weighted_sum, 0..) |channel, idx| {
                result_buffer[pixel_start + idx] = @intFromFloat(@min(255,@max(0,channel))); // 0 < value < 255
            }
        }
    }
    
    //write the result back to the image
    // @memcpy(image.data, result_buffer);
    
    //return the result as a new image 

    return .{
        .width = image.width, 
        .height =image.height, 
        .channels = image.channels, 
        .allocator = image.allocator, // TODO: check allocator ownership is correctly done, eg is deinit() called anywhere?
        .data = result_buffer,
    };


}





//Laplacian mask/image from an input image.
//The mask image data is immutable and read-only
// pub fn create_laplacian_mask(image: Image, allocator: std.mem.Allocator) !Image {
//     const result: []u8 = allocator.alloc(u8, image.width * image.height * image.channels);
//     const laplacian_kernel_weights = [_]i8 {1,1,1,1,-8,1,1,1,1};
//     const laplacian_kernel: Kernel = .{
//         .height = 3, 
//         .width = 3, 
//         .allocator = allocator,
//         .data = laplacian_kernel_weights[0..],
//     };
//
//     try linear_spatial_filter_naive(image: *Image, kernel: Kernel)
//
//
// }





























