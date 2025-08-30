// Copyright (C) 2016  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel MegaCore Function License Agreement, or other 
// applicable license agreement, including, without limitation, 
// that your use is for the sole purpose of programming logic 
// devices manufactured by Intel and sold by Intel or its 
// authorized distributors.  Please refer to the applicable 
// agreement for further details.

// PROGRAM		"Quartus Prime"
// VERSION		"Version 16.1.0 Build 196 10/24/2016 SJ Lite Edition"
// CREATED		"Wed Jun 25 19:12:01 2025"

module pwm_led_top(
	MAX10_CLK1_50,
	ADC_CLK_10,
	ARDUINO_RESET_N,
	SW,
	ARDUINO_IO,
	LEDR,
	VGA_B,
	VGA_G,
	VGA_HS,
	VGA_R,
	VGA_VS,
	blank
);

localparam SCREEN_WIDTH  = 640;
localparam SCREEN_HEIGHT = 480;
localparam COLOR_DEPTH   = 1;


input wire	MAX10_CLK1_50;
input wire	ADC_CLK_10;
input wire	ARDUINO_RESET_N;
input wire	[9:0] SW;
output wire	[0:0] ARDUINO_IO;

output wire	[9:0] LEDR;

output 		  [3:0]	VGA_B;
output 	     [3:0]	VGA_G;
output 	          	VGA_HS;
output 	     [3:0]	VGA_R;
output 		         VGA_VS;
output 					blank;

wire	[2:0] duty_cycle;
wire	duty_cycle_clk;
wire	pwm;
wire	pwm_clk;
wire	SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_1;
wire	SYNTHESIZED_WIRE_2;
wire	SYNTHESIZED_WIRE_3;
wire	[9:0] SYNTHESIZED_WIRE_4;
wire	[1:0] SYNTHESIZED_WIRE_5;
wire	[15:0] SYNTHESIZED_WIRE_6;
wire	[11:0] SYNTHESIZED_WIRE_7;
wire	SYNTHESIZED_WIRE_8;
wire	SYNTHESIZED_WIRE_9;
wire	SYNTHESIZED_WIRE_10;
wire	SYNTHESIZED_WIRE_11;
wire	SYNTHESIZED_WIRE_12;
wire	SYNTHESIZED_WIRE_13;
wire	[15:0] SYNTHESIZED_WIRE_14;
wire	[4:0] SYNTHESIZED_WIRE_15;
wire	[11:0] SYNTHESIZED_WIRE_16;
wire	SYNTHESIZED_WIRE_17;

wire clear_fb;
wire fb_clear_done;

//wire [9:0] x_prev_from_conv;

wire vga_clk_25;

wire [11:0] fifo_q;
wire        fifo_rdempty;

wire [11:0] out_conv;             // Raw 12-bit data from ADC Core
wire        sample_valid;      // Pulse from our ADC interface


wire [9:0]  x0_px, x1_px;          // Line segment endpoints
wire [9:0]  y0_px, y1_px;
wire        line_is_done;             // Feedback that drawing is finished

wire [9:0]  draw_h, draw_v;           // Pixel coordinates from Bresenham
wire        plot_pixel_now;               // Pulse to plot a pixel
wire start_wire;
wire [3:0]  pixel_data_from_ram;      // Pixel color read from framebuffer
wire [9:0]  vga_h_counter, vga_v_counter; // Read address for framebuffer
wire [9:0]  y_scaled_from_adc;

wire adc_is_ready;

assign	ARDUINO_IO[0] = SYNTHESIZED_WIRE_17;
assign	LEDR[0] = SYNTHESIZED_WIRE_17;

assign LEDR[7] = adc_is_ready;
assign LEDR[8] = !fifo_rdempty;
assign LEDR[9] = start_wire;



pwm_pll	b2v_inst(
	.inclk0(MAX10_CLK1_50),
	.c0(pwm_clk),
	.c1(duty_cycle_clk));


pwm_gen pwm_generator_inst (
    .clk(pwm_clk),
    .duty_cycle(duty_cycle),
    .pwm(pwm)
);


vga_pll b2v_inst1(
    .inclk0(MAX10_CLK1_50),
	 .c4(vga_clk_25));
	

ADC	b2v_inst11(
	.clk_clk(ADC_CLK_10),
	.mm_bridge_0_s0_burstcount(SYNTHESIZED_WIRE_0),
	.mm_bridge_0_s0_write(SYNTHESIZED_WIRE_1),
	.mm_bridge_0_s0_read(SYNTHESIZED_WIRE_2),
	.mm_bridge_0_s0_debugaccess(SYNTHESIZED_WIRE_3),
	.reset_reset_n(ARDUINO_RESET_N),
	.mm_bridge_0_s0_address(SYNTHESIZED_WIRE_4),
	.mm_bridge_0_s0_byteenable(SYNTHESIZED_WIRE_5),
	.mm_bridge_0_s0_writedata(SYNTHESIZED_WIRE_6),
	.mm_bridge_0_s0_waitrequest(SYNTHESIZED_WIRE_8),
	.mm_bridge_0_s0_readdatavalid(SYNTHESIZED_WIRE_9),
	.modular_adc_0_response_valid(SYNTHESIZED_WIRE_10),
	.modular_adc_0_response_startofpacket(SYNTHESIZED_WIRE_12),
	.modular_adc_0_response_endofpacket(SYNTHESIZED_WIRE_13),
	.modular_adc_0_response_empty(SYNTHESIZED_WIRE_11),
	.mm_bridge_0_s0_readdata(SYNTHESIZED_WIRE_14),
	.modular_adc_0_response_channel(SYNTHESIZED_WIRE_15),
	.modular_adc_0_response_data(SYNTHESIZED_WIRE_16));

