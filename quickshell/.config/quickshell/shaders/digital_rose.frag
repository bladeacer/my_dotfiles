#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(binding = 0) uniform sampler2D qt_Texture0;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
};
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}
void main() {
    vec2 uv = qt_TexCoord0;
    float n = hash(uv + floor(time * 4.0));
    float noise = step(0.995, n) * 0.12;
    float g = hash(vec2(floor(time * 0.8), uv.y * 100.0));
    float glitch = step(0.998, g) * 0.08;
    float alpha = (noise + glitch) * qt_Opacity;
    vec3 roseBlue = vec3(0.3, 0.55, 0.85);
    fragColor = vec4(roseBlue * alpha, alpha);
}
