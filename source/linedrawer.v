module linedrawer(
    input               clk,
    input               reset_n,
    input               start,
    input       [9:0]   x0, y0, x1, y1,
    
    output reg  [9:0]   h, v,
    output reg          plot_px,
    output reg          done
);

// This simple FSM just plots the two endpoints of the line segment.
localparam S_IDLE  = 2'b00, S_PLOT0 = 2'b01, S_PLOT1 = 2'b10, S_DONE = 2'b11;
reg [1:0] state;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        state   <= S_IDLE;
        plot_px <= 1'b0;
        done    <= 1'b0;
        h       <= 0;
        v       <= 0;
    end else begin
        // Defaults
        plot_px <= 1'b0;
        done    <= 1'b0;

        case(state)
            S_IDLE: begin
                if (start) state <= S_PLOT0;
            end
            
            S_PLOT0: begin // Plot the first point
                plot_px <= 1'b1;
                h <= x0;
                v <= y0;
                state <= S_PLOT1;
            end
            
            S_PLOT1: begin // Plot the second point
                plot_px <= 1'b1;
                h <= x1;
                v <= y1;
                state <= S_DONE;
            end

            S_DONE: begin // Signal that we are done
                done <= 1'b1;
                state <= S_IDLE;
            end
        endcase
    end
end
endmodule