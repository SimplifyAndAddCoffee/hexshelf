/*
modular honeycomb shelf generator.
Hexagon_width can be no larger than your print area's wider dimension
wall thickness should be a minimum of 3/4 the diameter of the mounting screw heads. 
Brad holes are provided primarily for fitment and are not meant to be load bearing (the brads will pull out of the wall)
Default settings are for 15 gauge wire brads, standard drywall screws.
218mm width should fit on *most* average printer beds
Free for non-commercial use, please attribute and share alike.

https://github.com/SimplifyAndAddCoffee
https://www.thingiverse.com/simplifyandaddcoffee/designs

 _________________
|# :           : #|
|  : HACK      :  |
|  :   THE     :  |
|  :    PLANET :  |
|  :___________:  |
|     _________   |
|    | __      |  |
|    ||  |     |  |
\____||__|_____|__|

*/

/* [Main Parameters] */

// What to render. 
render_type = "plated"; //["plated","preview","window cut svg"]
// how many joining pieces to print with each cell.
num_joiners = 2; // [0,1,2,3]
// how many edge pieces to print with each cell
num_covers = 3; // [0,1,2,3]
// how many long (joining) staves to print with each cell
num_longstaves = 3;  // [0,1,2,3]
// how many short (edge) staves to print with each cell
num_shortstaves = 3;  // [0,1,2,3]
// print a center horizontal divider shelf (optional)
include_divider=false; // [true,false]
// set to false if you only want to print the small pieces. 
include_cell=true; // [true,false]
// what type of cell to render
cell_type="hex"; // ["hooks","hex"]
// how wide each cell is, (max=bed width)
hexagon_width = 218; //
// how thick the outer walls are. Note: Should be at least 3/4 the diameter of the screw heads used to attach to the wall.
wall_thickness = 10; // 
// True to use inner circumradius as depth.
use_recommended_depth = false; // [true,false]
// manually set depth of shelf (mm)
depth_override = 170; 
// depth of the dovetail joining pieces. Must be shorter than the total depth of the shelf. 
dovetail_thickness = 20;
// recess for front acrylic window or door to keep dust out.
window_recession = true; //[true,false]
// thickness of material used for window/door
window_thickness = 2.9; 
// size of finger hole for removing window
window_hole_size = 20; 
// tolerance between parts
tol = 0.17; 

/* [Fastener Specifications] */

// outer diameter of screw threads
screw_diameter = 4.1;
// diameter of screw head
screw_head_diameter = 8.5;
// for purpose of calculating inset
screw_head_thickness = 1;
// length of the tapered part of the screw head.
screw_countersink_depth =2.3;
// how far to recess the screw in the dovetail joint piece.
screw_inset = 10;
// diameter of the wire brads for positioning
brad_hole_diameter = 2;
// diameter of the wire brad heads
brad_head_diameter = 3.2;
// how deep the brad heads are
brad_head_inset = 1.5;

$fn=32+0;

//calculated values 
outer_circumradius = hexagon_width /2;
outer_inradius = outer_circumradius * cos(30);
hexagon_height = outer_inradius * 2;
echo("hexagon height will be ",hexagon_height,". Ensure this is not wider than the smallest dimension of your printer bed.");
inner_inradius = outer_inradius - wall_thickness;
inner_circumradius = inner_inradius / cos(30);
inner_width = inner_circumradius * 2;
inner_height = inner_inradius * 2;
window_inradius = inner_inradius + window_thickness;
window_circumradius = window_inradius / cos(30);
window_width = window_circumradius * 2;
window_height = window_inradius * 2;
echo("interior cell width will be ",inner_width, ", and interior cell height will be ",inner_height, ", with a length per side of ",inner_circumradius);
echo("Window dimensions: inradius: ", window_inradius," circumradius/side: ", window_circumradius," width: ",window_width," height: ",window_height);
additional_depth = window_recession == true ? window_thickness * 1.25 : 0;
depth = use_recommended_depth == true ? inner_circumradius + additional_depth : depth_override + additional_depth;
echo("total depth will be ",depth);

