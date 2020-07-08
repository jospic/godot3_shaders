shader_type canvas_item;
render_mode blend_disabled;

uniform float iTime;
uniform int iFrame;
uniform sampler2D iChannel0;


void mainImage( out vec4 fragColor, in vec2 fragCoord, in vec2 iResolution )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    
	vec4 tex = texture(iChannel0, uv);
    
	fragColor = vec4(tex.xyz, 1.0);
}

void fragment(){
	vec2 iResolution=1./TEXTURE_PIXEL_SIZE;
	mainImage(COLOR,UV*iResolution,iResolution);
}