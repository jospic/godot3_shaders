shader_type canvas_item;
render_mode blend_disabled;

uniform float iTime;
uniform int iFrame;
uniform sampler2D iChannel0;
uniform sampler2D iChannel1;



// Raytracing a surface-of-revolution defined by a quadratic B-spline, by splitting the spline
// into sections which can each be expressed as quadratic polynomial.
//
// This is much faster than raymarching!
//
// See the comments throughout the code for details.


// Supersampled anti-aliasing level. Sample count = AA x AA.
uniform int AA = 2;

uniform int MAX_RAY_PATH_DEPTH = 16;


// Evaluate quadratic polynomial with given coefficients.
float applyCoeffs(vec3 coeffs, float x)
{
    return (x * coeffs.x + coeffs.y) * x + coeffs.z;
}

// Polynomial coefficient factors for a section of a 1D quadratic uniform B-spline.
vec3 coeffsForCP(float i)
{
    if(i < 1.)
        return vec3(.5, 0, 0);
    else if(i < 2.)
        return vec3(-1., 1., .5);
    return vec3(.5, -1., .5);
}

// Functions solve_quadric, solve_cubic, solve_quartic, and absmax are from Wyatt's
// quartic solver collection: https://www.shadertoy.com/view/XddfW7

int solve_quadric(vec2 coeffs, inout vec2 roots){
    float p = coeffs.y / 2.;
    float D = p*p - coeffs.x;
    if (D <= 0.) return 0;
    else {
        roots = vec2(-1, 1)*sqrt(D) - p;
        return 2;
    }
}
int solve_cubic(vec3 coeffs, inout vec3 r){
    float a = coeffs[2];
    float b = coeffs[1];
    float c = coeffs[0];
    float p = b - a*a/3.;
    float q = a * (2.*a*a - 9.*b)/27. + c;
    float p3 = p*p*p;
    float d = q*q + 4.*p3/27.;
    float offset = -a/3.;
    if(d >= 0.0) { 
        vec2 uv = (vec2(1, -1)*sqrt(d) - q)/2.;
        uv = uv = sign(uv)*pow(abs(uv), vec2(1./3.));
        r[0] = offset + uv.x + uv.y;	
        float f = ((r[0] + a)*r[0] + b)*r[0] + c;
        float f1 = (3.*r[0] + 2. * a)*r[0] + b;
        r[0] -= f/f1;
        return 1;
    }
    float u = sqrt(-p/3.);
    float v = acos(-sqrt(-27./p3)*q/2.)/3.;
    float m = cos(v), n = sin(v)*1.732050808;
    float f,f1;
    r[0] = offset + u * (m + m);
    f = ((r[0] + a)*r[0] + b)*r[0] + c;
    f1 = (3.*r[0] + 2. * a)*r[0] + b;
    r[0] -= f / f1;
    r[1] = offset - u * (n + m);
    f = ((r[1] + a)*r[1] + b) * r[1] + c;
    f1=(3.*r[1] + 2. * a)*r[1] + b;
    r[1] -= f / f1;
    r[2] = offset + u * (n - m);
    f = ((r[2] + a)*r[2] + b)*r[2] + c;
    f1 = (3.*r[2] + 2. * a)*r[2] + b;
    r[2] -= f / f1;
    return 3;
}
bvec4 solve_quartic(vec4 coeffs, inout vec4 s){
    bvec4 broots;
    float a = coeffs[0];
    float b = coeffs[1];
    float c = coeffs[2];
    float d = coeffs[3];
    float sq_a = a * a;
    float p = - 3./8. * sq_a + b;
    float q = 1./8. * sq_a * a - 1./2. * a * b + c;
    float r = - 3./256.*sq_a*sq_a + 1./16.*sq_a*b - 1./4.*a*c + d;
    int num;
    vec3 cubic_coeffs;
    cubic_coeffs[0] = 1.0/2. * r * p - 1.0/8. * q * q;
    cubic_coeffs[1] = - r;
    cubic_coeffs[2] = - 1.0/2. * p;
    solve_cubic(cubic_coeffs, s.xyz);
    float z = s[0];
    float u = z * z - r;
    float v = 2. * z - p;
    if(u > 0.) u = sqrt(abs(u));
    else return bvec4(false);
    if(v > 0.) v = sqrt(abs(v));
    else return bvec4(false);
    vec2 quad_coeffs;
    quad_coeffs[0] = z - u;
    quad_coeffs[1] = q < 0. ? -v : v;
    num = solve_quadric(quad_coeffs, s.xy);
    if (num == 0) broots.xy = bvec2(false);
    if (num == 2) broots.xy = bvec2(true);
    quad_coeffs[0] = z + u;
    quad_coeffs[1] = q < 0. ? v : -v;
    vec2 tmp = vec2(1e8);
    int old_num = num;
    num = solve_quadric(quad_coeffs, s.zw);
    if (num == 0) broots.zw = bvec2(false);
    if (num == 2) broots.zw = bvec2(true);
    s -= a/4.;
    
//if 0
    // Newton-Raphson iteration to improve precision
    s -= ((((s + a) * s + b) * s + c) * s + d) / 
        (((4. * s + 3. * a) * s + 2. * b) * s + c);
//endif
    
    return broots;
}

