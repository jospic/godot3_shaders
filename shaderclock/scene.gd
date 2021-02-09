extends Node2D

#two uniforms
var iTime=0.0
var iDate=0.0
var iFrame=0

func _ready():
	pass

func _process(delta):
	iDate = OS.get_time().hour * 3600 + OS.get_time().minute * 60 + OS.get_time().second
	iTime+=delta
	iFrame+=1
