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
    vec2 center = uv - 0.5;
    float vignette = dot(center, center);
    vec3 color = vec3(0.03, 0.01, 0.06);
    float alpha = (0.02 + vignette * 0.15) * qt_Opacity;
    fragColor = vec4(color * alpha, alpha);
}
