

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "motor" "NUM_INSTANCES" "DEVICE_ID"  "C_MOTOR_AXI_BASEADDR" "C_MOTOR_AXI_HIGHADDR"
}