float absmax(float a, float b) {
	if (b>1e-3) return max(a,b);
    return a;
}

// Ray-cylinder intersection.
vec2 intersectCylinder(vec2 ro, vec2 rd, float r)
{
    float a = dot(rd, rd);
    float b = 2.0 * dot(rd, ro);
    float c = dot(ro, ro) - r * r;
    float desc = b * b - 4.0 * a * c;
    if (desc < 0.0)
        return vec2(1.0, 0.0);

    return vec2((-b - sqrt(desc)) / (2.0 * a), (-b + sqrt(desc)) / (2.0 * a));
}

// Ray-box intersection.
vec2 box(vec3 ro,vec3 rd,vec3 p0,vec3 p1)
{
    vec3 t0 = (mix(p1, p0, step(0., rd * sign(p1 - p0))) - ro) / rd;
    vec3 t1 = (mix(p0, p1, step(0., rd * sign(p1 - p0))) - ro) / rd;
    return vec2(max(t0.x, max(t0.y, t0.z)),min(t1.x, min(t1.y, t1.z)));
}

// Performs ray-versus-swept-curve intersection test, and computes surface normal
// at the intersection if it exists.
// The surface is a radially-swept quadratic curve and the intersection test requires
// solving a quartic (degree 4) equation.
vec4 intersectSection(vec3 ro, vec3 rd, vec3 quadCoeffs, vec2 hs)
{
    ro.y -= hs.x;
    hs.y -= hs.x;
    hs.x = -1e-3;
    hs.y += 1e-3;
    
    // Differentiate the profile curve to find the inflection point, in order to calculate
    // a radius for the bounding cylinder of this section.
    vec2 differentialLine = vec2(2. * quadCoeffs.x, quadCoeffs.y);
    float inflectionPoint = (0. - differentialLine.y) / differentialLine.x;
    
    float r0 = applyCoeffs(quadCoeffs, 0.);
    float r1 = applyCoeffs(quadCoeffs, 1.);
    
    float cylinderRadius = max(r0, r1);
    
    if(inflectionPoint >= 0. && inflectionPoint < 1.)
    	cylinderRadius = max(cylinderRadius, applyCoeffs(quadCoeffs, inflectionPoint));
    
    // Test the ray against a capped bounding cylinder for early rejection.
    
    vec2 is = intersectCylinder(ro.xz, rd.xz, cylinderRadius + 1e-2);

    vec2 planeIntersections = (hs.xy - ro.y) / rd.y;
    
    if(rd.y > 0.)
        is.x = max(is.x, planeIntersections.x);
    else
        is.y = min(is.y, planeIntersections.x);
    
    if(rd.y < 0.)
        is.x = max(is.x, planeIntersections.y);
    else
        is.y = min(is.y, planeIntersections.y);
        
    if(is.y < 1e-3 || is.x > is.y)
        return vec4(1e4, 0, 0, 0);
    
    is.x = max(0., is.x);
    
    // Offset the ray start position along the ray to the bounding cylinder intersection, to
    // gain some precision in the quartic solver.
    ro += rd * is.x;

    // Note that Z and Y are swapped here. This is because the up vector of the scene is Y, but
    // the axis of revolution for my swept curve is Z.
    float ox = ro.x, oy = ro.z, oz = ro.y;
    float dx = rd.x, dy = rd.z, dz = rd.y;
    
    // Quadratic profile curve coefficients.
    float a = quadCoeffs.x, b = quadCoeffs.y, c = quadCoeffs.z;
    
    // The equation to solve is d² = (az² + bz + c)²
    // Where d is length(vec2(ox, oy) + t * vec2(dx, dy)) and z is oz + t * dz.
    // This yields a quartic polynomial equation in t.
    
    vec4 coeffs;
    
    float c4 = -(a * a * dz * dz * dz * dz);
    
    coeffs.x = -2. * dz *(2. * a * a * oz *  dz * dz + a * b * dz * dz);

    coeffs.y = dx * dx + dy * dy - 
        dz * ((oz * 6. * a * a * dz + 6. * a * b * dz) * oz + 2. * a * c * dz + b * dz * b);
    
    coeffs.z = 2. * ((ox * dx + oy * dy) - 
        dz * (((oz * 2. * a * a + 3. * a * b) * oz + 2. * a * c + b * b) * oz + b * c));

    coeffs.w = ox * ox + oy * oy -
		((((oz * a * a + 2. * b * a) * oz + 2. * a * c + b * b) * oz + 2. * b * c) * oz + c * c);

    // Since solve_quartic works on a so-called 'depressed quartic', the coefficients would normally
    // be divided by c4 (the 4th-order coefficient). However, this coefficient very quickly
    // approaches zero as dz approaches zero, which eventually results in catastrophic cancellation
    // during the root-finding process.
    // To overcome this, I'm using a trick which I learned from IQ: The order of the coefficients
    // is reversed so that the division is by the constant term instead. The solution to this
    // equation is 1 / t, hence the calculation of t as 1 / i.
    
    vec4 roots;
    bvec4 br = solve_quartic(vec4(coeffs.z, coeffs.y, coeffs.x, c4) / coeffs.w, roots);
    float i = -1.;
    
    if (br.x)
        i = absmax(i, roots.x);
    if (br.y)
        i = absmax(i, roots.y);
    if (br.z)
        i = absmax(i, roots.z);
    if (br.w)
       	i = absmax(i, roots.w);
    
    float t = 1. / i;
    
    if(t < 1e-3 || t > (is.y - is.x))
        return vec4(1e4, 0, 0, 0);
    
    vec3 p = ro + rd * t;
    vec3 tangent_u = vec3(p.z, 0, -p.x);
    vec3 tangent_v = vec3(normalize(p.xz) * (differentialLine.y + differentialLine.x * p.y), 1.).xzy;
    vec3 normal = cross(tangent_u, tangent_v);

    return vec4(is.x + t, normal);
}

