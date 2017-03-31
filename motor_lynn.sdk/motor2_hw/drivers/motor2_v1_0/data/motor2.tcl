

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "motor2" "NUM_INSTANCES" "DEVICE_ID"  "C_MOTOR_AXI_BASEADDR" "C_MOTOR_AXI_HIGHADDR"
}
