module adc_data_conv(
    input clk,
    input reset_n,
    input [9:0] y_adc_data_in,
    input bressenham_done,
    input sample_valid,
    input clear_done,
    output reg [9:0] x1, x0,
    output reg [9:0] y1, y0,
    output reg bressenham_start,
    output wire ready_flag,
    output reg clear_screen
);

    localparam SCREEN_WIDTH = 640;

    // To see ~2 cycles of a 1kHz wave, we need a ~2000us sweep.
    // ADC sample period is 0.1us. Time between points = 2000us / 640 = 3.125us.
    // Decimation = 3.125us / 0.1us = 31.25. We'll use 32.
    localparam DECIMATION_FACTOR = 100;

    localparam S_CLEAR_START = 3'b001;
    localparam S_CLEAR_WAIT  = 3'b010;
    localparam S_DRAW        = 3'b100;

    reg [2:0] state;
    reg [9:0] x_prev;
    reg [9:0] y_prev;
    reg is_drawing;
    reg [5:0] decimation_counter; // Counter for skipping samples

    assign ready_flag = !is_drawing;

    always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        state <= S_CLEAR_START;
        x_prev <= 0;
        y_prev <= 240;
        is_drawing <= 1'b1;
        bressenham_start <= 1'b0;
        clear_screen <= 1'b0;
        decimation_counter <= 0;
    end else begin
        // Defaults
        bressenham_start <= 1'b0;
        clear_screen <= 1'b0;

        // When the line drawer finishes its work, we are no longer busy.
        if (bressenham_done) is_drawing <= 1'b0;
        
        case(state)
            S_CLEAR_START: begin
                // ** THE FIX IS HERE **
                // 1. Start the framebuffer clear.
                clear_screen <= 1'b1;
                // 2. Reset the drawing coordinates for the new trace.
                x_prev <= 0;
                y_prev <= 240;
                // 3. Move to the next state to wait for the clear to finish.
                state <= S_CLEAR_WAIT;
            end
            
            S_CLEAR_WAIT: begin
                // Wait until the framebuffer signals it's done.
                if (clear_done) begin
                    is_drawing <= 1'b0; // We are now ready to draw.
                    state <= S_DRAW;
                    decimation_counter <= 0;
                end
            end
            
            S_DRAW: begin
                // If a sample is available AND we are ready...
                if (ready_flag && sample_valid) begin
                    if (decimation_counter >= DECIMATION_FACTOR - 1) begin
                        // --- Plot this sample ---
                        decimation_counter <= 0;
                        is_drawing <= 1'b1;
                        bressenham_start <= 1'b1;
                        
                        x0 <= x_prev; y0 <= y_prev;
                        x1 <= x_prev + 1; y1 <= y_adc_data_in;
                        y_prev <= y_adc_data_in;

                        if (x_prev >= SCREEN_WIDTH - 2) begin
                            state <= S_CLEAR_START; // Full sweep is done, go back to clear.
                        end else begin
                            x_prev <= x_prev + 1; // Move to the next pixel.
                        end
                    end else begin
                        // --- Skip this sample ---
                        decimation_counter <= decimation_counter + 1;
                    end
                end
            end
        endcase
    end
end
endmodule