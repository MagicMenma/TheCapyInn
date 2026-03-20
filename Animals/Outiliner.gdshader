shader_type canvas_item;

uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // 描边颜色
uniform float line_thickness : hint_range(0, 10) = 1.0; // 描边粗细
uniform bool active = false; // 是否开启高亮

void fragment() {
    vec4 col = texture(TEXTURE, UV);
    if (active) {
        vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
        float outline = texture(TEXTURE, UV + vec2(-size.x, 0)).a;
        outline += texture(TEXTURE, UV + vec2(size.x, 0)).a;
        outline += texture(TEXTURE, UV + vec2(0, -size.y)).a;
        outline += texture(TEXTURE, UV + vec2(0, size.y)).a;
        outline = min(outline, 1.0);
        
        COLOR = mix(col, line_color, outline - col.a);
    } else {
        COLOR = col;
    }
}
