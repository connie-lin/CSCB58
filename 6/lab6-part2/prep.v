//module lab6 (KEY,SW,HEX0,HEX2,HEX4,HEX5);
//	input [9:0] SW;
//	input [0:0]KEY;
//	output [6:0] HEX0, HEX2, HEX4, HEX5;
//	wire [3:0] q;
//	ram32x4 ram(
//		.address(SW[8:4]),
//		.clock(~KEY[0]),
//		.data(SW[3:0]),
//		.wren(SW[9]),
//		.q(q)
//	);
//	
//	hex_decoder front_address(
//		.hex_digit(SW[8]),
//		.segments(HEX5)
//		);
//	
//	hex_decoder rear_address(
//		.hex_digit(SW[7:4]),
//		.segments(HEX4)
//		);
//	
//	hex_decoder input_data(
//		.hex_digit(SW[3:0]),
//		.segments(HEX2)
//		);
//		
//	hex_decoder memory_data(
//		.hex_digit(q),
//		.segments(HEX0)
//		);
//
//endmodule
//
//module hex_decoder(hex_digit, segments);
//	input [3:0] hex_digit;
//	output reg [6:0] segments;
//   
//	always @(*)
//		case (hex_digit)
//			4'h0: segments = 7'b100_0000;
//			4'h1: segments = 7'b111_1001;
//			4'h2: segments = 7'b010_0100;
//			4'h3: segments = 7'b011_0000;
//			4'h4: segments = 7'b001_1001;
//			4'h5: segments = 7'b001_0010;
//			4'h6: segments = 7'b000_0010;
//			4'h7: segments = 7'b111_1000;
//			4'h8: segments = 7'b000_0000;
//			4'h9: segments = 7'b001_1000;
//			4'hA: segments = 7'b000_1000;
//			4'hB: segments = 7'b000_0011;
//			4'hC: segments = 7'b100_0110;
//			4'hD: segments = 7'b010_0001;
//			4'hE: segments = 7'b000_0110;
//			4'hF: segments = 7'b000_1110;   
//			default: segments = 7'h7f;
//		endcase
//endmodule


// Part 2 skeleton

module lab6
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn, enable, ld_x, ld_y, ld_c;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    
    // Instansiate datapath
	// datapath d0(...);
	datapath do(
		.location_in(SW[6:0]),
		.colour_in(SW[9:7]),
		.clock(CLOCK_50),
		.resetN(resetn),
		.enable_i_x(enable),
		.ld_x(ld_x),
		.ld_y(ld_y),
		.ld_c(ld_c),
		.x_out(x),
		.y_out(y),
		.colour_out(colour)
	);
    // Instansiate FSM control
    controller c0(
		.go(!KEY[3]),
		.resetN(resetn),
		.clock(CLOCK_50),
		.draw(!KEY[1]),
		.ld_x(ld_x),
		.ld_y(ld_y),
		.ld_c(ld_c),
		.enable_i_x(enable),
		.plot(writeEn)
	);

    
endmodule

module datapath(location_in, colour_in, clock, resetN, enable_i_x, ld_x, ld_y, ld_c, x_out, y_out, colour_out);
	input [6:0] location_in;
	input [2:0] colour_in;
	input clock;
	input enable_i_x;
	input resetN;
	input ld_x, ld_y, ld_c;
	output [7:0] x_out; 
	output [6:0] y_out;
	output [2:0] colour_out;
	
	reg [7:0] x;
	reg [7:0] y;
	reg [2:0] colour;
	reg [1:0] i_x, i_y; // index of x and y in loop
	reg enable_i_y;
	
	always @(posedge clock) begin 
		if(!resetN) begin  //active low reset
			x <= 7'b0;
			y <= 7'b0;
			colour <= 3'b0;
		end
		else begin
			if(ld_x)
				x <= location_in;
			if(ld_y)
				y <= location_in;
			if(ld_c)
				colour <= colour_in;
		end
	end
	
	always @(posedge clock) begin
		if(!resetN)
			i_x <= 2'b00;
		else if(enable_i_x) begin // start to increase x
			if(i_x == 2'b11) begin
				i_x <= 2'b00;
				enable_i_y <= 1;
				end
			else begin
				i_x <= i_x + 1;
				enable_i_y <= 0;
				end
			end
	end
	
	always @(posedge clock) begin
		if(!resetN)
			i_y <= 2'b00;
		else if(enable_i_y) begin // start to increase y
			if(i_y == 2'b11)
				i_y <= 2'b00;
			else
				i_y <= i_y + 1;
			end
	end
	
	assign x_out = x + i_x;
	assign y_out = y + i_y;
	assign colour_out = colour;

endmodule
	
module controller(go, resetN, clock, draw, ld_x, ld_y, ld_c, enable_i_x, plot);
	input go, resetN, clock, draw;
	output reg ld_x, ld_y, ld_c, enable_i_x, plot;
	
	reg [2:0] current_state, next_state;
	
	localparam 	S_Load_x = 3'd0,
				S_Load_x_wait = 3'd1,
				S_Load_y_c = 3'd2, // load the y coord and color in the same time
				S_Load_y_c_wait = 3'd3,
				S_Draw = 3'd4;
	
	always @(*) begin
		case (current_state)
			S_Load_x: next_state = go ? S_Load_x_wait : S_Load_x;
			S_Load_x_wait: next_state = go ? S_Load_x_wait : S_Load_y_c;
			S_Load_y_c: next_state = draw ? S_Load_y_c_wait : S_Load_y_c;
			S_Load_y_c_wait: next_state = draw ? S_Load_y_c_wait : S_Draw;
			S_Draw: next_state = go ? S_Load_x : S_Draw;
		endcase
	end
	
	always @(*) begin
		ld_x = 1'b0;
		ld_y = 1'b0;
		ld_c = 1'b0;
		plot = 1'b0;
		
		case(current_state)
			S_Load_x: begin
				ld_x = 1'b1;
				enable_i_x = 1'b1;
				end
			S_Load_y_c: begin
				ld_y = 1'b1;
				ld_c = 1'b1;
				end
			S_Draw: begin
				plot = 1'b1;
				end
		endcase
	end
	
	always @(posedge clock) begin
		if(!resetN) // active low reset
			current_state <= S_Load_x;
		else
			current_state = next_state;
	end

endmodule	


module combination(go, clock, resetN, draw, colour_in, location_in, x_out, y_out, colour_out);
	input clock, resetN, go, draw;
	input [2:0] colour_in;
	input [6:0] location_in;
	output [7:0] x_out;
	output [6:0] y_out;
	output [2:0] colour_out;
	
	wire ld_x, ld_y, ld_c, plot, enable_i_x;
	
	controller c0(.go(go), .resetN(resetN), .clock(clock), .draw(draw), .ld_x(ld_x), .ld_y(ld_y), .ld_c(ld_c), .enable_i_x(enable_i_x), .plot(plot)
	);
	
	datapath d0(.location_in(location_in), .colour_in(colour_in), .clock(clock), .resetN(resetN), .enable_i_x(enable_i_x), .ld_x(ld_x), .ld_y(ld_y), .ld_c(ld_c), .x_out(x_out), .y_out(y_out), .colour_out(colour_out)
	);
	
endmodule
				
	
	
	