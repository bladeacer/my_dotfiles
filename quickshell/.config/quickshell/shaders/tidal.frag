#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float sweep;
};

void main() {
    vec2 uv = qt_TexCoord0;
    float pos = uv.x - sweep;

    float crest = sin(pos * 35.0 + uv.y * 20.0) * exp(-abs(pos) * 10.0);
    crest += sin(pos * 20.0 + uv.y * 12.0) * 0.4 * exp(-abs(pos) * 6.0);
    float displace = crest * 0.025;
    vec2 dist = vec2(uv.x + displace * (1.0 - uv.y), uv.y + displace * 0.3);

    float glow = exp(-abs(pos) * 7.0);
    vec3 waveColor = vec3(0.52, 0.63, 0.78);
    vec3 foam = vec3(0.7, 0.85, 1.0);
    vec3 base = vec3(0.12, 0.13, 0.20);
    vec3 color = mix(base, waveColor, glow * 0.8);
    color += foam * glow * 0.25 * (0.5 + 0.5 * sin(pos * 45.0 + uv.y * 25.0));
    color *= 1.0 + 0.1 * glow * (0.5 + 0.5 * sin(pos * 10.0 - uv.y * 8.0));
    float alpha = glow * 0.6;

    fragColor = vec4(color, alpha) * qt_Opacity;
}
