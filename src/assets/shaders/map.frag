#version 450

layout(location = 0) out vec4 fragColor;

layout(set = 0, binding = 0) uniform FragInfo {
    vec2 resolution;
    vec2 rect_origin;
    vec2 rect_size;
    float time;
} info;

float circle(vec2 p, vec2 center, float radius) {
    return 1.0 - smoothstep(radius, radius + 0.012, length(p - center));
}

float segment(vec2 p, vec2 a, vec2 b, float width) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return 1.0 - smoothstep(width, width + 0.01, length(pa - ba * h));
}

void main() {
    vec2 uv = clamp((gl_FragCoord.xy - info.rect_origin) / info.rect_size, 0.0, 1.0);
    vec2 p = uv;

    vec3 color = mix(vec3(0.07, 0.12, 0.15), vec3(0.13, 0.19, 0.16), uv.y);

    vec2 grid = abs(fract(uv * vec2(15.0, 9.0)) - 0.5);
    float grid_line = 1.0 - smoothstep(0.0, 0.018, min(grid.x, grid.y));
    color += vec3(0.10, 0.28, 0.24) * grid_line * 0.20;

    vec2 n0 = vec2(0.14, 0.72);
    vec2 n1 = vec2(0.31, 0.55);
    vec2 n2 = vec2(0.48, 0.68);
    vec2 n3 = vec2(0.63, 0.43);
    vec2 n4 = vec2(0.82, 0.30);

    float path = 0.0;
    path += segment(p, n0, n1, 0.010);
    path += segment(p, n1, n2, 0.010);
    path += segment(p, n2, n3, 0.010);
    path += segment(p, n3, n4, 0.010);
    color += vec3(0.85, 0.60, 0.28) * clamp(path, 0.0, 1.0) * 0.72;

    float pulse = 0.85 + 0.15 * sin(info.time * 3.0);
    float nodes = 0.0;
    nodes += circle(p, n0, 0.030);
    nodes += circle(p, n1, 0.034);
    nodes += circle(p, n2, 0.031);
    nodes += circle(p, n3, 0.038);
    nodes += circle(p, n4, 0.042 * pulse);
    color = mix(color, vec3(0.96, 0.78, 0.45), clamp(nodes, 0.0, 1.0));

    float fog = smoothstep(0.92, 0.20, length(uv - vec2(0.50, 0.52)));
    fragColor = vec4(color * fog, 1.0);
}
