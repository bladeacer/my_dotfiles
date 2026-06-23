#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(binding = 0) uniform sampler2D qt_Texture0;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
    vec4 transBgColor;
};
void main() {
    vec2 uv = qt_TexCoord0;
    float beamY = progress;
    float reveal = step(uv.y, beamY);
    float dist = uv.y - beamY;
    float beamGlow = exp(-abs(dist) * 200.0);
    vec3 color = mix(transBgColor.rgb, vec3(0.2, 0.6, 1.0), beamGlow * 0.5);
    float alpha = 1.0 - reveal;
    fragColor = vec4(color * alpha, alpha);
}
