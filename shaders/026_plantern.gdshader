shader_type canvas_item;

uniform vec4 ring_color : source_color = vec4(1.0, 1.0, 0.8, 1.0); // 环颜色 + 透明度
uniform float inner_radius : hint_range(0.0, 1.0) = 0.4;  // 内半径
uniform float outer_radius : hint_range(0.0, 1.0) = 0.5;  // 外半径
uniform float softness : hint_range(0.001, 0.2) = 0.2;   // 渐变边缘

void fragment() {
    // 将 UV 原点从左上角移到中心（-0.5 ~ 0.5）
    vec2 uv = UV - vec2(0.5);
    float dist = length(uv); // 当前像素到中心的距离

    // 外环渐变（从 outer_radius 到 outer_radius-softness 之间渐变）
    float outer = smoothstep(outer_radius, outer_radius - softness, dist);

    // 内环渐变（从 inner_radius 到 inner_radius+softness 之间渐变）
    float inner = smoothstep(inner_radius - softness, inner_radius, dist);

    // 两者相乘形成“环形渐变带”
    float ring_alpha = outer * inner;

    // 输出带透明度的颜色
    COLOR = vec4(ring_color.rgb, ring_alpha / 8.0);
}
