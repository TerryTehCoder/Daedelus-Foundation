/particles/droplets
	icon = 'icons/effects/particles/generic.dmi'
	icon_state = list("dot"=2,"drop"=1)
	width = 32
	height = 36
	count = 5
	spawning = 0.2
	lifespan = 1 SECONDS
	fade = 0.5 SECONDS
	color = "#549EFF"
	position = generator(GEN_BOX, list(-9,-9,0), list(9,18,0), NORMAL_RAND)
	scale = generator(GEN_VECTOR, list(0.9,0.9), list(1.1,1.1), NORMAL_RAND)
	gravity = list(0, -0.9)

/particles/splash
	icon = 'icons/effects/particles/generic.dmi'
	icon_state = list("drop"=4,"drip"=3,"dot"=2)
	width = 48
	height = 48
	count = 15
	spawning = 0
	lifespan = 0.8 SECONDS
	fade = 0.3 SECONDS
	color = "#E0F7FA"
	position = generator(GEN_CIRCLE, 1, 1, NORMAL_RAND)
	scale = generator(GEN_VECTOR, list(1.2,1.2), list(1.8,1.8), NORMAL_RAND)
	velocity = generator(GEN_VECTOR, list(-1.5, -2.0), list(1.5, -1.0), NORMAL_RAND)
	gravity = list(0, 0.5)

/particles/wave
	icon = 'icons/effects/particles/generic.dmi'
	icon_state = list("dot"=5,"curl"=3,"cross"=1)
	width = 48
	height = 48
	count = 15
	spawning = 0
	lifespan = 1.2 SECONDS
	fade = 0.4 SECONDS
	color = "#549EFF"
	position = generator(GEN_BOX, list(-12,-12,0), list(12,12,0), NORMAL_RAND)
	scale = generator(GEN_VECTOR, list(0.8,0.8), list(1.4,1.4), NORMAL_RAND)
	velocity = generator(GEN_VECTOR, list(-0.3, -0.2), list(0.3, 0.2), NORMAL_RAND)
	gravity = list(0, -0.05)

/particles/whitecap
	icon = 'icons/effects/particles/generic.dmi'
	icon_state = list("dot"=3,"square"=1,"rectangle"=1)
	width = 32
	height = 32
	count = 8
	spawning = 0
	lifespan = 0.8 SECONDS
	fade = 0.3 SECONDS
	color = "#FFFFFF"
	position = generator(GEN_CIRCLE, 1, 1, NORMAL_RAND)
	scale = generator(GEN_VECTOR, list(1.0,1.0), list(1.6,1.6), NORMAL_RAND)
	velocity = generator(GEN_VECTOR, list(-0.5, -0.8), list(0.5, -0.3), NORMAL_RAND)
	gravity = list(0, 0.1)

/particles/wave_crest
	icon = 'icons/effects/particles/generic.dmi'
	icon_state = list("cross"=2,"up_arrow"=1)
	width = 24
	height = 24
	count = 3
	spawning = 0
	lifespan = 0.5 SECONDS
	fade = 0.1 SECONDS
	color = "#FFFFFF"
	position = generator(GEN_VECTOR, list(-6,0,0), list(6,0,0), UNIFORM_RAND)
	scale = generator(GEN_VECTOR, list(1.5,1.5), list(2.0,2.0), NORMAL_RAND)
	velocity = generator(GEN_VECTOR, list(-0.2, 0.5), list(0.2, 1.0), NORMAL_RAND)
