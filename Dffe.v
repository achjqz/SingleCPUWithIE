module dffe32(D, Clock, Reset,We, Q);	 
	input Clock, Reset,We;
	input [31:0] D;
	output reg [31:0] Q;
	always @(posedge Clock or negedge Reset) 
		if (Reset == 0) begin
			Q <= 0;
		end else begin
			if (We) Q <= D;
		end
endmodule

