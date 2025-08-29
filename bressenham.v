module bressenham (
    input               clk,
    input               reset_n,
    input               start,
    input       [9:0]   x1, x0,
    input       [9:0]   y1, y0, // Changed to 10-bit
    
    output reg  [9:0]   v,      // Changed to 10-bit
    output reg  [9:0]   h,
    output reg          done,
    output reg          plot_px,
    output reg          busy
);

localparam S_IDLE   = 2'b00, S_SETUP  = 2'b01, S_DRAW   = 2'b10, S_DONE   = 2'b11;
reg [1:0] state;

wire signed [10:0] dx = (x1 > x0) ? (x1 - x0) : (x0 - x1);
wire signed [10:0] dy = (y1 > y0) ? (y1 - y0) : (y0 - y1); // Changed to 10-bit
reg         [9:0]  x_curr;
reg         [9:0]  y_curr; // Changed to 10-bit
reg                sx, sy;
reg  signed [11:0] err;
wire signed [12:0] e2 = err << 1;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        state <= S_IDLE; 
        h <= 0;
        v <= 0;
        plot_px <= 1'b0;
        done <= 1'b0; 
        busy <= 1'b0; 
        x_curr <= 0; 
        y_curr <= 0;
        sx <= 0; 
        sy <= 0; 
        err <= 0;
    end else begin
        plot_px <= 1'b0;
         done <= 1'b0;
        case(state)
            S_IDLE: begin
                busy <= 1'b0;
                if (start) state <= S_SETUP;
            end
            S_SETUP: begin
                busy <= 1'b1; 
                x_curr <= x0;
                 y_curr <= y0;
                sx <= (x0 < x1) ? 1'b0 : 1'b1;
                sy <= (y0 < y1) ? 1'b0 : 1'b1;
                err <= dx - dy;
                state <= S_DRAW;
            end
            S_DRAW: begin
                busy <= 1'b1;
                 plot_px <= 1'b1;
                h <= x_curr; 
                v <= y_curr;
                if (x_curr == x1 && y_curr == y1) begin
                    state <= S_DONE;
                end else begin
                    if (e2 >= -dy) begin
                        err <= err - dy;
                        if(sx == 1'b0) x_curr <= x_curr + 1; else x_curr <= x_curr - 1;
                    end
                    if (e2 <= dx) begin
                        err <= err + dx;
                        if(sy == 1'b0) y_curr <= y_curr + 1; else y_curr <= y_curr - 1;
                    end
                end
            end
            S_DONE: begin
                done <= 1'b1; 
                state <= S_IDLE;
            end
            default: state <= S_IDLE;
        endcase
    end
end
endmodule