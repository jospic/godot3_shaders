shader_type canvas_item;
render_mode blend_disabled;

uniform float iTime;
uniform float iDate;
uniform int iFrame;
uniform sampler2D iChannel0;

uniform float PI = 3.14159265359;


vec2 opU( vec2 d1, vec2 d2 )
{
    return d1.x>d2.x?d1:d2;
}

float circle(vec2 pos, float radius)
{
    return 1.0-(abs(length(pos)-radius));

}

float line( in vec2 p, in vec2 a, in vec2 b )
{
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    float d = length( pa - ba*h );

    return  (1.0 - d);
}


vec2 rotatePoint(vec2 pt,vec2 piv,float angle){
    float s=sin(angle);
    float c=cos(angle);
    vec2 p=pt-piv  ;
    return vec2(p.x * c - p.y * s,p.x * s + p.y * c)+piv;
}


//uniform vec2 res=vec2(0.);
//uniform vec2 cpos=vec2(0.);

// CHAR: 48 :0
void char_0(vec2 uv,vec2 s,float m, inout vec2 res, inout vec2 cpos){
    vec2 p=uv-cpos;
    res=opU(res,vec2(line(p,vec2(9.0,21.0)*s,vec2(6.0,20.0)*s),m));
    res=opU(res,vec2(line(p,vec2(6.0,20.0)*s,vec2(4.0,17.0)*s),m));
    res=opU(res,vec2(line(p,vec2(4.0,17.0)*s,vec2(3.0,12.0)*s),m));
    res=opU(res,vec2(line(p,vec2(3.0,12.0)*s,vec2(3.0,9.0)*s),m));
    res=opU(res,vec2(line(p,vec2(3.0,9.0)*s,vec2(4.0,4.0)*s),m));
    res=opU(res,vec2(line(p,vec2(4.0,4.0)*s,vec2(6.0,1.0)*s),m));
    res=opU(res,vec2(line(p,vec2(6.0,1.0)*s,vec2(9.0,0.0)*s),m));
    res=opU(res,vec2(line(p,vec2(9.0,0.0)*s,vec2(11.0,0.0)*s),m));
    res=opU(res,vec2(line(p,vec2(11.0,0.0)*s,vec2(14.0,1.0)*s),m));
    res=opU(res,vec2(line(p,vec2(14.0,1.0)*s,vec2(16.0,4.0)*s),m));
    res=opU(res,vec2(line(p,vec2(16.0,4.0)*s,vec2(17.0,9.0)*s),m));
    res=opU(res,vec2(line(p,vec2(17.0,9.0)*s,vec2(17.0,12.0)*s),m));
    res=opU(res,vec2(line(p,vec2(17.0,12.0)*s,vec2(16.0,17.0)*s),m));
    res=opU(res,vec2(line(p,vec2(16.0,17.0)*s,vec2(14.0,20.0)*s),m));
    res=opU(res,vec2(line(p,vec2(14.0,20.0)*s,vec2(11.0,21.0)*s),m));
    res=opU(res,vec2(line(p,vec2(11.0,21.0)*s,vec2(9.0,21.0)*s),m));
    cpos.x+=20.0*s.x;
}
// CHAR: 49 :1
void char_1(vec2 uv,vec2 s,float m, inout vec2 res, inout vec2 cpos){
    vec2 p=uv-cpos;
    res=opU(res,vec2(line(p,vec2(6.0,17.0)*s,vec2(8.0,18.0)*s),m));
    res=opU(res,vec2(line(p,vec2(8.0,18.0)*s,vec2(11.0,21.0)*s),m));
    res=opU(res,vec2(line(p,vec2(11.0,21.0)*s,vec2(11.0,0.0)*s),m));
    cpos.x+=20.0*s.x;
}
// CHAR: 50 :2
void char_2(vec2 uv,vec2 s,float m, inout vec2 res, inout vec2 cpos){
    vec2 p=uv-cpos;
    res=opU(res,vec2(line(p,vec2(4.0,16.0)*s,vec2(4.0,17.0)*s),m));
    res=opU(res,vec2(line(p,vec2(4.0,17.0)*s,vec2(5.0,19.0)*s),m));
    res=opU(res,vec2(line(p,vec2(5.0,19.0)*s,vec2(6.0,20.0)*s),m));
    res=opU(res,vec2(line(p,vec2(6.0,20.0)*s,vec2(8.0,21.0)*s),m));
    res=opU(res,vec2(line(p,vec2(8.0,21.0)*s,vec2(12.0,21.0)*s),m));
    res=opU(res,vec2(line(p,vec2(12.0,21.0)*s,vec2(14.0,20.0)*s),m));
    res=opU(res,vec2(line(p,vec2(14.0,20.0)*s,vec2(15.0,19.0)*s),m));
    res=opU(res,vec2(line(p,vec2(15.0,19.0)*s,vec2(16.0,17.0)*s),m));
    res=opU(res,vec2(line(p,vec2(16.0,17.0)*s,vec2(16.0,15.0)*s),m));
    res=opU(res,vec2(line(p,vec2(16.0,15.0)*s,vec2(15.0,13.0)*s),m));
    res=opU(res,vec2(line(p,vec2(15.0,13.0)*s,vec2(13.0,10.0)*s),m));
    res=opU(res,vec2(line(p,vec2(13.0,10.0)*s,vec2(3.0,0.0)*s),m));
    res=opU(res,vec2(line(p,vec2(3.0,0.0)*s,vec2(17.0,0.0)*s),m));
    cpos.x+=20.0*s.x;
}
// CHAR: 51 :3
void char_3(vec2 uv,vec2 s,float m, inout vec2 res, inout vec2 cpos){
    vec2 p=uv-cpos;
    res=opU(res,vec2(line(p,vec2(5.0,21.0)*s,vec2(16.0,21.0)*s),m));
    res=opU(res,vec2(line(p,vec2(16.0,21.0)*s,vec2(10.0,13.0)*s),m));
    res=opU(res,vec2(line(p,vec2(10.0,13.0)*s,vec2(13.0,13.0)*s),m));
    res=opU(res,vec2(line(p,vec2(13.0,13.0)*s,vec2(15.0,12.0)*s),m));
    res=opU(res,vec2(line(p,vec2(15.0,12.0)*s,vec2(16.0,11.0)*s),m));
    res=opU(res,vec2(line(p,vec2(16.0,11.0)*s,vec2(17.0,8.0)*s),m));
    res=opU(res,vec2(line(p,vec2(17.0,8.0)*s,vec2(17.0,6.0)*s),m));
    res=opU(res,vec2(line(p,vec2(17.0,6.0)*s,vec2(16.0,3.0)*s),m));
    res=opU(res,vec2(line(p,vec2(16.0,3.0)*s,vec2(14.0,1.0)*s),m));
    res=opU(res,vec2(line(p,vec2(14.0,1.0)*s,vec2(11.0,0.0)*s),m));
    res=opU(res,vec2(line(p,vec2(11.0,0.0)*s,vec2(8.0,0.0)*s),m));
    res=opU(res,vec2(line(p,vec2(8.0,0.0)*s,vec2(5.0,1.0)*s),m));
    res=opU(res,vec2(line(p,vec2(5.0,1.0)*s,vec2(4.0,2.0)*s),m));
    res=opU(res,vec2(line(p,vec2(4.0,2.0)*s,vec2(3.0,4.0)*s),m));
    cpos.x+=20.0*s.x;
}
// CHAR: 52 :4
void char_4(vec2 uv,vec2 s,float m, inout vec2 res, inout vec2 cpos){
    vec2 p=uv-cpos;
    res=opU(res,vec2(line(p,vec2(13.0,21.0)*s,vec2(3.0,7.0)*s),m));
    res=opU(res,vec2(line(p,vec2(3.0,7.0)*s,vec2(18.0,7.0)*s),m));
    res=opU(res,vec2(line(p,vec2(13.0,21.0)*s,vec2(13.0,0.0)*s),m));
    cpos.x+=20.0*s.x;
}
// CHAR: 53 :5
void char_5(vec2 uv,vec2 s,float m, inout vec2 res, inout vec2 cpos){
    vec2 p=uv-cpos;
    res=opU(res,vec2(line(p,vec2(15.0,21.0)*s,vec2(5.0,21.0)*s),m));
    res=opU(res,vec2(line(p,vec2(5.0,21.0)*s,vec2(4.0,12.0)*s),m));
    res=opU(res,vec2(line(p,vec2(4.0,12.0)*s,vec2(5.0,13.0)*s),m));
    res=opU(res,vec2(line(p,vec2(5.0,13.0)*s,vec2(8.0,14.0)*s),m));
    res=opU(res,vec2(line(p,vec2(8.0,14.0)*s,vec2(11.0,14.0)*s),m));
    res=opU(res,vec2(line(p,vec2(11.0,14.0)*s,vec2(14.0,13.0)*s),m));
    res=opU(res,vec2(line(p,vec2(14.0,13.0)*s,vec2(16.0,11.0)*s),m));
    res=opU(res,vec2(line(p,vec2(16.0,11.0)*s,vec2(17.0,8.0)*s),m));
    res=opU(res,vec2(line(p,vec2(17.0,8.0)*s,vec2(17.0,6.0)*s),m));
    res=opU(res,vec2(line(p,vec2(17.0,6.0)*s,vec2(16.0,3.0)*s),m));
    res=opU(res,vec2(line(p,vec2(16.0,3.0)*s,vec2(14.0,1.0)*s),m));
    res=opU(res,vec2(line(p,vec2(14.0,1.0)*s,vec2(11.0,0.0)*s),m));
    res=opU(res,vec2(line(p,vec2(11.0,0.0)*s,vec2(8.0,0.0)*s),m));
    res=opU(res,vec2(line(p,vec2(8.0,0.0)*s,vec2(5.0,1.0)*s),m));
    res=opU(res,vec2(line(p,vec2(5.0,1.0)*s,vec2(4.0,2.0)*s),m));
    res=opU(res,vec2(line(p,vec2(4.0,2.0)*s,vec2(3.0,4.0)*s),m));
    cpos.x+=20.0*s.x;
}
// CHAR: 54 :6
void char_6(vec2 uv,vec2 s,float m, inout vec2 res, inout vec2 cpos){
    vec2 p=uv-cpos;
    res=opU(res,vec2(line(p,vec2(16.0,18.0)*s,vec2(15.0,20.0)*s),m));
    res=opU(res,vec2(line(p,vec2(15.0,20.0)*s,vec2(12.0,21.0)*s),m));
    res=opU(res,vec2(line(p,vec2(12.0,21.0)*s,vec2(10.0,21.0)*s),m));
    res=opU(res,vec2(line(p,vec2(10.0,21.0)*s,vec2(7.0,20.0)*s),m));
    res=opU(res,vec2(line(p,vec2(7.0,20.0)*s,vec2(5.0,17.0)*s),m));
    res=opU(res,vec2(line(p,vec2(5.0,17.0)*s,vec2(4.0,12.0)*s),m));
    res=opU(res,vec2(line(p,vec2(4.0,12.0)*s,vec2(4.0,7.0)*s),m));
    res=opU(res,vec2(line(p,vec2(4.0,7.0)*s,vec2(5.0,3.0)*s),m));
    res=opU(res,vec2(line(p,vec2(5.0,3.0)*s,vec2(7.0,1.0)*s),m));
    res=opU(res,vec2(line(p,vec2(7.0,1.0)*s,vec2(10.0,0.0)*s),m));
    res=opU(res,vec2(line(p,vec2(10.0,0.0)*s,vec2(11.0,0.0)*s),m));
    res=opU(res,vec2(line(p,vec2(11.0,0.0)*s,vec2(14.0,1.0)*s),m));
    res=opU(res,vec2(line(p,vec2(14.0,1.0)*s,vec2(16.0,3.0)*s),m));
    res=opU(res,vec2(line(p,vec2(16.0,3.0)*s,vec2(17.0,6.0)*s),m));
    res=opU(res,vec2(line(p,vec2(17.0,6.0)*s,vec2(17.0,7.0)*s),m));
    res=opU(res,vec2(line(p,vec2(17.0,7.0)*s,vec2(16.0,10.0)*s),m));
    res=opU(res,vec2(line(p,vec2(16.0,10.0)*s,vec2(14.0,12.0)*s),m));
    res=opU(res,vec2(line(p,vec2(14.0,12.0)*s,vec2(11.0,13.0)*s),m));
    res=opU(res,vec2(line(p,vec2(11.0,13.0)*s,vec2(10.0,13.0)*s),m));
    res=opU(res,vec2(line(p,vec2(10.0,13.0)*s,vec2(7.0,12.0)*s),m));
    res=opU(res,vec2(line(p,vec2(7.0,12.0)*s,vec2(5.0,10.0)*s),m));
    res=opU(res,vec2(line(p,vec2(5.0,10.0)*s,vec2(4.0,7.0)*s),m));
    cpos.x+=20.0*s.x;
}
// CHAR: 55 :7
void char_7(vec2 uv,vec2 s,float m, inout vec2 res, inout vec2 cpos){
    vec2 p=uv-cpos;
    res=opU(res,vec2(line(p,vec2(17.0,21.0)*s,vec2(7.0,0.0)*s),m));
    res=opU(res,vec2(line(p,vec2(3.0,21.0)*s,vec2(17.0,21.0)*s),m));
    cpos.x+=20.0*s.x;
}
// CHAR: 56 :8
void char_8(vec2 uv,vec2 s,float m, inout vec2 res, inout vec2 cpos){
    vec2 p=uv-cpos;
    res=opU(res,vec2(line(p,vec2(8.0,21.0)*s,vec2(5.0,20.0)*s),m));
    res=opU(res,vec2(line(p,vec2(5.0,20.0)*s,vec2(4.0,18.0)*s),m));
    res=opU(res,vec2(line(p,vec2(4.0,18.0)*s,vec2(4.0,16.0)*s),m));
    res=opU(res,vec2(line(p,vec2(4.0,16.0)*s,vec2(5.0,14.0)*s),m));
    res=opU(res,vec2(line(p,vec2(5.0,14.0)*s,vec2(7.0,13.0)*s),m));
    res=opU(res,vec2(line(p,vec2(7.0,13.0)*s,vec2(11.0,12.0)*s),m));
    res=opU(res,vec2(line(p,vec2(11.0,12.0)*s,vec2(14.0,11.0)*s),m));
    res=opU(res,vec2(line(p,vec2(14.0,11.0)*s,vec2(16.0,9.0)*s),m));
    res=opU(res,vec2(line(p,vec2(16.0,9.0)*s,vec2(17.0,7.0)*s),m));
    res=opU(res,vec2(line(p,vec2(17.0,7.0)*s,vec2(17.0,4.0)*s),m));
    res=opU(res,vec2(line(p,vec2(17.0,4.0)*s,vec2(16.0,2.0)*s),m));
    res=opU(res,vec2(line(p,vec2(16.0,2.0)*s,vec2(15.0,1.0)*s),m));
    res=opU(res,vec2(line(p,vec2(15.0,1.0)*s,vec2(12.0,0.0)*s),m));
    res=opU(res,vec2(line(p,vec2(12.0,0.0)*s,vec2(8.0,0.0)*s),m));
    res=opU(res,vec2(line(p,vec2(8.0,0.0)*s,vec2(5.0,1.0)*s),m));
    res=opU(res,vec2(line(p,vec2(5.0,1.0)*s,vec2(4.0,2.0)*s),m));
    res=opU(res,vec2(line(p,vec2(4.0,2.0)*s,vec2(3.0,4.0)*s),m));
    res=opU(res,vec2(line(p,vec2(3.0,4.0)*s,vec2(3.0,7.0)*s),m));
    res=opU(res,vec2(line(p,vec2(3.0,7.0)*s,vec2(4.0,9.0)*s),m));
    res=opU(res,vec2(line(p,vec2(4.0,9.0)*s,vec2(6.0,11.0)*s),m));
    res=opU(res,vec2(line(p,vec2(6.0,11.0)*s,vec2(9.0,12.0)*s),m));
    res=opU(res,vec2(line(p,vec2(9.0,12.0)*s,vec2(13.0,13.0)*s),m));
    res=opU(res,vec2(line(p,vec2(13.0,13.0)*s,vec2(15.0,14.0)*s),m));
    res=opU(res,vec2(line(p,vec2(15.0,14.0)*s,vec2(16.0,16.0)*s),m));
    res=opU(res,vec2(line(p,vec2(16.0,16.0)*s,vec2(16.0,18.0)*s),m));
    res=opU(res,vec2(line(p,vec2(16.0,18.0)*s,vec2(15.0,20.0)*s),m));
    res=opU(res,vec2(line(p,vec2(15.0,20.0)*s,vec2(12.0,21.0)*s),m));
    res=opU(res,vec2(line(p,vec2(12.0,21.0)*s,vec2(8.0,21.0)*s),m));
    cpos.x+=20.0*s.x;
}
// CHAR: 57 :9
void char_9(vec2 uv,vec2 s,float m, inout vec2 res, inout vec2 cpos){
    vec2 p=uv-cpos;
    res=opU(res,vec2(line(p,vec2(16.0,14.0)*s,vec2(15.0,11.0)*s),m));
    res=opU(res,vec2(line(p,vec2(15.0,11.0)*s,vec2(13.0,9.0)*s),m));
    res=opU(res,vec2(line(p,vec2(13.0,9.0)*s,vec2(10.0,8.0)*s),m));
    res=opU(res,vec2(line(p,vec2(10.0,8.0)*s,vec2(9.0,8.0)*s),m));
    res=opU(res,vec2(line(p,vec2(9.0,8.0)*s,vec2(6.0,9.0)*s),m));
    res=opU(res,vec2(line(p,vec2(6.0,9.0)*s,vec2(4.0,11.0)*s),m));
    res=opU(res,vec2(line(p,vec2(4.0,11.0)*s,vec2(3.0,14.0)*s),m));
    res=opU(res,vec2(line(p,vec2(3.0,14.0)*s,vec2(3.0,15.0)*s),m));
    res=opU(res,vec2(line(p,vec2(3.0,15.0)*s,vec2(4.0,18.0)*s),m));
    res=opU(res,vec2(line(p,vec2(4.0,18.0)*s,vec2(6.0,20.0)*s),m));
    res=opU(res,vec2(line(p,vec2(6.0,20.0)*s,vec2(9.0,21.0)*s),m));
    res=opU(res,vec2(line(p,vec2(9.0,21.0)*s,vec2(10.0,21.0)*s),m));
    res=opU(res,vec2(line(p,vec2(10.0,21.0)*s,vec2(13.0,20.0)*s),m));
    res=opU(res,vec2(line(p,vec2(13.0,20.0)*s,vec2(15.0,18.0)*s),m));
    res=opU(res,vec2(line(p,vec2(15.0,18.0)*s,vec2(16.0,14.0)*s),m));
    res=opU(res,vec2(line(p,vec2(16.0,14.0)*s,vec2(16.0,9.0)*s),m));
    res=opU(res,vec2(line(p,vec2(16.0,9.0)*s,vec2(15.0,4.0)*s),m));
    res=opU(res,vec2(line(p,vec2(15.0,4.0)*s,vec2(13.0,1.0)*s),m));
    res=opU(res,vec2(line(p,vec2(13.0,1.0)*s,vec2(10.0,0.0)*s),m));
    res=opU(res,vec2(line(p,vec2(10.0,0.0)*s,vec2(8.0,0.0)*s),m));
    res=opU(res,vec2(line(p,vec2(8.0,0.0)*s,vec2(5.0,1.0)*s),m));
    res=opU(res,vec2(line(p,vec2(5.0,1.0)*s,vec2(4.0,3.0)*s),m));
    cpos.x+=20.0*s.x;
}