// Perform intersection tests against each section of a surface defined by a radially-swept
// 1D quadratic uniform B-spline. A section is a range of the parameter domain between two
// control points, over which the set of contributing points is constant. 
vec4 traceSurface(float[10] controlPoints, vec3 ro, vec3 rd, int N)
{
    float mt = 1e3;
    vec3 normal;
    
    for(int i = 0; i < N; ++i)
    {
        // Sections are non-overlapping and ordered along a line (the axis of revolution), so
        // it's easy to order them along a ray.
        int j = (rd.y > 0. ? i : N - 1 - i);
        
        // The polynomial coefficients can be expressed as a linear combination of the 3 contributing
        // control points.
        float h = float(j);
        vec3 coeffs = 	coeffsForCP(2.) * controlPoints[j] +
            			coeffsForCP(1.) * controlPoints[j + 1] +
            			coeffsForCP(0.) * controlPoints[j + 2];
        
        vec4 res = intersectSection(ro, rd, coeffs, vec2(h, h + 1.));

        if(res.x > 1e-3 && res.x < mt)
        {
            normal = res.yzw;
            mt = res.x;
            // Breaking on the first intersection found is safe due to the axial ordering.
            break;
        }
    }
    
    return vec4(mt, normal);
}

vec3 sampleEnv(vec3 ro, vec3 rd)
{
    if(rd.y < 0.)
    {
		// Include the (parallax-correct) floor in the environment, because it's cheap to do so.
    	float floort = -ro.y / rd.y;
        vec2 uv = ro.xz + rd.xz * floort;
        if(floort > 0. && floort < 1e4 && max(abs(uv.x), abs(uv.y)) < 15.)
        {
            return texture(iChannel1, uv / 20.).rgb / 2.5;
        }
    }
    // Sample the environment map.
    return texture(iChannel0, rd.zyx, 2.).rgb;
}