module hex_shape(){

    difference(){
        cylinder(h=depth,r=outer_circumradius, center=false,$fn=6);
        cylinder(h=depth+1,r=inner_circumradius, center=false,$fn=6);
        }
}

module dovetail(){
l = outer_circumradius * 3/4;
w1 = wall_thickness * 0.5;
w2 = wall_thickness * 1.5;
h = dovetail_thickness;
dovetail_width = l / 3;
dovetail_inner = dovetail_width * 0.8 ;

        linear_extrude(height = h)
            polygon([[0,dovetail_inner+(dovetail_width-dovetail_inner)/2],[w2/2,dovetail_width],[w2/2,0],[0,(dovetail_width-dovetail_inner)/2]]);
}

module screw_hole(){
    union(){
        cylinder(h=dovetail_thickness+1,d=screw_diameter+2*tol);
        translate([0,0,dovetail_thickness-screw_inset-screw_head_thickness])
            cylinder(h=dovetail_thickness+1,d=screw_head_diameter+2*tol);
        translate([0,0,dovetail_thickness-screw_inset-screw_head_thickness-screw_countersink_depth])
        linear_extrude(height=screw_countersink_depth,scale=((screw_head_diameter+2*tol)/(screw_diameter+2*tol)))
                circle(d=screw_diameter+2*tol);
    } 
}

module brad_hole(){
    union(){
        cylinder(h=dovetail_thickness+1,d=brad_hole_diameter+2*tol);
        translate([0,0,dovetail_thickness-brad_head_inset-tol])
        cylinder(h=dovetail_thickness+1,d=brad_head_diameter+2*tol);
    }
}

module stave(cutout=false,type="long"){
l= type=="long" ? wall_thickness * 2: wall_thickness;
w=outer_circumradius * 3/4 * 1/4;
h1= cutout == false? dovetail_thickness/3 : (dovetail_thickness/3)*1.045;
h2=h1*1.5;
    minkowski()
        union(){
            cube([l,w,h1]);
            cube([wall_thickness/4,w,h2]);
        }
    if(cutout==true)cube(tol);

}


module joiner(cutout=false,type="inner"){

//figure out how to calculate dovetail dimensions
l = outer_circumradius * 3/4;
w1 = wall_thickness * 0.5;
w2 = wall_thickness * 1.5;
h = dovetail_thickness;
dovetail_width = l / 3;
dovetail_inner = dovetail_width * 0.8 ;
minkowski(){
    union(){
        difference(){
            union(){
                translate([-w1/2,0,0])cube([w1,l,h]);
                    for(x=[0:1:1]){
                        mirror([x,0,0]){
                            dovetail();
                            translate([0,outer_circumradius * 3/4 * 2/3,0])dovetail();
                        }
                    }
            }
            
            if(cutout==false){
                union(){
                    for(y=[0:1:1]){ // main screw holes
                        translate([0,(outer_circumradius * 3/4 * 1/3 * 1/2 ) + ( y *outer_circumradius * 3/4 * 2/3) ,0]){
                            if(type=="inner"){  
                                screw_hole();
                                }
                            for(z=[0:90:360]){
                                rotate([0,0,z])
                                    translate([w2/2*2/3,w2/2*2/3,0])
                                        brad_hole();
                            }
                        }
                    }
                    translate([-wall_thickness,outer_circumradius * 3/4 * 1/2 - outer_circumradius * 3/4 * 1/4 * 1/2,dovetail_thickness /3])
                        stave(cutout=true);
                }
            }
            if(type=="outer"){
                cube([w2,l+1,2*h+1]);
                    translate([0,outer_circumradius * 3/4 * 1/2 - outer_circumradius * 3/4 * 1/4 * 1/2,dovetail_thickness /3])
                    mirror([1,0,0])
                        stave(cutout=true);
            }
        }

    }
    if(cutout==true)cube(tol);
    }
}