void putDigit(float d,vec2 uv, vec2 s,float m, vec2 res, vec2 cpos)
{
    d = floor(d);    
    if(d == 0.0){ char_0(uv,s,m, res, cpos); return;}
    if(d == 1.0){ char_1(uv,s,m, res, cpos); return;}
    if(d == 2.0){ char_2(uv,s,m, res, cpos); return;}
    if(d == 3.0){ char_3(uv,s,m, res, cpos); return;}
    if(d == 4.0){ char_4(uv,s,m, res, cpos); return;}
    if(d == 5.0){ char_5(uv,s,m, res, cpos); return;}
    if(d == 6.0){ char_6(uv,s,m, res, cpos); return;}
    if(d == 7.0){ char_7(uv,s,m, res, cpos); return;}
    if(d == 8.0){ char_8(uv,s,m, res, cpos); return;}
    if(d == 9.0){ char_9(uv,s,m, res, cpos); return;}
}

void minutes(vec2 uv)
{
    vec2 buv=uv;
    //    cpos=vec2(0.3 ,0.3)-vec2(0.02);
    vec2 sc=vec2(0.001);
    float numdia=8.;
	vec2 cpos = vec2(0.);
	vec2 res = vec2(0.);
	
    for(float i=0.;i<12.;i++)
    {
        vec2 numpos=vec2(0.3 ,0.3)-(vec2(10.)*sc);

        cpos=rotatePoint(vec2(numpos.x,numpos.y+0.17),numpos,(-i/12.)*PI*2.);
        vec2 coff=vec2(18.,8.);
        vec2 ccen=coff;

        vec2 croff=rotatePoint(coff,ccen,(-i/12.)*PI*2.);

        cpos-=croff*sc;
        cpos+=sc*8.;
        vec2 bcp=cpos;
		float m=30.+i;

        for(int ii = 1;ii >= 0;ii--)
        {
            float digit = mod( (i*5.) / pow(10.0, float(ii)) , 10.0);
            putDigit(digit,buv,sc,m, res, cpos);
            cpos=bcp+vec2(16.*sc.x,0.);
        }

    }
}

