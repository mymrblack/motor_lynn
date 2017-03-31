
`timescale 1 ns / 1 ps

	module motor_v1_0_MOTOR_AXI #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Width of S_AXI data bus
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		// Width of S_AXI address bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 5
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

		// Global Clock Signal
		input wire  S_AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		input wire  S_AXI_ARESETN,
		// Write address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		// Write channel Protection type. This signal indicates the
    		// privilege and security level of the transaction, and whether
    		// the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_AWPROT,
		// Write address valid. This signal indicates that the master signaling
    		// valid write address and control information.
		input wire  S_AXI_AWVALID,
		// Write address ready. This signal indicates that the slave is ready
    		// to accept an address and associated control signals.
		output wire  S_AXI_AWREADY,
		// Write data (issued by master, acceped by Slave) 
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		// Write strobes. This signal indicates which byte lanes hold
    		// valid data. There is one write strobe bit for each eight
    		// bits of the write data bus.    
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		// Write valid. This signal indicates that valid write
    		// data and strobes are available.
		input wire  S_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    		// can accept the write data.
		output wire  S_AXI_WREADY,
		// Write response. This signal indicates the status
    		// of the write transaction.
		output wire [1 : 0] S_AXI_BRESP,
		// Write response valid. This signal indicates that the channel
    		// is signaling a valid write response.
		output wire  S_AXI_BVALID,
		// Response ready. This signal indicates that the master
    		// can accept a write response.
		input wire  S_AXI_BREADY,
		// Read address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		// Protection type. This signal indicates the privilege
    		// and security level of the transaction, and whether the
    		// transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_ARPROT,
		// Read address valid. This signal indicates that the channel
    		// is signaling valid read address and control information.
		input wire  S_AXI_ARVALID,
		// Read address ready. This signal indicates that the slave is
    		// ready to accept an address and associated control signals.
		output wire  S_AXI_ARREADY,
		// Read data (issued by slave)
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		// Read response. This signal indicates the status of the
    		// read transfer.
		output wire [1 : 0] S_AXI_RRESP,
		// Read valid. This signal indicates that the channel is
    		// signaling the required read data.
		output wire  S_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    		// accept the read data and response information.
		input wire  S_AXI_RREADY
	);

	// AXI4LITE signals
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rvalid;

	// Example-specific design signals
	// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	// ADDR_LSB is used for addressing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 2;
	//----------------------------------------------
	//-- Signals for user logic register space example
    wire out_en, init; 
    wire [31:0] init_div;
    wire [31:0] raster_a_circle;
    wire [31:0] pos_a_circle;
    wire [31:0] pos_pwm_cntr;
    wire find_origin_finish;
    wire to_one_side_en, to_one_side_finish;
    wire [31:0] side_raster_val;
	//------------------------------------------------
	//-- Number of Slave Registers 8
	reg [C_S_AXI_DATA_WIDTH-1:0]	motor_ctrl;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg1;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg2;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg3;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg4;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg5;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg6;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg7;
	wire	 slv_reg_rden;
	wire	 slv_reg_wren;
	reg [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
	integer	 byte_index;

	// I/O Connections assignments

	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= axi_bresp;
	assign S_AXI_BVALID	= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RDATA	= axi_rdata;
	assign S_AXI_RRESP	= axi_rresp;
	assign S_AXI_RVALID	= axi_rvalid;
	// Implement axi_awready generation
	// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	// de-asserted when reset is low.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
	        begin
	          // slave is ready to accept write address when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_awready <= 1'b1;
	        end
	      else           
	        begin
	          axi_awready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_awaddr latching
	// This process is used to latch the address when both 
	// S_AXI_AWVALID and S_AXI_WVALID are valid. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
	        begin
	          // Write Address latching 
	          axi_awaddr <= S_AXI_AWADDR;
	        end
	    end 
	end       

	// Implement axi_wready generation
	// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	// de-asserted when reset is low. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID)
	        begin
	          // slave is ready to accept write data when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_wready <= 1'b1;
	        end
	      else
	        begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       

	// Implement memory mapped register select and write logic generation
	// The write data is accepted and written to memory mapped registers when
	// axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	// select byte enables of slave registers while writing.
	// These registers are cleared when reset (active low) is applied.
	// Slave register write enable is asserted when valid address and data are available
	// and the slave is ready to accept the write address and write data.
	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      motor_ctrl <= 0;
	      slv_reg1 <= 0;
	      slv_reg2 <= 0;
	      slv_reg3 <= 0;
	      slv_reg4 <= 0;
	      slv_reg5 <= 0;
	      slv_reg6 <= 0;
	      slv_reg7 <= 0;
	    end 
	  else begin
	    if (slv_reg_wren)
	      begin
	        case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	          3'h0:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 0
	                motor_ctrl[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          3'h1:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 1
	                slv_reg1[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          3'h2:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 2
	                slv_reg2[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          3'h3:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 3
	                slv_reg3[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          3'h4:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 4
	                slv_reg4[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          3'h5:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 5
	                slv_reg5[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          3'h6:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 6
	                slv_reg6[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          3'h7:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 7
	                slv_reg7[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          default : begin
	                      motor_ctrl <= motor_ctrl;
	                      slv_reg1 <= slv_reg1;
	                      slv_reg2 <= slv_reg2;
	                      slv_reg3 <= slv_reg3;
	                      slv_reg4 <= slv_reg4;
	                      slv_reg5 <= slv_reg5;
	                      slv_reg6 <= slv_reg6;
	                      slv_reg7 <= slv_reg7;
	                    end
	        endcase
	      end
	  end
	end    

	// Implement write response logic generation
	// The write response and response valid signals are asserted by the slave 
	// when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	// This marks the acceptance of address and indicates the status of 
	// write transaction.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid  <= 0;
	      axi_bresp   <= 2'b0;
	    end 
	  else
	    begin    
	      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
	        begin
	          // indicates a valid write response is available
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; // 'OKAY' response 
	        end                   // work error responses in future
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid) 
	            //check if bready is asserted while bvalid is high) 
	            //(there is a possibility that bready is always asserted high)   
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	end   

	// Implement axi_arready generation
	// axi_arready is asserted for one S_AXI_ACLK clock cycle when
	// S_AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when S_AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_araddr  <= 32'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID)
	        begin
	          // indicates that the slave has acceped the valid read address
	          axi_arready <= 1'b1;
	          // Read address latching
	          axi_araddr  <= S_AXI_ARADDR;
	        end
	      else
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_arvalid generation
	// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	// data are available on the axi_rdata bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
	        begin
	          // Valid read data is available at the read data bus
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0; // 'OKAY' response
	        end   
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          // Read data is accepted by the master
	          axi_rvalid <= 1'b0;
	        end                
	    end
	end    

	// Implement memory mapped register select and read logic generation
	// Slave register read enable is asserted when valid address is available
	// and the slave is ready to accept the read address.
	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
	always @(*)
	begin
	      // Address decoding for reading registers
	      case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	        3'h0   : reg_data_out <= {to_one_side_finish, find_origin_finish};
	        3'h1   : reg_data_out <= pos_a_circle;
	        3'h2   : reg_data_out <= raster_a_circle;
	        3'h3   : reg_data_out <= pos_pwm_cntr;
	        3'h4   : reg_data_out <= slv_reg4;
	        3'h5   : reg_data_out <= slv_reg5;
	        3'h6   : reg_data_out <= slv_reg6;
	        3'h7   : reg_data_out <= slv_reg7;
	        default : reg_data_out <= 0;
	      endcase
	end

	// Output register or memory read data
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rdata  <= 0;
	    end 
	  else
	    begin    
	      // When there is a valid read address (S_AXI_ARVALID) with 
	      // acceptance of read address by the slave (axi_arready), 
	      // output the read dada 
	      if (slv_reg_rden)
	        begin
	          axi_rdata <= reg_data_out;     // register read data
	        end   
	    end
	end    

	// Add user logic here

    assign out_en = motor_ctrl[0];
    assign init = motor_ctrl[1];
    assign init_div = slv_reg1;
    assign side_raster_val = slv_reg2;
    assign to_one_side_en = motor_ctrl[2];

    MOTOR motor(.clk(S_AXI_ACLK), .resetn(S_AXI_ARESETN), 
        .out_en(out_en), .init(init), .div(init_div),
        .raster_a(raster_a), .raster_b(raster_b), .raster_z(raster_z), 
        .to_one_side_en(to_one_side_en), .side_raster_val(side_raster_val),
        .pos_pwm(pos_pwm), .dir(dir), 
        .find_origin_finish(find_origin_finish), .to_one_side_finish(to_one_side_finish),
        .raster_a_circle(raster_a_circle), .pos_a_circle(pos_a_circle));
	// User logic ends

	endmodule

module MOTOR(input clk, input resetn, input out_en, input init, input [31:0] div,
        input raster_a, input raster_b, input raster_z, input to_one_side_en,
        input [31:0] side_raster_val,
        output pos_pwm, output dir, output [31:0] raster_a_circle, 
        output find_origin_finish, output to_one_side_finish,
        output [31:0] pos_a_circle);
        
        wire a,b,z;
    
        MOTOR_INIT motor_init(.clk(clk), .resetn(resetn), .init(init), .div(div),
        .raster_a(a), .raster_b(raster_b), .raster_z(z), .to_one_side_en(to_one_side_en),
        .side_raster_val(side_raster_val), .dir(dir), .pos_pwm(pos_pwm), 
        .find_origin_finish(find_origin_finish), .to_one_side_finish(to_one_side_finish),
        .raster_a_circle(raster_a_circle), .pos_a_circle(pos_a_circle));
        
        GET_POSEDGE_ASYNC a_posedge(clk, resetn, raster_a, a);
        GET_POSEDGE_ASYNC z_posedge(clk, resetn, raster_z, z);
    endmodule
    
module MOTOR_INIT(input clk, input resetn, input init, input [31:0] div,
        input raster_a, input raster_b, input raster_z, input to_one_side_en,
        input [31:0] side_raster_val,
        output reg dir, output pos_pwm, output find_origin_finish, output to_one_side_finish,
        output [31:0] raster_a_circle, output [31:0] pos_a_circle);
        
        reg [15:0] z_cntr;
        wire pos_pwm_inner, init_en, to_one_side_pwm;
        wire find_origin_pwm, find_origin_en;
        wire [31:0] raster_cntr;
    
        always@(posedge clk) begin
            if(!resetn | !init_en)
                dir <= 0;
            else
                dir <= 1;
        end
    
        always@(posedge clk) begin
            if(!resetn | !init)
                z_cntr <= 0;
            else if(raster_z == 1)
                z_cntr <= z_cntr + 1;
            else
                z_cntr <= z_cntr;
        end
    
        RASTER_CNTR raster_count(.clk(clk), .resetn(resetn), .sig_plus(raster_a), 
            .clr(raster_z), .sig_dir(raster_b), .raster_a_circle(raster_a_circle),
            .raster_cntr(raster_cntr));
    
        INIT_POS_CTRL pos_pwm_generate(.clk(clk), .resetn(resetn), .enable(init_en), 
            .clr(raster_z), .div(div), .pos_a_circle(pos_a_circle), .pos_pwm(pos_pwm_inner));
    
        FIND_ORINGIN_MODULE find_origin(.origin_cntr(z_cntr), .init_pwm(pos_pwm_inner), 
            .init(init), .find_origin_pwm(find_origin_pwm), .find_origin_finish(find_origin_finish), 
            .find_origin_en(find_origin_en));
    
        TO_ONE_SIDE_MODULE to_one_side(.init_pwm(pos_pwm_inner), .to_one_side_en(to_one_side_en),
            .raster_cntr(raster_cntr), .side_raster_val(side_raster_val),
            .to_one_side_pwm(to_one_side_pwm), .to_one_side_finish(to_one_side_finish));
    
        assign pos_pwm = find_origin_pwm | to_one_side_pwm; 
        assign init_en = (find_origin_en | to_one_side_en)?  1: 0;
    endmodule
    
    module TO_ONE_SIDE_MODULE (input init_pwm, input to_one_side_en, input [31:0] raster_cntr,
        input [31:0] side_raster_val,
        output to_one_side_pwm, output to_one_side_finish);
        assign to_one_side_pwm = (to_one_side_en & (raster_cntr > side_raster_val))? init_pwm: 0;
        assign to_one_side_finish = (to_one_side_en & (raster_cntr <= side_raster_val))? 1: 0;
    endmodule
    module FIND_ORINGIN_MODULE (input [15:0] origin_cntr, input init_pwm, input init, 
        output find_origin_pwm, output find_origin_finish, output find_origin_en);
        
        assign find_origin_pwm = (origin_cntr >= 2)? 0: init_pwm;
        assign find_origin_en = (origin_cntr >= 2)? 0: init; 
        assign find_origin_finish = (origin_cntr >= 2)? 1: 0;
    endmodule
    module RASTER_CNTR (input clk, input resetn, input sig_plus, input clr, input sig_dir,
        output reg [31:0] raster_a_circle, output reg [31:0] raster_cntr);
        always@(posedge clk) begin
            if(!resetn | clr)
                raster_cntr <= 0;
            else if(sig_plus == 1) begin
                if (sig_dir)
                    raster_cntr <= raster_cntr + 1;
                else
                    raster_cntr <= raster_cntr - 1;
            end
            else
                raster_cntr <= raster_cntr;
        end
    
        always@(posedge clk) begin
            if(!resetn)
                raster_a_circle <= 0;
            else if(clr)
                raster_a_circle <= raster_cntr;
            else 
                raster_a_circle <= raster_a_circle;
        end
    endmodule
    
    module INIT_POS_CTRL(input clk, input resetn, input enable, input clr, input [31:0] div,
        output reg [31:0] pos_a_circle, output pos_pwm);
        
        reg [31:0] pos_pwm_cntr;
        reg [31:0] clk_cntr;
    
        always@(posedge clk) begin
            if(!resetn | !enable | (div == 0))
                clk_cntr <= 0;
            else if(clk_cntr == div)
                clk_cntr <= 1;
            else
                clk_cntr <= clk_cntr + 1;
        end
        assign pos_pwm = ((clk_cntr != 0)&&(clk_cntr <= (div >> 1)))? 1: 0;
    
        always@(posedge clk) begin 
            if(!resetn | clr)
                pos_pwm_cntr <= 0;
            else if(clk_cntr == 1)
                pos_pwm_cntr <= pos_pwm_cntr + 1;
            else
                pos_pwm_cntr <= pos_pwm_cntr;
        end
    
        always@(posedge clk) begin 
            if(!resetn)
                pos_a_circle <= 0;
            else if(clr)
                pos_a_circle <= pos_pwm_cntr;
            else
                pos_a_circle <= pos_a_circle;
        end
    endmodule
    
    module GET_POSEDGE_ASYNC(input clk, input resetn, input signal_in, output signal_out);
        reg signal_temp1;
        reg signal_temp2;
        reg signal_temp3;
    
        always@(posedge clk) begin
            if(!resetn) begin
                signal_temp1 <=0;
                signal_temp2 <=0;
                signal_temp3 <=0;
            end
            else begin
                signal_temp1 <= signal_in;
                signal_temp2 <= signal_temp1;
                signal_temp3 <= signal_temp2;
            end
        end
    
        assign signal_out = signal_temp2 &(~signal_temp3);
    endmodule
	
