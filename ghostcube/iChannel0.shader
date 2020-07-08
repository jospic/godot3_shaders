shader_type canvas_item;
render_mode blend_disabled;

uniform float iTime;
uniform int iFrame;
uniform sampler2D iChannel0;



float sdBox( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) +
         length(max(d,0.0));
}

float map(vec3 p)
{
    float t = iTime;
    p.xz *= mat2(vec2(cos(t), sin(t)), vec2(-sin(t), cos(t)));
    p.xy *= mat2(vec2(cos(t), sin(t)), vec2(-sin(t), cos(t)));
    p.yz *= mat2(vec2(cos(t), sin(t)), vec2(-sin(t), cos(t)));
    
    float k = sdBox(p, vec3(1.0));
    float o = 0.85;
	k = max(k, -sdBox(p, vec3(2.0, o, o)));
    k = max(k, -sdBox(p, vec3(o, 2.0, o)));
    k = max(k, -sdBox(p, vec3(o, o, 2.0)));
    return k;
}

float trace(vec3 o, vec3 r)
{
 	float t = 0.0;
    for (int i = 0; i < 32; ++i) {
        vec3 p = o + r * t;
        float d = map(p) * 0.9;
        t += d;
    }
    return t;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord, in vec2 iResolution )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    vec4 old = texture(iChannel0, uv - vec2(0.0, 1.0/1024.));
    vec4 old2 = texture(iChannel0, uv - vec2(0.0, 2.0*1.0/1024.));
    
    uv = uv * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;
    
    vec3 o = vec3(0.0, 0.0, -2.5);
    vec3 r = vec3(uv, 0.8);
    
    float t = trace(o, r);
    
    vec3 fog = vec3(1.0) / (1.0 + t * t * 0.1) * 0.1;
    
    float c = iTime * 5.0 + uv.x;
    fog *= vec3(sin(c)*cos(c*2.0), cos(c)*cos(c*2.0), sin(c)) * 0.5 + 0.5;
    
    fog += old.xyz * 0.6 + old2.xyz * 0.37;
    
	fragColor = vec4(fog, 1.0);
}




void fragment(){
	vec2 iResolution=1./TEXTURE_PIXEL_SIZE;
	mainImage(COLOR,UV*iResolution, iResolution);
}