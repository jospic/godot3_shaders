shader_type canvas_item;

uniform float earth_radius_km = 6371;
uniform float atmo_radius_km = 6471;
uniform float cam_height_m = 1.8;
uniform vec3 sun_pos = vec3(0.0, 0.1, -0.5);
uniform float sun_intensity = 22.0;
uniform vec3 rayleigh_coeff = vec3(5.5, 13.0, 22.4); // we divide this by 100000
uniform float mie_coeff = 21.0; // we divide this by 100000
uniform float rayleigh_scale = 800;
uniform float mie_scale = 120;
uniform float mie_scatter_dir = 0.758;

uniform sampler2D night_sky : hint_black_albedo;
uniform mat3 rotate_night_sky;

// Atmosphere code from: https://github.com/wwwtyro/glsl-atmosphere
vec2 rsi(vec3 r0, vec3 rd, float sr) {
	// ray-sphere intersection that assumes
	// the sphere is centered at the origin.
	// No intersection when result.x > result.y
	float a = dot(rd, rd);
	float b = 2.0 * dot(rd, r0);
	float c = dot(r0, r0) - (sr * sr);
	float d = (b*b) - 4.0*a*c;
	if (d < 0.0) return vec2(1e5,-1e5);
	return vec2(
		(-b - sqrt(d))/(2.0*a),
		(-b + sqrt(d))/(2.0*a)
	);
}

vec3 atmosphere(vec3 r, vec3 r0, vec3 pSun, float iSun, float rPlanet, float rAtmos, vec3 kRlh, float kMie, float shRlh, float shMie, float g) {
	float PI = 3.14159265358979;
	int iSteps = 16;
	int jSteps = 8;

	// Normalize the sun and view directions.
	pSun = normalize(pSun);
	r = normalize(r);

	// Calculate the step size of the primary ray.
	vec2 p = rsi(r0, r, rAtmos);
	if (p.x > p.y) return vec3(0,0,0);
	p.y = min(p.y, rsi(r0, r, rPlanet).x);
	float iStepSize = (p.y - p.x) / float(iSteps);

	// Initialize the primary ray time.
	float iTime = 0.0;

	// Initialize accumulators for Rayleigh and Mie scattering.
	vec3 totalRlh = vec3(0,0,0);
	vec3 totalMie = vec3(0,0,0);

	// Initialize optical depth accumulators for the primary ray.
	float iOdRlh = 0.0;
	float iOdMie = 0.0;

	// Calculate the Rayleigh and Mie phases.
	float mu = dot(r, pSun);
	float mumu = mu * mu;
	float gg = g * g;
	float pRlh = 3.0 / (16.0 * PI) * (1.0 + mumu);
	float pMie = 3.0 / (8.0 * PI) * ((1.0 - gg) * (mumu + 1.0)) / (pow(1.0 + gg - 2.0 * mu * g, 1.5) * (2.0 + gg));

	// Sample the primary ray.
	for (int i = 0; i < iSteps; i++) {
		// Calculate the primary ray sample position.
		vec3 iPos = r0 + r * (iTime + iStepSize * 0.5);

		// Calculate the height of the sample.
		float iHeight = length(iPos) - rPlanet;

		// Calculate the optical depth of the Rayleigh and Mie scattering for this step.
		float odStepRlh = exp(-iHeight / shRlh) * iStepSize;
		float odStepMie = exp(-iHeight / shMie) * iStepSize;

		// Accumulate optical depth.
		iOdRlh += odStepRlh;
		iOdMie += odStepMie;

		// Calculate the step size of the secondary ray.
		float jStepSize = rsi(iPos, pSun, rAtmos).y / float(jSteps);

		// Initialize the secondary ray time.
		float jTime = 0.0;

		// Initialize optical depth accumulators for the secondary ray.
		float jOdRlh = 0.0;
		float jOdMie = 0.0;

		// Sample the secondary ray.
		for (int j = 0; j < jSteps; j++) {
			// Calculate the secondary ray sample position.
			vec3 jPos = iPos + pSun * (jTime + jStepSize * 0.5);

			// Calculate the height of the sample.
			float jHeight = length(jPos) - rPlanet;

			// Accumulate the optical depth.
			jOdRlh += exp(-jHeight / shRlh) * jStepSize;
			jOdMie += exp(-jHeight / shMie) * jStepSize;

			// Increment the secondary ray time.
			jTime += jStepSize;
		}

		// Calculate attenuation.
		vec3 attn = exp(-(kMie * (iOdMie + jOdMie) + kRlh * (iOdRlh + jOdRlh)));

		// Accumulate scattering.
		totalRlh += odStepRlh * attn;
		totalMie += odStepMie * attn;

		// Increment the primary ray time.
		iTime += iStepSize;

	}

	// Calculate and return the final color.
	return iSun * (pRlh * kRlh * totalRlh + pMie * kMie * totalMie);
}

// and our application

vec3 ray_dir_from_uv(vec2 uv) {
	float PI = 3.14159265358979;
	vec3 dir;
	
	float x = sin(PI * uv.y);
	dir.y = cos(PI * uv.y);
	
	dir.x = x * sin(2.0 * PI * (0.5 - uv.x));
	dir.z = x * cos(2.0 * PI * (0.5 - uv.x));
	
	return dir;
}

vec2 uv_from_ray_dir(vec3 dir) {
	float PI = 3.14159265358979;
	vec2 uv;
	
	uv.y = acos(dir.y) / PI;
	
	dir.y = 0.0;
	dir = normalize(dir);
	uv.x = acos(dir.z) / (2.0 * PI);
	if (dir.x < 0.0) {
		uv.x = 1.0 - uv.x;
	}
	uv.x = 0.5 - uv.x;
	if (uv.x < 0.0) {
		uv.x += 1.0;
	}
	
	return uv;
}

void fragment() {
	vec3 dir = ray_dir_from_uv(UV);
	
	// determine our sky color
	vec3 color = atmosphere(
		dir
		, vec3(0.0, earth_radius_km * 100.0 + cam_height_m * 0.1, 0.0)
		, sun_pos
		, sun_intensity
		, earth_radius_km * 100.0
		, atmo_radius_km * 100.0
		, rayleigh_coeff / 100000.0
		, mie_coeff / 100000.0
		, rayleigh_scale
		, mie_scale
		, mie_scatter_dir
	);
	
	// Apply exposure.
	color = 1.0 - exp(-1.0 * color);
	
	// Mix in night sky (already sRGB)
	if (dir.y > 0.0) {
		float f = (0.21 * color.r) + (0.72 * color.g) + (0.07 * color.b);
		float cutoff = 0.1;
		
		vec2 ns_uv = uv_from_ray_dir(rotate_night_sky * dir);
		color += texture(night_sky, ns_uv).rgb * clamp((cutoff - f) / cutoff, 0.0, 1.0);
	}
	
	COLOR = vec4(color, 1.0);
}