assign	SYNTHESIZED_WIRE_17 =  ~pwm;

// clock domain crossing fifo
cdcfifo fifo_inst(
	// write side
	.wrclk(ADC_CLK_10),
	.data(SYNTHESIZED_WIRE_16),
	.wrreq(SYNTHESIZED_WIRE_10), // adc valid write request
	// read side
	.rdclk(MAX10_CLK1_50),
	.rdreq(adc_is_ready),
	.q(fifo_q),
	.rdempty(fifo_rdempty)
);

// PWM duty cycle selection for testing
// sw1 shift register debounce
debouncer	b2v_inst3(
	.noisy(SW[0]),
	.clk(duty_cycle_clk),
	.debounced(duty_cycle[0]));

// sw2 shift register debounce

debouncer	b2v_inst4(
	.noisy(SW[1]),
	.clk(duty_cycle_clk),
	.debounced(duty_cycle[1]));

// sw3 shift reg debounce

debouncer	b2v_inst5(
	.noisy(SW[2]),
	.clk(duty_cycle_clk),
	.debounced(duty_cycle[2]));


//SEG7_LUT_6	b2v_inst7(
//	.iDIG(SYNTHESIZED_WIRE_7),
//	.oSEG0(HEX0),
//	.oSEG1(HEX1),
//	.oSEG2(HEX2),
//	.oSEG3(HEX3),
//	.oSEG4(HEX4),
//	.oSEG5(HEX5));


ADC_connect	b2v_inst8(
	.clk(ADC_CLK_10),
	.reset_n(ARDUINO_RESET_N),
	.mm_bridge_0_s0_waitrequest(SYNTHESIZED_WIRE_8),
	.mm_bridge_0_s0_readdatavalid(SYNTHESIZED_WIRE_9),
	.modular_adc_0_valid(),
	.modular_adc_0_response_empty(),
	.modular_adc_0_startofpacket(),
	.modular_adc_0_endofpacket(),
	.mm_bridge_0_s0_readdata(SYNTHESIZED_WIRE_14),
	.modular_adc_0_channel(),
	.modular_adc_0_data(),
	.mm_bridge_0_s0_burstcount(SYNTHESIZED_WIRE_0),
	.mm_bridge_0_s0_write(SYNTHESIZED_WIRE_1),
	.mm_bridge_0_s0_read(SYNTHESIZED_WIRE_2),
	.mm_bridge_0_s0_debugaccess(SYNTHESIZED_WIRE_3),
	.data_out(SYNTHESIZED_WIRE_7),
	.mm_bridge_0_s0_address(SYNTHESIZED_WIRE_4),
	.mm_bridge_0_s0_byteenable(SYNTHESIZED_WIRE_5),
	.mm_bridge_0_s0_writedata(SYNTHESIZED_WIRE_6));


// causes issues with clock crossing	
/* 
adc_data_out adc_data_out_inst(
	.clk(MAX10_CLK1_50),
	.data_out(),
	.avl_str_sink_valid(SYNTHESIZED_WIRE_10),
	.avl_str_sink_data(SYNTHESIZED_WIRE_16),
	.avl_str_sink_channel(SYNTHESIZED_WIRE_15),
	.data_valid(sample_valid)

);
*/

// scaled adc value from the dual port fifo
assign y_scaled_from_adc = (fifo_q * SCREEN_HEIGHT) >> 12;

adc_data_conv adc_data_conv_instance (
	.clk(MAX10_CLK1_50),
	.reset_n(ARDUINO_RESET_N),
	.y_adc_data_in(y_scaled_from_adc),
	.bressenham_done(line_is_done),
	.ready_flag(adc_is_ready),
	.sample_valid(!fifo_rdempty),
	.x1(x1_px),
	.x0(x0_px),
	.y1(y1_px),
	.y0(y0_px),
	.bressenham_start(start_wire),
	.clear_done(fb_clear_done),     
    .clear_screen(clear_fb)
	
);
	

linedrawer linedrawer_instance (
	.clk(MAX10_CLK1_50),
	.reset_n(ARDUINO_RESET_N),
	.start(start_wire),
	.x0(x0_px),
	.y0(y0_px),
	.x1(x1_px),
	.y1(y1_px),
	.h(draw_h),
	.v(draw_v),
	.plot_px(plot_pixel_now),
	.done(line_is_done)
); 


framebuffer #(
	.SCREEN_HEIGHT(SCREEN_HEIGHT),
	.SCREEN_WIDTH(SCREEN_WIDTH),
	.COLOR_DEPTH(COLOR_DEPTH)
) framebuffer_instance (
	.clk(MAX10_CLK1_50),
	.clk_25(vga_clk_25),
	.write_v(draw_v),
	.write_h(draw_h),
	.write_data(1'b1),
	.wren(plot_pixel_now),
	.read_v(vga_v_counter),
	.read_h(vga_h_counter),
	.read_data_out(pixel_data_from_ram),
	.clear(clear_fb),
    .clear_done(fb_clear_done)
);


vga_control u0 (.clk(MAX10_CLK1_50),
					.reset_n(ARDUINO_RESET_N),
					.clk_25(vga_clk_25),
					.data_in(pixel_data_from_ram),
					.v_counter(vga_v_counter),
					.h_counter(vga_h_counter),
					.blue_out(VGA_B),
					.green_out(VGA_G),
					.hsync(VGA_HS),
					.red_out(VGA_R), 
					.vsync(VGA_VS),
					.blank(blank));


//assign LEDR[8] = !fifo_rdempty;
//assign LEDR[9] = start_wire;
//assign LEDR = x_prev_from_conv;
endmodule
