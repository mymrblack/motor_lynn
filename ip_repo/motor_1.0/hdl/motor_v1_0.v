
`timescale 1 ns / 1 ps

	module motor_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface MOTOR_AXI
		parameter integer C_MOTOR_AXI_DATA_WIDTH	= 32,
		parameter integer C_MOTOR_AXI_ADDR_WIDTH	= 5
	)
	(
		// Users to add ports here
        input raster_a,
        input raster_b,
        input raster_z,

        output pos_pwm,
        output dir,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface MOTOR_AXI
		input wire  motor_axi_aclk,
		input wire  motor_axi_aresetn,
		input wire [C_MOTOR_AXI_ADDR_WIDTH-1 : 0] motor_axi_awaddr,
		input wire [2 : 0] motor_axi_awprot,
		input wire  motor_axi_awvalid,
		output wire  motor_axi_awready,
		input wire [C_MOTOR_AXI_DATA_WIDTH-1 : 0] motor_axi_wdata,
		input wire [(C_MOTOR_AXI_DATA_WIDTH/8)-1 : 0] motor_axi_wstrb,
		input wire  motor_axi_wvalid,
		output wire  motor_axi_wready,
		output wire [1 : 0] motor_axi_bresp,
		output wire  motor_axi_bvalid,
		input wire  motor_axi_bready,
		input wire [C_MOTOR_AXI_ADDR_WIDTH-1 : 0] motor_axi_araddr,
		input wire [2 : 0] motor_axi_arprot,
		input wire  motor_axi_arvalid,
		output wire  motor_axi_arready,
		output wire [C_MOTOR_AXI_DATA_WIDTH-1 : 0] motor_axi_rdata,
		output wire [1 : 0] motor_axi_rresp,
		output wire  motor_axi_rvalid,
		input wire  motor_axi_rready
	);
// Instantiation of Axi Bus Interface MOTOR_AXI
	motor_v1_0_MOTOR_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_MOTOR_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_MOTOR_AXI_ADDR_WIDTH)
	) motor_v1_0_MOTOR_AXI_inst (
        .raster_a(raster_a),
        .raster_b(raster_b),
        .raster_z(raster_z),
        .pos_pwm(pos_pwm),
        .dir(dir),
		.S_AXI_ACLK(motor_axi_aclk),
		.S_AXI_ARESETN(motor_axi_aresetn),
		.S_AXI_AWADDR(motor_axi_awaddr),
		.S_AXI_AWPROT(motor_axi_awprot),
		.S_AXI_AWVALID(motor_axi_awvalid),
		.S_AXI_AWREADY(motor_axi_awready),
		.S_AXI_WDATA(motor_axi_wdata),
		.S_AXI_WSTRB(motor_axi_wstrb),
		.S_AXI_WVALID(motor_axi_wvalid),
		.S_AXI_WREADY(motor_axi_wready),
		.S_AXI_BRESP(motor_axi_bresp),
		.S_AXI_BVALID(motor_axi_bvalid),
		.S_AXI_BREADY(motor_axi_bready),
		.S_AXI_ARADDR(motor_axi_araddr),
		.S_AXI_ARPROT(motor_axi_arprot),
		.S_AXI_ARVALID(motor_axi_arvalid),
		.S_AXI_ARREADY(motor_axi_arready),
		.S_AXI_RDATA(motor_axi_rdata),
		.S_AXI_RRESP(motor_axi_rresp),
		.S_AXI_RVALID(motor_axi_rvalid),
		.S_AXI_RREADY(motor_axi_rready)
	);

	// Add user logic here

	// User logic ends

	endmodule
