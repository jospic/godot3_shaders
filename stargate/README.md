# Abstract Terrain Objects (stargate) 

This is a converted demo for Godot 3 from original example by ShaderToy https://www.shadertoy.com/view/ttXGWH
Compared to the original version, I used a different algorithm for terrain noise, 
inspired by: https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83

In particular I used a following generic noise:

```glsl
float rand(vec2 n) { 
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 p){
	vec2 ip = floor(p);
	vec2 u = fract(p);
	u = u*u*(3.0-2.0*u);
	
	float res = mix(
		mix(rand(ip),rand(ip+vec2(1.0,0.0)),u.x),
		mix(rand(ip+vec2(0.0,1.0)),rand(ip+vec2(1.0,1.0)),u.x),u.y);
	return res*res;
}
```

I have inserted buttons on the right that allow you to change the shape at runtime, being able to choose between rectangle, square, circular, triangular, hexagon and octagon.

![Stargate](./thumb/stargate.gif "Abstract Terrain Objects (stargate) in Godot 3")

Donations
---------
Was this project useful for you? Wanna make a donation? These are the options:

### Paypal

My [Paypal donation link](https://www.paypal.me/donatejospic?locale.x=it_IT)