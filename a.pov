#version 3.7;

global_settings {
	assumed_gamma 1.0
}

#default {
	pigment {
		color rgb 1
	}
	finish {
		phong 0 reflection 0
		ambient 0.0 diffuse 1.0
//		ambient 0.2 diffuse 0.8
		ambient 1
	}
}

#macro TriAxis(Vec)
union {
//	box { -Vec,Vec }
	box { -Vec,Vec rotate <90,0,0> }
	box { -Vec,Vec rotate <0,90,0> }
	box { -Vec,Vec rotate <0,0,90> }
}
#end

#macro ScopeBox(Center, Size, Corner)
#local Inner1 = 1-(Corner/Size*2);
#local Inner2 = 1-(Corner/Size  );
difference {
	box { -1,1 }
	union {
		TriAxis(<-Inner1,-2,-2>)
		TriAxis(<-Inner2,-Inner2,-3>)
	}
//	bounded_by { box { -1,1 } }
	scale Size/2
	translate Center
}	
#end

#macro Star(Center, Spoke, Core)
union {
	box { -Core/2, Core/2 }
	TriAxis(<1000,Spoke/2,Spoke/2>)
	translate Center
}
#end

//TriAxis(<-0.5,-2,-2>)
//TriAxis(<-2,-0.5,-0.5>)

#declare itpl = function(A,B,R) {
	A+R*(B-A)
}

#declare ease = function(X) {
	(cos(X*pi)+1)/2
}

#declare rotpause = 0.3;

#declare rotclock = (clock < rotpause ? 0 : ease((clock-rotpause) / (1-rotpause)));
//#declare rotclock = 0.4;

union {
	ScopeBox(<0,0,0>, 24, 8)
	rotate <-rotclock*90,-rotclock*90,0>
	scale itpl(1,0.5,rotclock)
}
union {
	ScopeBox(<0,0,0>, 12, 4)
	rotate <rotclock*90,0,rotclock*90>
	scale itpl(1,2,rotclock)
}
union {
	Star(<0,0,0>, 2, 6)
	translate <-100,0,0>
	rotate <rotclock*90,0,0>
}

#declare Camera_0 = camera { orthographic location <100, 0, 0>
                            look_at   <0.0 , 0.0 , 0.0>
							up 32*x right 32*y
                            }
#declare Camera_1 = camera { orthographic 
                            /*ultra_wide_angle*/ angle 10   // diagonal view
                            location  <200.0 , 200.0 ,-200.0>
                            right     x*image_width/image_height
                            look_at   <0.0 , 0.0 , 0.0>}
#declare Camera_2 = camera {/*ultra_wide_angle*/ angle 90  //right side view
                            location  <40.0 , 10.0 , 0.0>
                            right     x*image_width/image_height
                            look_at   <0.0 , 1.0 , 0.0>}
#declare Camera_3 = camera {/*ultra_wide_angle*/ angle 90        // top view
                            location  <0.0 , 40.0 ,-0.001>
                            right     x*image_width/image_height
                            look_at   <0.0 , 1.0 , 0.0>}
camera{Camera_0}

// Set a color of the background (sky)
background { color rgb< 1, 1, 1> }


//light_source { <10,20,-30> color rgb -1 }


//light_source { <0,0,-1e9> color rgb <1,1,1> }
//light_source { <0,0, 1e9> color rgb <1,1,1> }
//light_source { <0,-1e9,0> color rgb <1,1,1> }
//light_source { <0, 1e9,0> color rgb <1,1,1> }

//light_source { <1e5,0,0> color rgb <1,1,1> shadowless }
light_source { <1e5,0,0> color rgb -1 parallel point_at <0,0,0> shadowless }
