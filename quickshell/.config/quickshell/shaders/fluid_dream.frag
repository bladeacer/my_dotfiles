#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(binding = 0) uniform sampler2D qt_Texture0;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
};
void main() {
    vec2 uv = qt_TexCoord0;
    float wave = sin(uv.y * 40.0 + time * 0.8) * cos(uv.x * 35.0 + time * 0.6);
    float intensity = abs(wave);
    float alpha = intensity * 0.08 * qt_Opacity;
    fragColor = vec4(vec3(1.0) * alpha, alpha);
}
