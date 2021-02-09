extends Node2D

#two uniforms
var iTime=0.0
var iFrame=0

func _ready():
	pass

func _process(delta):
	iTime+=delta
	iFrame+=1
