module Main(Clk, Clrn, inst, addr, aluout, memout, intr, inta);
	input Clk, Clrn,intr;
	output [31:0] inst, addr, aluout, memout;
	output inta;
	wire [31:0] data;
	wire        wmem;	
	INSTMEM imem(addr, inst);
	CPU cpu (Clk, Clrn, inst, memout, addr, wmem, data, aluout, intr, inta);
	DATAMEM dmem(Clk, memout, data, aluout, wmem );
endmodule
