#version 440

in vec2 qt_TexCoord0;
out vec4 fragColor;

uniform float qt_Opacity;
uniform float time;
uniform float bars;
uniform sampler2D src;

#define PI 3.14159265359

void main() {
    vec2 uv = qt_TexCoord0;
    float barWidth = 1.0 / bars;
    float barIdx = floor(uv.x / barWidth);
    float barLocal = (uv.x - barIdx * barWidth) / barWidth;

    float barHeight = 0.1 + 0.9 * (0.5 + 0.5 * sin(barIdx * 0.5 + time * 4.0));
    float glow = 0.0;

    if (uv.y < barHeight) {
        float distToEdge = abs(uv.y - barHeight) / barHeight;
        glow = exp(-distToEdge * 20.0) * 0.3;
        float edge = 1.0 - smoothstep(barHeight - 0.02, barHeight, uv.y);
        fragColor = mix(
            vec4(0.52, 0.63, 0.78, 1.0),
            vec4(0.71, 0.78, 0.51, 1.0),
            barHeight
        ) * qt_Opacity * (edge + glow);
    } else {
        fragColor = vec4(0.0, 0.0, 0.0, 0.0);
    }
}
