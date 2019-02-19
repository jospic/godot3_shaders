# Godot Rayleigh/Mie sky asset

Introduction
------------
This is my implementation of a rayleigh/mie sky asset for the Godot engine. The standard procedural panoramic sky doesn't really cut it and using a static image has it's own issues.

The technique for coloring the sky itself is well known and well documented. If you google for rayleigh and mie you'll find a treasure trove of articles on the subject.

While I had implemented my own version I found some GLSL code from Rye Terrell that he kindly donated to the public domain. It was basically a copy paste to make it work in Godot and that has formed the basis of this.

One thing to keep in mind is that the technique at heart is basically a simplified raytracer and while it is fairly optimised it can still keep your GPU busy. 
Also for Godot it isn't enough to just render the background. You could just render a 2D rectangle in the background each frame with this logic instead of using the panoramic sky functionality.

However the panoramic sky does more then just render the background, it is also heavily applied in the PBR renderer and to make this work the image data is applied to special buffers that handle this.

As a result we're not just rendering the background at a much higher resolution then is visible in a single frame, we're also updating several internal textures used by the material shader. All very costly if we would be doing that each and every frame.

Luckily....

The sun doesn't move very quickly accross the sky and updating the generated image every frame isn't a very useful exercise. Instead the approach I've taken is that the background image is just rendered once and it sits there happily until you change one of its parameters.

Therefor, _don't_ call the ```set_sun_position``` method each frame as it will trigger updating the image:) Instead call it whenever your sun has actually moved through the sky.

There is also a one or two frame delay before the sky is updated, this is a temporary workaround as Godot does not have a mechanism (as far as I know) for letting us know the viewport has actually finished rendering when using the render once approach.

How to use this asset
---------------------
If you've chosen to download this asset in its intirety you'll have gotten a sample scene that you can evaluate but for your own project you will just want to have the *sky* subfolder in *addons*

You will either want to use an environment added to your camera or use a WorldEnvironment node. Make sure the *Local To Scene* property in the *Resource* group of the environment is turned on.
Then set the *Mode* in the *Background* group to Sky and create a *PanoramaSky*, you can leave the texture empty for now. For the panorama sky you should also turn *Local To Scene* on.

Now add the scene *addons/sky/sky_texture.tscn* as a subscene into your project.
Then hook up the *sky_updated* signal to a function in your scene.

This signal will be issued when a new sky texture is available so you can assign that to the panoramic sky. It is important to (re)do this whenever the sky texture is updated because it is this action that immediately triggers Godot to update all the internal buffers that make the PBR shaders work.
Because of some internal reasons I haven't fully investigated yet you need to make a copy of the Viewport Texture of the Viewport for this to work properly. I have added a convenience method so you can simply copy the following code into your signal function:
```
func _on_Sky_texture_sky_updated():
	$Sky_texture.copy_to_environment(get_viewport().get_camera().environment)
```

If you want a nice night sky an option was added to use a panoramic sky texture with stars that is mixed in when the sky gets dark. Just assign this to the night sky property of the viewport.
I'm still looking into adding a reprojection here.

You can change the positioning of the sun in the sky by assinging *sun_position* however purely using the skymap for illuminations does not result in things like shadows. Adding a directional light for your sun is still a good idea. For this another convenience method was added which sets the sun position based on the hour of the day, optionally takes a directional light node as a parameter and a setting that allows you to horizontally rotate the suns position:
```
	# set the time of day to 10:30am
	$Sky_texture.set_time_of_day(10.5, get_node("DirectionalLight"), deg2rad(15.0))

```

More properties will be exposed in the near future so you can change the colouring of the sky.

Licensing
---------
The source code that makes up the sky renderer is released under an MIT License.

The original GLSL shader this works is based on falls under an unlicense license.
Please visit https://github.com/wwwtyro/glsl-atmosphere for more information.

The star background image is:
Gigagalaxy Zoom: Milky Way 
Credit: ESO / Serge Brunier, Frederic Tapissier - Copyright: Serge Brunier (TWAN)
https://apod.nasa.gov/apod/ap090926.html
(if anyone has something that can be released under CC0 or so, please let me know)

About this repository
---------------------
This repository was created by and is maintained by Bastiaan Olij a.k.a. Mux213

You can follow me on twitter for regular updates here:
https://twitter.com/mux213

Videos about my work with Godot including tutorials on working with VR in Godot can by found on my youtube page:
https://www.youtube.com/channel/UCrbLJYzJjDf2p-vJC011lYw