vec4 traceScene(vec3 ro, vec3 rd, out int objid)
{
    float mt = 1e3;
    vec3 normal;
    
    objid = 0;
    
    // Floor object
    if(rd.y < 0.)
    {
    	float floort = (0. - ro.y) / rd.y;
        vec2 uv = ro.xz + rd.xz * floort;
        if(floort > 0. && floort < mt && abs(uv.x) < 15. && abs(uv.y) < 15.)
        {
            mt = floort;
            normal = vec3(0, 1, 0);
            objid = 1;
        }
    }
    
    vec4 res;
    float sc = .52;
    
    vec2 wineglass_box_is = box(ro, rd, vec3(-1.6, 0., -1.6), vec3(1.6, 10, 1.6));
    
    if(wineglass_box_is.x < wineglass_box_is.y)
    {
        // Wineglass (outer)
        res = traceSurface(float[10](2.5, .1, .1, .1, .1, 1.1, 1.6, 1.5, 1.2, 1.), ro, rd, 8);
        if(res.x > 1e-3 && res.x < mt)
        {
            mt = res.x;
            normal = res.yzw;
            objid = 2;
        }


        // Wineglass (inner)
        res = traceSurface(float[10](0., 0., 0., 0., 0., 1., 1.5, 1.4, 1.1, .9), ro, rd, 8);
        if(res.x > 1e-3 && res.x < mt)
        {
            mt = res.x;
            normal = -res.yzw;
            objid = 3;
        }


        // Glass wine surface
        {
            float t = (6. - ro.y) / rd.y;
            if(t > 1e-3 && t < mt)
            {
                vec3 p = ro + rd * t;
                if(length(p.xz) < 1.45)
                {
                    mt = t;
                    normal = vec3(0, -1, 0);
                    objid = 3;
                }
            }
        }
    }
    
    vec3 bottle_pos = vec3(6,0,-2);
    vec2 winebottle_box_is = box((ro - bottle_pos), rd, vec3(-2, 0., -2), vec3(2, 15, 2));

    if(winebottle_box_is.x < winebottle_box_is.y)
    {
        // Wine bottle (outer)

        res = traceSurface(float[10](.9, 1., 1., 1., 1., 1., .6, .3, .3, .3), (ro - bottle_pos)  * sc, rd * sc, 8);
        if(res.x > 1e-3 && res.x < mt)
        {
            mt = res.x;
            normal = res.yzw;
            objid = 4;
        }

        // Wine bottle (inner)
        res = traceSurface(float[10](.9 - .1, 1. - .1, 1. - .1, 1. - .1, 1. - .1, 1. - .1,
                                     .6 - .1, .3 - .1, .3 - .1, .3 - .1), (ro - bottle_pos)  * sc, rd * sc, 8);
        if(res.x > 1e-3 && res.x < mt)
        {
            mt = res.x;
            normal = -res.yzw;
            objid = 5;
        }
    }
    
    vec3 vase_pos = vec3(5, 0, 7);
    vec2 vase_box_is = box((ro - vase_pos), rd, vec3(-3.5, 0., -3.5), vec3(3.5, 12, 3.5));

    if(vase_box_is.x < vase_box_is.y)
    {
        float sc = .45;

        // Water vase (outer)
        res = traceSurface(float[10](.1, 1.5, 1.5, 1.5, .5, .5, 1.6, 0., 0., 0.),
                           (ro - vase_pos)  * sc, rd * sc, 5);
        if(res.x > 1e-3 && res.x < mt)
        {
            mt = res.x;
            normal = res.yzw;
            objid = 6;
        }


        // Water vase (inner)
        res = traceSurface(float[10](.1 - .1, 1.5 - .1, 1.5 - .1, 1.5 - .1, .5 - .1, .5 - .1, 1.6 - .1, 0., 0., 0.),
                           (ro - vase_pos)  * sc, rd * sc, 5);
        if(res.x > 1e-3 && res.x < mt)
        {
            mt = res.x;
            normal = -res.yzw;
            objid = 7;
        }

        // Vase water surface
        {
            float t = (2. - ro.y) / rd.y;
            if(t > 1e-3 && t < mt)
            {
                vec3 p = ro + rd * t;
                if(length(p.xz - vase_pos.xz) < 1.4 / sc)
                {
                    mt = t;
                    normal = vec3(0, -1, 0);
                    objid = 7;
                }
            }
        }
    }
    

    return vec4(mt, normal);
}
    