void hours(vec2 uv)
{
    vec2 buv=uv;
    //    cpos=vec2(0.3 ,0.3)-vec2(0.02);
    vec2 sc=vec2(0.002);
    float numdia=8.;
	vec2 cpos = vec2(0.);
	vec2 res = vec2(0.);
	
    for(float i=0.;i<12.;i++)
    {
        vec2 numpos=vec2(0.3 ,0.3)-(vec2(10.)*sc);
        float np=-i/12.;
        cpos=rotatePoint(vec2(numpos.x,numpos.y+0.232),numpos,(np)*PI*2.);
        vec2 coff=vec2((((i==0.) || (i>=10.))?18.:8.),8.);
        vec2 ccen=vec2((((i==0.) || (i>=10.))?18.:8.),8.);

        vec2 croff=rotatePoint(coff,ccen,(-i/12.)*PI*2.);

        cpos-=croff*sc;
        cpos+=sc*8.;
        vec2 bcp=cpos;
	
		float m=10.+i;

        if(i==0.){
            putDigit(1.,buv,sc,m, res, cpos);
            cpos=bcp+vec2(16.*sc.x,0.);
            putDigit(2.,buv,sc,m, res, cpos);
        }else if(i>=10.){
            putDigit(1.,buv,sc,m, res, cpos);
            cpos=bcp+vec2(16.*sc.x,0.);
            putDigit(i-10.,buv,sc,m, res, cpos);
        }else{
            putDigit(i,buv,sc,m, res, cpos);
        }
        //        char_32(buv,sc);
    }
}


