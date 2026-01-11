include <BOSL2/std.scad>

CNL_STAND_SIZE = [50, 22, 5.5];
CNL_CAT_Z = 5;
CNL_DOWEL_SIZE = [CNL_CAT_Z, CNL_CAT_Z, 2.5];

LED_WIRE_D = 1.4;

SUPER_MINI_SIZE = [22.7, 18.3, 1.2];

module esp32c3_super_mini() {
  cube(SUPER_MINI_SIZE, anchor=RIGHT);
}

module cnl_body_base(wall_type = "diamonds_2x3") {
  tex = texture("diamonds");
  if (wall_type == "diamonds_2x3") {
    linear_sweep(
      region=rect(
        size=[CNL_STAND_SIZE.x, CNL_STAND_SIZE.y],
        rounding=4, anchor=CENTER
      ),
      texture=tex, h=CNL_STAND_SIZE.z, center=false,
      tex_inset=true, tex_depth=0.4, tex_size=[2, 3],
      style="alt"
    );
  } else if (wall_type == "diamonds_1x3") {
    linear_sweep(
      region=rect(
        size=[CNL_STAND_SIZE.x, CNL_STAND_SIZE.y],
        rounding=4, anchor=CENTER
      ),
      texture=tex, h=CNL_STAND_SIZE.z, center=false,
      tex_inset=true, tex_depth=0.4, tex_size=[1, 3],
      style="alt"
    );
  } else {
    linear_extrude(
      height=CNL_STAND_SIZE.z, center=false, convexity=10,
      twist=0, slices=20, scale=1.0
    )
      rect(size=[CNL_STAND_SIZE.x, CNL_STAND_SIZE.y], rounding=4);
    // squircle(size=[CNL_STAND_SIZE.x, CNL_STAND_SIZE.y], squareness=0.80, style="fg", anchor=CENTER, spin=0, atype="box");
  }
}

module cnl_stand(wall_type = "diamonds_2x3a") {
  difference() {
    cnl_body_base(wall_type=wall_type);

    inner_space_z = CNL_STAND_SIZE.z - 0.5;

    // space for wires
    up(0.5)
      left(2)
        cube([15, 15, CNL_STAND_SIZE.z], anchor=RIGHT + BOT);

    // space for dowel
    cube([CNL_DOWEL_SIZE.x + 0.05, CNL_DOWEL_SIZE.y + 0.05, CNL_STAND_SIZE.z], anchor=RIGHT + BOT);

    // space for esp32c3 super mini
    up(CNL_STAND_SIZE.z + 0.01)
      right(CNL_STAND_SIZE.x / 2 - 2)
        diff(remove="del") {
          cube(
            [SUPER_MINI_SIZE.x + 0.2, SUPER_MINI_SIZE.y + 0.2, inner_space_z],
            anchor=RIGHT + TOP
          ) {
            // space for screw holes
            yflip_copy() align(RIGHT + BACK + TOP, inside=false) tag("del")
                  hull() {
                    right(-3.3) back(-3.3) cylinder(h=0.01, d=20, center=false);

                    down(3) cylinder(h=0.01, d=0.01, center=false);
                  }
            ;

            // cable hole
            align(LEFT + CENTER) cube([3, 6, inner_space_z], anchor=RIGHT + TOP);

            type_c_offset_size = 0.3;
            type_c_offset_length = 0;
            // type c port
            left(1) up(1 + 3.2) align(RIGHT + BOT) diff() {
                    cube(
                      [
                        7.2 + type_c_offset_length,
                        8.9 + type_c_offset_size,
                        3.2 + type_c_offset_size,
                      ],
                      anchor=CENTER + BOT
                    ) {
                      tag("remove") edge_mask([BACK, FRONT], except=[RIGHT, LEFT])
                          rounding_edge_mask(l=10 + type_c_offset_length, r=1.5);
                    }
                    ;
                  }
            ;
          }
          ;
        }
    ;
  }
  ;
}

module cat() {
  // 69.78 x 111.34 (1:1.6, Golden Ratio!)
  resize([45, 0, 0], auto=true)
    import("cat.svg", center=true, convexity=1);
}

module cnl_cat() {
  difference() {
    linear_extrude(height=CNL_CAT_Z, center=false, convexity=1, twist=0, slices=20, scale=1.0)
      union() {
        // base shape
        cat();

        // outer shell (outset)
        shell2d(1.45, or=[2, 0])
          cat();

        // dwell (not very cute)
        translate([0, -45 * 1.6 / 2, 0])
          square([CNL_DOWEL_SIZE.x, CNL_DOWEL_SIZE.z], anchor=RIGHT + BACK);
      }

    // space for led wire
    wire_space_d = LED_WIRE_D + 0.05;
    up(CNL_CAT_Z - 3) {
      linear_extrude(height=CNL_CAT_Z, center=false, convexity=1, twist=0, slices=20, scale=1.0) union() {
          // inset
          shell2d(-wire_space_d) cat();

          // dwell
          translate([-CNL_DOWEL_SIZE.x / 2, -45 * 1.6 / 2 + 1, 0])
            square([wire_space_d, CNL_DOWEL_SIZE.z + 1], anchor=BACK);
        }
      ;
    }
    ;
  }
  ;
}