mat3 rotX(float a)
{
    return mat3(1., 0., 0., 0., cos(a), sin(a), 0., -sin(a), cos(a));
}

mat3 rotY(float a)
{
    return mat3(cos(a), 0., sin(a), 0., 1., 0., -sin(a), 0., cos(a));
}

mat3 rotZ(float a)
{
    return mat3(cos(a), sin(a), 0., -sin(a), cos(a), 0., 0., 0., 1.);
}

void render(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy * 2. - 1.;
	uv.x *= iResolution.x / iResolution.y;
    
    // Camera position and target.
    vec3 campos = vec3(0, -.5, 22);
    campos.y += 3.2;
    vec3 camtarget = vec3(0, -.5, 0);
	vec3 ro = campos, rd = normalize(vec3(uv, 3.5));
    
    // Camera lookat.
    vec3 w = normalize(camtarget - campos);
    vec3 u = normalize(cross(vec3(0, 1, 0), w));
    vec3 v = cross(w, u);
    rd = mat3(u, v, w) * rd;

	// Scene rotation and positioning
    mat3 m = rotY(.9 + cos(iTime / 9.) * 1.5);
    ro = m * ro + vec3(2, 5.5, 1.);
    rd = m * rd;
    
    fragColor.rgb = vec3(0);
    
    vec3 fac = vec3(1);
    float ray_ior = 1.;
    float ray_spread = 0.;
    
    for(int i = 0; i < MAX_RAY_PATH_DEPTH; ++i)
    {
        rd = normalize(rd);
        int objid;
        vec4 res = traceScene(ro, rd, objid);

        if(res.x > 1e2)
        {
            // Ray escaped the scene. Sample the environment map.
            fragColor.rgb += texture(iChannel0, rd.zyx, 1.5 + ray_spread).rgb * fac;
            break;
        }

        vec3 normal = normalize(res.yzw);
        vec3 forwardNormal = faceforward(normal, rd, normal);
        vec3 rp = ro + rd * res.x;
        
        if(rp.y < 1e-2)
        {
            // Floor.
            float fr = mix(.2, .5, clamp(pow(1. - dot(rd, -forwardNormal), 2.), 0., 1.)) / 2.;
            fr *= smoothstep(.1, .7, texture(iChannel1, rp.xz / 20.).r);
            fragColor.rgb += texture(iChannel1, rp.xz / 20.).rgb * (1. - fr) * fac * .3;
            fac *= fr;
            ro += rd * (res.x + .001);
            rd = reflect(rd, normal);
            ray_spread += 1.;
        }
        else
        {
            // Fresnel term.
            float fr = mix(.022, .9, clamp(pow(1. - dot(rd, -forwardNormal), 3.), 0., 1.));

            // Use a different fresnel curve for liquids.
            if((objid == 7 && rp.y < 2.01) || (objid == 3 && rp.y < 6.01))
            	fr = mix(.05, .2, clamp(pow(1. - dot(rd, -forwardNormal), 3.), 0., 1.));

            float medium_ior;
            bool entering = dot(rd, normal) > 0.;
            
            // Apply object-dependent shading.
            
            if(objid == 5)
                fac *= vec3(.5,1.,.5) / 2.;
            
            if(objid == 5 && rp.y < 10.)
            	fac *= .1;
               
            if((objid == 3 && rp.y < 6.01) || (objid == 7 && rp.y < 2.01))
            {
                if(entering)
                {
                    medium_ior = 1.36;
                }
                else
                {
                    if(objid == 7)
                        fac *= exp(-res.x * vec3(4,4,1) / 100.);
                    else
                		fac *= exp(-res.x * vec3(1,4,4) / 1.);
                    medium_ior = (abs(res.z) == 1.) ? 1. : 1.5;
                }
            }
            else
            {
                medium_ior = !entering ? 1.5 : 1.0;
            }

            // Offset ray away from surface.
            ro += rd * (res.x + .02)*1.0;
            ro -= forwardNormal * 0.02 * (abs(dot(rd, normal)));
            
            // Take a non-shadowed environment sample.
            fragColor.rgb += sampleEnv(ro, reflect(rd, normal)) * fr * fac;
            
            fac *= 1. - fr;
            
            vec3 ord = rd;
            
            // Refract the ray.
            rd = refract(normalize(rd), forwardNormal, ray_ior / medium_ior);
            
            // Handle total internal reflection.
            if(rd == vec3(0))
               	rd = reflect(ord, normal);
            
            ray_ior = medium_ior;
            
            // Terminate paths which make too small a contribution.
            if(max(fac.r, max(fac.g, fac.b)) < .002)
                break;
        }
        
        // Always lose a small amount of energy on every bounce.
        fac *= .99;
    }
}