float isInside( vec2 p, vec2 c ) { vec2 d = abs(p-0.5-c) - 0.5; return -max(d.x,d.y); }
//float isInside( vec2 p, vec4 c ) { vec2 d = abs(p-0.5-c.xy-c.zw*0.5) - 0.5*c.zw - 0.5; return -max(d.x,d.y); }

vec4 loadValue( in vec2 re, in vec2 iChannelResolution )
{
    return texture( iChannel0, (0.5+re) / iChannelResolution.xy, -100.0 );
}
void storeValue( in vec2 re, in vec4 va, inout vec4 fragColor, in vec2 fragCoord )
{
    fragColor = ( isInside(fragCoord,re) > 0.0 ) ? va : fragColor;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord, in vec2 iResolution, in vec2 iChannelResolution)
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    uv.y/=iResolution.x/iResolution.y;

    vec3 col=vec3(0.);
    vec2 res=vec2(-100.);

    vec4 sres=loadValue(vec2(0.), iChannelResolution);
    if(sres.xy==iResolution) {
//if resolution has NOT changed, copy the clock face buffer to the clock face buffer;
        fragColor = vec4(texture(iChannel0,fragCoord/iResolution.xy).rgb,1.0);
       return;
    }
//if resolution HAS changed, draw the clock face to the buffer;
    
    hours(uv);
    minutes(uv);
   
    col=vec3(0., res.x, res.y);
    fragColor = vec4(col,1.0);
    storeValue( vec2(0.), vec4(vec2(iResolution), vec2(0.)), fragColor, fragCoord );

}

void fragment(){
	vec2 iResolution = 1./SCREEN_PIXEL_SIZE;
	vec2 iChannelResolution = 1./TEXTURE_PIXEL_SIZE;
	vec2 fragCoord = FRAGCOORD.xy;
	mainImage(COLOR, fragCoord, iResolution, iChannelResolution);
}