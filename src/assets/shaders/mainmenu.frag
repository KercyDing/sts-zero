#version 450

layout(location = 0) out vec4 fragColor;

layout(set = 0, binding = 0) uniform FragInfo {
    vec2 resolution;
    vec2 rect_origin;
    vec2 rect_size;
    float time;
} info;

float line(float value, float width) {
    return 1.0 - smoothstep(0.0, width, abs(value));
}

void main() {
    vec2 uv = clamp((gl_FragCoord.xy - info.rect_origin) / info.rect_size, 0.0, 1.0);
    vec2 p = uv * 2.0 - 1.0;

    vec3 top = vec3(0.10, 0.13, 0.22);
    vec3 bottom = vec3(0.22, 0.11, 0.15);
    vec3 color = mix(top, bottom, uv.y);

    float glow = 0.35 / (1.0 + 14.0 * dot(p - vec2(-0.35, -0.22), p - vec2(-0.35, -0.22)));
    float ember = 0.28 / (1.0 + 18.0 * dot(p - vec2(0.55, 0.35), p - vec2(0.55, 0.35)));
    color += vec3(0.18, 0.30, 0.65) * glow;
    color += vec3(0.70, 0.34, 0.18) * ember;

    float sweep = line(fract((uv.x + uv.y * 0.65 + info.time * 0.04) * 7.0) - 0.5, 0.018);
    color += vec3(0.22, 0.38, 0.72) * sweep * 0.20;

    float border = max(
        max(line(uv.x, 0.006), line(1.0 - uv.x, 0.006)),
        max(line(uv.y, 0.006), line(1.0 - uv.y, 0.006))
    );
    color = mix(color, vec3(0.82, 0.66, 0.42), border * 0.65);

    float vignette = smoothstep(1.28, 0.32, length(p));
    fragColor = vec4(color * vignette, 1.0);
}
