module clock_div (
	input clk,
	input reset_n,
	output reg clk_25

);

always @(posedge clk or negedge reset_n)
	begin
		if (!reset_n) begin
			clk_25 <= 0;
		end else begin
		clk_25 = ~clk_25;
	
		end
	end
endmodule