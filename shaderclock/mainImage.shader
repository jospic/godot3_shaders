shader_type canvas_item;
render_mode blend_disabled;

uniform float iTime;
uniform int iFrame;
uniform float iDate;
uniform sampler2D iChannel0;


//A clock to help teach my kids how to tell the time

float antiAlias(float x, in vec2 iResolution) {
	return (x-(1.0-2.0/iResolution.y))*(iResolution.y/2.0);
	}
	
float blur(float x) {return pow(smoothstep(0.945,1.0,x),10.);}

uniform float PI = 3.14159265359;


float opU( float d1, float d2 )
{
    return max(d1,d2);
}

/*
vec2 opU( vec2 d1, vec2 d2 )
{
    return d1.x>d2.x?d1:d2;
}
*/

float circle(vec2 pos, float radius)
{
    return (1.0-abs(length(pos)-radius));
}

float line( in vec2 p, in vec2 a, in vec2 b )
{
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    float d = length( pa - ba*h );

    return  (1.0 - d);
}

float square(in vec2 p, in vec2 pos, in vec4 s)
{
    float res=0.;
    vec2 uv=(p-pos);
    //    uv-=c;

    res=opU(res,line(uv,vec2(s.x,s.y),vec2(s.z,s.y)));
    res=opU(res,line(uv,vec2(s.z,s.y),vec2(s.z,s.w)));
    res=opU(res,line(uv,vec2(s.z,s.w),vec2(s.x,s.w)));
    res=opU(res,line(uv,vec2(s.x,s.w),vec2(s.x,s.y)));
    return res;
}

vec2 rotatePoint(vec2 pt,vec2 piv,float angle){
    float s=sin(angle);
    float c=cos(angle);
    vec2 p=pt-piv  ;
    return vec2(p.x * c - p.y * s,p.x * s + p.y * c)+piv;
}

vec3 render(vec2 r, vec4 tdata, in vec2 iResolution){
    vec3 col=vec3(0.);
    float bamt=0.;
    col=vec3(1.,0.1,0.45);

    //default materials
    if(r.y==1.) {col=col.rgb;bamt=0.6;}
    if(r.y==2.) {col=col.gbr;bamt=0.6;}
    if(r.y==3.) {col=col.grb;bamt=0.6;}
    if(r.y==4.) {col=col.rrr;bamt=0.;}

    //current hours & mins material glow
    if(floor(r.y)>=10. && floor(r.y)<=22. ) {
        float hmid=mod((tdata.w+150.)/3600.,12.);
            if(floor(r.y-10.)==mod(floor(hmid),12.) || r.y==5.)
            {
                col=col.grb;
                bamt=.5;
            }else{
                col=vec3(.4);
            }
    }
    if(floor(r.y)>=30. && floor(r.y)<=44.) {
        float mmid=mod((((tdata.w+150.)/60.)),60.);
        if(floor(r.y-30.)*5.==floor((mmid)/5.)*5. || r.y==6.){
            col=col.gbr;
            bamt=.5;
        }else{
            col=vec3(.4);
        }
    }

    float aares=clamp(antiAlias(r.x, iResolution), 0.0, 1.);
    aares+=clamp(blur(r.x), 0.0, 1.)*bamt;
    col*=aares;
    return clamp(col,vec3(0.),vec3(1.));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord, in vec2 iResolution )
{
    //    vec2 res=vec2(0.);

    vec2 uv = fragCoord.xy / iResolution.xy;

    vec3 col=vec3(0.);
    //  res=vec2(0.);

    float cmix= (smoothstep(00.,90.,float(iFrame)));
    float times=iDate;
	
    vec4 tdata=vec4(
        mod(times/3600.,12.), 	// hours
        mod(times/60.,60.),		// minutess
        mod(times,60.),			// seconds
        times);					// time (s)

    uv-=vec2(0.20,0.0);

    if(uv.x>0.04 && uv.x<0.65 && uv.y>0.01 && uv.y <1.){
        vec4 cf=texture(iChannel0,uv);
        col+=render(cf.yz,tdata, iResolution);
    }

    //Square things up
    uv.y/=iResolution.x/iResolution.y;

    if(true)
    {
        {
            vec2 ruv=rotatePoint(uv,vec2(0.3),(cmix*(((tdata.y)/60.))-(1./4.))*(2.*PI));
            col+=render(vec2(square(ruv+vec2(0.),vec2(0.3),vec4(-0.05,-0.001,0.18,0.001)),2.),tdata, iResolution);
        }
        {
            vec2 ruv=rotatePoint(uv,vec2(0.3),(cmix*(((tdata.x)/12.))-(1./4.))*(2.*PI));
            col+=render(vec2(square(ruv+vec2(0.),vec2(0.3),vec4(-0.05,-0.002,0.135,0.002)),3.),tdata, iResolution);
        }
        {
            float smotion=tdata.z+(0.5-cos(tdata.z*PI*2.))*0.155;
            vec2 ruv=rotatePoint(uv,vec2(0.3),cmix*(((smotion)/60.)-(1./4.))*(2.*PI));
            col+=render(vec2(square(ruv+vec2(0.),vec2(0.3),vec4(-0.05,-0.0005,0.2,0.0005)),1.),tdata, iResolution)*
                smoothstep(30.,90.,float(iFrame));
        }
    }

    fragColor = vec4(col,1.0);
}

void fragment(){
	vec2 iResolution = 1./SCREEN_PIXEL_SIZE;
	vec2 fragCoord = FRAGCOORD.xy;
	mainImage(COLOR, fragCoord, iResolution);
}