module window_cutout(){
    difference(){
        cylinder(h=window_thickness*1.26,r=window_circumradius+tol/2,$fn=6);
        union(){
            for(z=[0:60:300]){
                rotate([0,0,z+30]){
                    translate([window_inradius,0,window_thickness*1.125]){
                        rotate([90,0,0]){
                            cylinder(h=window_circumradius/10,d=window_thickness/4,center=true);
                        }
                    }
                }
            }
        }

    }
}

module window_svg(){
    difference(){
        circle(window_circumradius,$fn=6);
        union(){
            translate([0,window_inradius,0])square(window_hole_size,center=true);
            translate([0,window_inradius-window_hole_size/2,0])circle(d=window_hole_size);
        }
    }
}

module cell(){
    difference(){
        hex_shape();
        union(){
            for(z=[180:60:300]){
                rotate([0,0,30+z])
                    translate([outer_inradius-0.001,-outer_circumradius * 3/4 * 1/2,0]){
                            joiner(cutout=true);
                            translate([-wall_thickness,outer_circumradius * 3/4 * 1/2 - outer_circumradius * 3/4 * 1/4 * 1/2,dovetail_thickness /3])
                                stave(cutout=true);
                        }
            }
            for(z=[0:60:120]){
                rotate([0,0,30+z])
                    translate([outer_inradius,-outer_circumradius * 3/4 * 1/2,0]){
                            joiner(cutout=true,type="inner");
                            translate([0,outer_circumradius * 3/4 * 1/2 - outer_circumradius * 3/4 * 1/4 * 1/2,dovetail_thickness /3])
                                mirror([1,0,0])
                                    stave(cutout=true,type="long");
                        }
            }
            if(window_recession==true){
                translate([0,0,depth-window_thickness*1.25])
                    window_cutout();
            translate([0,outer_inradius-wall_thickness*0.8,0])mirror([1,0,0])linear_extrude(height=0.4)text(text="TOP", size = wall_thickness/2,halign="center");
            }
        }
    
    }

}

module hooks(){
    hook_d=wall_thickness*2/3;
    hook_r=0.8;
    hook_l=wall_thickness*1.5;
    hook_rot=160;
    translate([0,inner_inradius,0]){
        difference(){
            union(){
                // baseplate
                linear_extrude(height = depth)
                    polygon([[outer_circumradius/2,wall_thickness],[inner_circumradius/2,0],[-inner_circumradius/2,0],[-outer_circumradius/2,wall_thickness]]);
                // supports
                difference(){
                    union(){
                        translate([0,-inner_inradius,0])
                            cylinder(h=depth,r=outer_circumradius,$fn=6);
                    }
                    union(){
                        translate([0,-inner_inradius,0])
                            cylinder(h=depth,r=inner_circumradius,$fn=6);
                        translate([0,-outer_circumradius*1.25,outer_circumradius*2])
                            rotate([45,0,0])
                                cube(outer_circumradius*4,center=true);
                        
                    }
                }
                // hooks
                for(x=[-1:1:1]){
                    for(z=[1:1:3]){
                        translate([x*inner_circumradius/4,0,z*depth/4]){
                            translate([0,0,-hook_d*hook_r*2])
                                rotate([90,0,0])
                                    cylinder(h=hook_l,d=hook_d,$fn=6);
                                    translate([0,-hook_l,-hook_d*hook_r])
                                        rotate([180,90,0])
                                            rotate_extrude(angle=hook_rot)
                                                translate([hook_d*hook_r,0,0])
                                                    rotate([0,0,90])
                                                        circle(d=hook_d,$fn=6);
                            translate([0,-hook_l+cos(hook_rot)*hook_r*2,0])
                                rotate([0180-hook_rot,0,0])
                                    translate([0,0,0])
                                        sphere(d=hook_d, $fn=6);
                        }
                    }
                }
            }
            union(){
                rotate([0,0,90])
                    translate([outer_inradius-inner_inradius,-outer_circumradius * 3/4 * 1/2,0]){
                            joiner(cutout=true,type="inner");translate([0,outer_circumradius * 3/4 * 1/2 - outer_circumradius * 3/4 * 1/4 * 1/2,dovetail_thickness /3])
                                mirror([1,0,0])
                                    stave(cutout=true,type="short");
                            }
                translate([0,-wall_thickness,depth+outer_circumradius/2])
                    rotate([45,0,0])
                        cube(outer_circumradius,center=true);
            }
        }
    }
}

