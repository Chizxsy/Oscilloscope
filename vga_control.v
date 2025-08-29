module vga_control(
    input clk,
	 input clk_25,
    input reset_n,
    input [3:0]data_in,
    output hsync,
    output vsync,
    output [3:0] red_out,
    output [3:0] green_out,
    output [3:0] blue_out,
    output blank,
    //output reg clk_25,
    output reg [11:0] v_counter,
    output reg [9:0] h_counter

);

// VGA 640x480 @ 60Hz Timing
localparam H_VISIBLE_PIXELS = 640;
localparam H_FRONT_PORCH = 16;
localparam H_SYNC_PULSE = 96;
localparam H_TOTAL = 800;

localparam V_VISIBLE_LINES = 480;
localparam V_FRONT_PORCH = 10;
localparam V_SYNC_PULSE = 2;
localparam V_TOTAL = 525;

localparam H_SYNC_START = H_VISIBLE_PIXELS + H_FRONT_PORCH;
localparam H_SYNC_END = H_SYNC_START + H_SYNC_PULSE;

localparam V_SYNC_START = V_VISIBLE_LINES + V_FRONT_PORCH;
localparam V_SYNC_END = V_SYNC_START + V_SYNC_PULSE;


reg [3:0] red_reg;
reg [3:0] green_reg;
reg [3:0] blue_reg;
//sync
reg hsync_reg;
reg vsync_reg;
reg blank_reg;

// Output assignments
assign hsync = hsync_reg;
assign vsync = vsync_reg;
assign blank = blank_reg;
assign red_out = red_reg;
assign green_out = green_reg;
assign blue_out = blue_reg;

/*
always @(posedge clk or negedge reset_n)
	begin
		if (!reset_n) begin
			clk_25 <= 0;
		end else begin
		clk_25 = ~clk_25;
		end
	end
	
*/

// VGA logic
always @(posedge clk_25 or negedge reset_n) begin
    if (!reset_n) begin
        h_counter <= 0;
        v_counter <= 0;
        hsync_reg <= 1;
        vsync_reg <= 1;
        blank_reg <= 1;
        red_reg <= 0;
        green_reg <= 0;
        blue_reg <= 0;
    end else begin

        // Horizontal counter
        if (h_counter < H_TOTAL - 1)
            h_counter <= h_counter + 1;
        else begin
            h_counter <= 0;
            if (v_counter < V_TOTAL - 1)
                v_counter <= v_counter + 1;
            else
                v_counter <= 0;
        end

        // Sync signals
        hsync_reg <= (h_counter >= H_SYNC_START && h_counter < H_SYNC_END) ? 0 : 1;
        vsync_reg <= (v_counter >= V_SYNC_START && v_counter < V_SYNC_END) ? 0 : 1;

        // Blanking
        blank_reg <= (h_counter >= H_VISIBLE_PIXELS || v_counter >= V_VISIBLE_LINES);

        
        if (h_counter < H_VISIBLE_PIXELS && v_counter < V_VISIBLE_LINES) begin

            red_reg <= data_in;
            green_reg <= data_in;
            blue_reg <= data_in;

        end else begin
            red_reg <= 4'd0;
            green_reg <= 4'd0; 
            blue_reg <= 4'd0;
        end

end
end 
endmodule
