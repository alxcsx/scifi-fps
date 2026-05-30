shader_type canvas_item;

//Pixel size  ----------------------
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform int pixel_size : hint_range(1, 16) = 4;


//Dithering  -----------------------
// Make the dithering more or less aggressive
uniform float dither_strength : hint_range(0.0, 1.0) = 0.2; 

const mat4 bayer = mat4(
    vec4( 0.0/16.0, 12.0/16.0,  3.0/16.0, 15.0/16.0),
    vec4( 8.0/16.0,  4.0/16.0, 11.0/16.0,  7.0/16.0),
    vec4( 2.0/16.0, 14.0/16.0,  1.0/16.0, 13.0/16.0),
    vec4(10.0/16.0,  6.0/16.0,  9.0/16.0,  5.0/16.0)
);

void fragment() {
    vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;
    vec2 uv = floor(SCREEN_UV * resolution / float(pixel_size)) * float(pixel_size) / resolution;
    vec4 color = texture(screen_texture, uv);
    
    // Calculate the dither value based on the screen pixel coordinate
    int x = int(FRAGCOORD.x / float(pixel_size)) % 4;
    int y = int(FRAGCOORD.y / float(pixel_size)) % 4;
    float dither = bayer[x][y] - 0.5;
    
    // Apply the dither slightly to the color to create the crunchy gradients
    COLOR = color + vec4(dither * dither_strength);
}