module divider(){
intersection(){
translate([-hexagon_width/2,-wall_thickness/2,0])
    cube([hexagon_width,wall_thickness,depth]);
    cylinder(h=depth - additional_depth,r=inner_circumradius-tol, center=false,$fn=6);
    }
}

module plated_bits(){
    translate([0,-outer_circumradius*1/3,0]){
        for(x=[1:1:num_joiners])
            translate([-wall_thickness + wall_thickness*2.1*x,0,0])
            joiner(cutout=false);
        for(x=[1:1:num_covers])
            translate([wall_thickness - wall_thickness*2.1*x,0,0])
            joiner(cutout=false,type="outer");
        for(x=[1:1:num_shortstaves])
            translate([wall_thickness - wall_thickness*2.1*x,-outer_circumradius * 3/4 * 1/4 * 1.1,0])
                stave(type="short");
        for(x=[1:1:num_longstaves])
            translate([-2*wall_thickness + wall_thickness*2.1*x,-outer_circumradius * 3/4 * 1/4 * 1.1,0])
                stave(type="long");
    }
}    

module preview_bits(){
    for(z=[180:60:300]){
        rotate([0,0,30+z])
            translate([outer_inradius,-outer_circumradius * 3/4 * 1/2,0]){
                    color(c=[0.9,0,0],alpha=0.5)joiner(cutout=false);
                    translate([-wall_thickness,outer_circumradius * 3/4 * 1/2 - outer_circumradius * 3/4 * 1/4 * 1/2,dovetail_thickness /3])
                        color(c=[0,0,0.8],alpha=1)stave(cutout=false);
                }
    }
    for(z=[0:60:120]){
        rotate([0,0,30+z])
            translate([outer_inradius,-outer_circumradius * 3/4 * 1/2,0]){
                    color(c=[0.9,0,0],alpha=1)joiner(cutout=false,type="outer");
                    translate([0,outer_circumradius * 3/4 * 1/2 - outer_circumradius * 3/4 * 1/4 * 1/2,dovetail_thickness /3])
                        mirror([1,0,0])
                            color(c=[0,0,0.8],alpha=0.5)stave(cutout=true,type="short");
                }
    }
    if(window_recession==true){
        translate([0,0,depth-window_thickness*1.25])
            color(c=[0,0,0,0.1])linear_extrude(height=window_thickness)window_svg();
    }
}

if(render_type=="plated"){
    if(include_cell==true){
        if(cell_type=="hex")
            cell();
        if(cell_type=="hooks")
            hooks();
        }
    plated_bits();
    if(include_divider==true)
        translate([0,hexagon_height/2+wall_thickness*0.6,0])
            divider();
}

if(render_type=="window cut svg"){
window_svg();
}

if(render_type=="preview"){
    for(y=[0,outer_inradius*2,0]){
        translate([0,y,0]){
        
            color(c = [1,1,0], alpha=0.5)cell();
            color(c = [1,0.8,0], alpha=1)if(include_divider==true)divider();
            preview_bits();
        
            translate([2*outer_circumradius-sin(30)*outer_circumradius,outer_inradius,0]){
            
                color(c = [1,1,0], alpha=0.5)cell();
                color(c = [1,0.8,0], alpha=1)if(include_divider==true)divider();
                preview_bits();
                
            }
            
        }
        
    }

}
