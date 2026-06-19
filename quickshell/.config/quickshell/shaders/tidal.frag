#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(binding = 0) uniform sampler2D source;

layout(std140, binding = 1) uniform buf {
    float qt_Opacity;
    float time;
};

void main() {
    vec2 uv = qt_TexCoord0;

    float wave1 = sin(uv.y * 20.0 + time * 2.0) * 0.04;
    float wave2 = sin(uv.y * 35.0 + time * 3.5) * 0.025;
    float wave3 = cos(uv.x * 15.0 + time * 1.5) * 0.015;
    float displace = wave1 + wave2 + wave3;

    vec2 distorted = vec2(uv.x + displace, uv.y);

    float edge = 1.0 - smoothstep(0.0, 0.1, abs(uv.x - 0.5) - 0.4);
    float tint = 0.5 + 0.5 * sin(uv.y * 30.0 + time * 4.0);

    vec4 color = texture(source, distorted);
    color.rgb += vec3(0.08, 0.12, 0.20) * edge * 0.3;
    color.rgb *= 1.0 + 0.15 * tint * edge;

    fragColor = color * qt_Opacity;
}
