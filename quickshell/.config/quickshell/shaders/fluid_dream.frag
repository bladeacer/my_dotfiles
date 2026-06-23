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
    float wave = sin(uv.x * 25.0 + uv.y * 20.0 + time * 0.9) * 0.5 + 0.5;
    float alpha = wave * 0.08 * qt_Opacity;
    fragColor = vec4(vec3(1.0) * alpha, alpha);
}