void mainImage( out vec4 fragColor, in vec2 fragCoord, in vec2 iResolution)
{
    vec2 uv = fragCoord / iResolution.xy * 2. - 1.;
	uv.x *= iResolution.x / iResolution.y;
    fragColor.rgb = vec3(0);
    
	for(int y = 0; y < AA; ++y)
        for(int x = 0; x < AA; ++x)
        {
            vec4 col = vec4(0);
            render(col, fragCoord + vec2(x, y) / float(AA));
            fragColor.rgb += max(col.rgb, 0.);
        }
    
    fragColor.rgb *= 1.2 / float(AA * AA);
    
    // Vignet,
    fragColor.rgb *= vec3(1. - (pow(abs(uv.x), 4.) + pow(abs(uv.y * 1.5), 4.)) * .04);
    
    // Tonemapping.
    fragColor.rgb /= (fragColor.rgb + 1.) * .5;
    
    // Gamma and dither.
    fragColor.rgb = pow(fragColor.rgb, vec3(1. / 2.2)) +
        				texelFetch(iChannel2, ivec2(fragCoord) & 1023, 0).rgb / 200.;
}


void fragment(){
	vec2 iResolution=1./TEXTURE_PIXEL_SIZE;
	mainImage(COLOR,UV*iResolution,iResolution);
}