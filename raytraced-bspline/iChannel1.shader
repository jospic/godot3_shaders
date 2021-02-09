shader_type canvas_item;
render_mode blend_disabled;

uniform float iTime;
uniform int iFrame;
uniform sampler2D iChannel0;
uniform sampler2D iChannel1;


// bufA self reading test
// bufB cross reading(copy of this mainImage) 
// bufC display iResolution
// bufD display iTime iFrame

// from https://www.shadertoy.com/view/XsG3z1
vec4 mainImage_bufA(out vec4 fragColor, in vec2 fragCoord, in vec2 iResolution){
    vec2 uv = fragCoord;
    float c = 1. - texture(iChannel0, uv).y; 
    float c2 = 1. - texture(iChannel0, uv + .5/iResolution.xy).y;
    float pattern = -cos(uv.x*.75*3.14159 - .9)*cos(uv.y*1.5*3.14159 - .75)*.5 + .5;
    vec3 col = pow(vec3(1.5, 1, 1)*c, vec3(1, 2.25, 6));
    col = mix(col, col.zyx, clamp(pattern - .2, 0., 1.) );
    col += vec3(.6, .85, 1.)*max(c2*c2 - c*c, 0.)*12.;
    col *= pow( 16.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y) , .125)*1.15;
    col *= smoothstep(0., 1., iTime/2.);
    return vec4(min(col, 1.), 1); 
}


void mainImage( out vec4 fragColor, in vec2 fragCoord, in vec2 iResolution )
{
    vec2 uv = fragCoord/iResolution.xy;
    vec3 col = vec3(0.);
	
	uv*=2.;// simple tiles
	int id=int(uv.x)+int(uv.y)*2; //tile ID
	uv=fract(uv);// 4 tiles
	if(id==0)col=mainImage_bufA(fragColor,uv,iResolution).rgb;
	if(id==1)col=texture(iChannel1,uv).rgb;
	if(id==2)col=texture(iChannel2,uv).rgb;
	if(id==3)col=texture(iChannel3,uv).bgr;
	
    fragColor = vec4(col,1.0);
}

void fragment(){
	vec2 iResolution=1./TEXTURE_PIXEL_SIZE;
	mainImage(COLOR,UV*iResolution,iResolution);
}