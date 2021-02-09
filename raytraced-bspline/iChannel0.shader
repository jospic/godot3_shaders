shader_type canvas_item;
render_mode blend_disabled;

uniform float iTime;
uniform int iFrame;
uniform sampler2D iChannel0;
uniform sampler2D iChannel1;


//using https://www.shadertoy.com/view/XsG3z1

vec3 hash33(in vec2 p){ 
    float n = sin(dot(p, vec2(41, 289)));    
    return fract(vec3(2097152, 262144, 32768)*n); 
}

vec4 tx(in vec2 p){ return texture(iChannel0, p); }
float blur(in vec2 p, in vec2 iResolution){
    vec3 e = vec3(1, 0, -1);
    vec2 px = 1./iResolution.xy;
	float res = 0.0;
	res += tx(p + e.xx*px ).x + tx(p + e.xz*px ).x + tx(p + e.zx*px ).x + tx(p + e.zz*px ).x;
    res += (tx(p + e.xy*px ).x + tx(p + e.yx*px ).x + tx(p + e.yz*px ).x + tx(p + e.zy*px ).x)*2.;
	res += tx(p + e.yy*px ).x*4.;
    return res/16.;     
    
}

void mainImage( out vec4 fragColor, in vec2 fragCoord, in vec2 iResolution){
	vec2 uv = fragCoord/iResolution.xy;
    vec2 pw = 1./iResolution.xy;
	float avgReactDiff = blur(uv,iResolution);
    vec3 noise = hash33(uv + vec2(53, 43)*iTime)*.6 + .2;
    vec3 e = vec3(1, 0, -1);
    vec2 pwr = pw*1.5; 
	vec2 lap = vec2(tx(uv + e.xy*pwr).y - tx(uv - e.xy*pwr).y, tx(uv + e.yx*pwr).y - tx(uv - e.yx*pwr).y);
    uv = uv + lap*pw*3.0; 
    float newReactDiff = tx(uv).x + (noise.z - 0.5)*0.0025 - 0.002; 
	newReactDiff += dot(tx(uv + (noise.xy-0.5)*pw).xy, vec2(1, -1))*0.145; 
    if(iFrame>9) fragColor.xy = clamp(vec2(newReactDiff, avgReactDiff/.98), 0., 1.);
    else fragColor = vec4(noise, 1.);
	fragColor.a=1.;
    
}

void fragment(){
	vec2 iResolution=1./TEXTURE_PIXEL_SIZE;
	mainImage(COLOR,UV*iResolution,iResolution);
}