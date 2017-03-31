#JC1_P
set_property PACKAGE_PIN AB7 [get_ports {raster_a}]
set_property IOSTANDARD LVCMOS33 [get_ports {raster_a}]
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets raster_a_IBUF]

#JC1_N
set_property PACKAGE_PIN AB6  [get_ports {raster_b}]
set_property IOSTANDARD LVCMOS33 [get_ports {raster_b}]

#JC2_P
set_property PACKAGE_PIN Y4  [get_ports {raster_z}]
set_property IOSTANDARD LVCMOS33 [get_ports {raster_z}]

#JC3_P
set_property PACKAGE_PIN R6  [get_ports {pos_pwm}]
set_property IOSTANDARD LVCMOS33 [get_ports {pos_pwm}]

#JC3_N
set_property PACKAGE_PIN  T6  [get_ports {dir}]
set_property IOSTANDARD LVCMOS33 [get_ports {dir}]