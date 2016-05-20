#version 3.7;

#ifdef (PhoneBoot)
  #declare ImageRatio = 2560/1440;
#else
  #declare ImageRatio = 1;
#end

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
	box { -Vec,Vec rotate <90,0,0> }
	box { -Vec,Vec rotate <0,90,0> }
	box { -Vec,Vec rotate <0,0,90> }
}
#end

#macro ScopeBox(Center, Size, Corner)
  #ifdef (Intro)
	#local NewSize=Size + 100*(1-rotclock);
  #else
	#local NewSize=Size;
  #end
#local Inner1 = 1-(Corner/NewSize*2);
#local Inner2 = 1-(Corner/NewSize  );
difference {
	box { -1,1 }
	union {
		TriAxis(<-Inner1,-2,-2>)
		TriAxis(<-Inner2,-Inner2,-3>)
	}
	scale NewSize/2
	translate Center
}
#end

#macro Star(Center, Spoke, Core)
union {
	box { -Core/2, Core/2 rotate <rotclock*90,rotclock*90,rotclock*90> }
	box { -<1000,Spoke/2,Spoke/2>,<1000,Spoke/2,Spoke/2> rotate <0,90,rotclock*90> }
	box { -<1000,Spoke/2,Spoke/2>,<1000,Spoke/2,Spoke/2> rotate <rotclock*90,0,90> }
	translate Center
}
#end

#declare itpl = function(A,B,R) {
	A+R*(B-A)
}

#declare ease = function(X) {
	1-(cos(X*pi)+1)/2
}

#ifdef (PhoneBoot)
  #declare rotpause = 0;
#else
  #declare rotpause = 0.3;
#end

#declare rotclock = (clock < rotpause ? 0 : ease((clock-rotpause) / (1-rotpause)));
#debug concat("rotclock=", str(rotclock,5,5), "\n")
//#declare rotclock = 0.4;

union {
	ScopeBox(<0,0,0>, 24, 8)
	rotate <-rotclock*90,-rotclock*90,0>
  #ifndef (Intro_)
	scale itpl(1,0.5,rotclock)
  #end
}
union {
	ScopeBox(<0,0,0>, 12, 4)
	rotate <rotclock*90,0,rotclock*90>
  #ifndef (Intro_)
	scale itpl(1,2,rotclock)
  #end
}
union {
	Star(<0,0,0>, 2, 6)
	translate <-100,0,0>
	rotate <rotclock*90,0,0>
}

#declare Camera_0 = camera {
  orthographic location <100, 0, 0>
  look_at   <0.0 , 0.0 , 0.0>
  up 32*ImageRatio*x
  right 32*y
  translate <0,-32*((ImageRatio-1)/2),0>
}
camera{Camera_0}

background { color rgb< 1, 1, 1> }

light_source {
  <1e5,0,0>
  color rgb -1
  parallel
  shadowless
  #ifdef (Intro)
	rotate <0,0,90*(1-rotclock)>
  #end
  point_at <0,0,0>
}
