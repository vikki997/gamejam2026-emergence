shader_type canvas_item;

uniform vec2 center;
uniform float radius = 0.3;
uniform float softness = 0.08;
uniform float inner_bright = 0.5;
uniform float outer_bright = 0.15;

void fragment() {
    float dist = length(UV - center);
    float mask = smoothstep(radius, radius + softness, dist);
    float final_alpha = mix(inner_bright, outer_bright, mask);
    COLOR.rgb = vec3(0.0,0.0,0.0);
    COLOR.a = 1.0 - final_alpha;
}
