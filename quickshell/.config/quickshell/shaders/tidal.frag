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

    float face = smoothstep(-0.05, 0.25, pos);
    float curl = uv.y * uv.y * 0.35;
    float cpos = pos + curl * exp(-pos * pos * 12.0);

    float body = exp(-cpos * cpos * 8.0) * (1.0 - uv.y * 0.5);
    float crestGlow = exp(-cpos * cpos * 30.0);

    float foam = crestGlow * (0.6 + 0.4 * sin(cpos * 60.0 + uv.y * 30.0));
    float spray = exp(-abs(cpos) * 50.0) * (1.0 - uv.y) * 0.5;

    float trail = 0.0;
    for (int i = 1; i <= 3; i++) {
        float ti = float(i) * 0.25;
        float tp = pos + ti;
        trail += exp(-tp * tp * 8.0) * (0.3 - float(i) * 0.07);
    }

    float alpha = max(body, trail) * 0.75;
    vec3 waveColor = vec3(0.45, 0.58, 0.78);
    vec3 deepColor = vec3(0.35, 0.45, 0.65);
    vec3 foamColor = vec3(0.75, 0.9, 1.0);
    vec3 base = vec3(0.12, 0.13, 0.20);

    vec3 color = mix(base, deepColor, body * 0.9);
    color = mix(color, waveColor, trail * 0.7);
    color = mix(color, foamColor, foam * 0.9 + spray * 0.6);
    color += foamColor * crestGlow * 0.3;

    fragColor = vec4(color, alpha) * qt_Opacity;
}
