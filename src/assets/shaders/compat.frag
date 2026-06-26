#version 450

layout(location = 0) out vec4 fragColor;

layout(set = 0, binding = 0) uniform FragInfo {
    vec2 resolution;
    vec2 rect_origin;
    vec2 rect_size;
    float time;
} info;

float slash(vec2 uv, float offset, float width) {
    float d = uv.x * 0.72 + uv.y - offset;
    return 1.0 - smoothstep(width, width + 0.015, abs(d));
}

void main() {
    vec2 uv = clamp((gl_FragCoord.xy - info.rect_origin) / info.rect_size, 0.0, 1.0);
    vec2 p = uv * 2.0 - 1.0;

    vec3 color = mix(vec3(0.16, 0.10, 0.13), vec3(0.26, 0.13, 0.10), uv.y);

    float heat = 0.5 + 0.5 * sin(info.time * 1.8 + uv.x * 8.0);
    color += vec3(0.45, 0.12, 0.05) * heat * smoothstep(1.1, 0.1, length(p - vec2(0.45, 0.15)));

    float blades = 0.0;
    blades += slash(uv, 0.52 + sin(info.time) * 0.015, 0.020);
    blades += slash(uv, 0.78, 0.014);
    blades += slash(uv, 1.06, 0.014);
    color += vec3(0.86, 0.42, 0.18) * blades * 0.42;

    float center = smoothstep(0.52, 0.05, abs(uv.y - 0.52)) * smoothstep(0.08, 0.42, uv.x) * smoothstep(0.94, 0.55, uv.x);
    color += vec3(0.55, 0.22, 0.12) * center * 0.35;

    float border = max(
        max(1.0 - smoothstep(0.0, 0.010, uv.x), 1.0 - smoothstep(0.0, 0.010, 1.0 - uv.x)),
        max(1.0 - smoothstep(0.0, 0.010, uv.y), 1.0 - smoothstep(0.0, 0.010, 1.0 - uv.y))
    );
    color = mix(color, vec3(0.90, 0.55, 0.26), border * 0.55);

    fragColor = vec4(color, 1.0);
}
