// #include <stdio.h>

#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image.h"
#include "stb_image_write.h"

//commented out so that zig compiler doesnt panic over two main function in src/ lmao
// int main(){
//
//     int w, h, n_channels;
//     unsigned char* data = stbi_load("./char.jpg", &w, &h, &n_channels, 0);
//
//     printf("w: %d h: %d n_channels %d\n", w,h,n_channels);
//     // int i;
//     // for (i = 0; i < 1025; i++) {
//     //     printf("%d ", data[i]);
//     // }
//
//     int write_img = stbi_write_bmp("wrote_an_img!", 32, 32, 2, data);
//     printf("write_img: %d\n", write_img);
//     return 0;
//
//
// }
