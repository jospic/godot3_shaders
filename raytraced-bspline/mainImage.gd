extends Sprite

onready var global_v=get_tree().get_root().get_node("scene")

#bind textures as samler2D to shader
#do it here to prevent "errors" from Godot(and crash in HTML5 build)
#this logic should work same like Shadetroy
func _ready():
	for i in range(1):
		var cnode=global_v.get_node("iChannel"+str(i)+"/Sprite")
		for j in range(1):
			if(i!=j):
				var iChannel=global_v.get_node("iChannel"+str(j)).get_viewport().get_texture()
				#set flags, read this to set other flags if need
				#https://docs.godotengine.org/en/3.1/classes/class_texture.html
				iChannel.flags=Texture.FLAG_FILTER
				cnode.material.set("shader_param/iChannel"+str(j),iChannel)
			else:
				var iChannel=global_v.get_node("iChannel_buf"+str(j)).get_viewport().get_texture()
				#same
				iChannel.flags=Texture.FLAG_FILTER
				cnode.material.set("shader_param/iChannel"+str(j),iChannel)

#uniforms
func _process(delta):
	self.material.set("shader_param/iTime",global_v.iTime)
	self.material.set("shader_param/iFrame",global_v.iFrame)
