shader_type canvas_item;

// Grabs the 3D render from the camera behind the UI
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

// How chunky the pixels are
uniform int pixel_size : hint_range(1, 16) = 4;

void fragment() {
    // Get current screen resolution
    vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;
    
    // Snap the UV coordinates to a grid based on chosen pixel size
    vec2 uv = floor(SCREEN_UV * resolution / float(pixel_size)) * float(pixel_size) / resolution;
    
    // Output the chunky pixel
    COLOR = texture(screen_texture, uv);
}