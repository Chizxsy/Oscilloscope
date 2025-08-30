module framebuffer #(
    parameter COLOR_DEPTH   = 1,
    parameter SCREEN_WIDTH  = 640,
    parameter SCREEN_HEIGHT = 480
)(
    input                           clk,
    input                           clk_25,
    input        [9:0]              write_h,
    input        [9:0]              write_v,
    input        [COLOR_DEPTH-1:0]  write_data,
    input                           wren,
    input        [9:0]              read_h,
    input        [9:0]              read_v,
    input                           clear,
    output reg   [COLOR_DEPTH-1:0]  read_data_out,
    output wire                     clear_done
);

localparam NUM_PIXELS = SCREEN_WIDTH * SCREEN_HEIGHT;
localparam ADDR_WIDTH = 19;

reg [COLOR_DEPTH-1:0] pixel_memory [0:NUM_PIXELS-1];
wire [ADDR_WIDTH-1:0] write_addr = (write_v * SCREEN_WIDTH) + write_h;
wire [ADDR_WIDTH-1:0] read_addr  = (read_v  * SCREEN_WIDTH) + read_h;

reg [ADDR_WIDTH-1:0] clear_counter;
reg                  is_clearing;

assign clear_done = (clear_counter == NUM_PIXELS - 1) && is_clearing;

always @(posedge clk) begin
    if (clear && !is_clearing) begin
        is_clearing <= 1'b1;
        clear_counter <= 0;
    end

    if (is_clearing) begin
        pixel_memory[clear_counter] <= 1'b0;
        if (!clear_done) begin
            clear_counter <= clear_counter + 1;
        end else begin
            is_clearing <= 1'b0;
        end
    end else if (wren) begin
        pixel_memory[write_addr] <= write_data;
    end
end

always @(posedge clk_25) begin
    read_data_out <= pixel_memory[read_addr];
end

endmodule