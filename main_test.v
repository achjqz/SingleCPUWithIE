module test_main();
    reg Clock;
	reg Reset;
	reg intr;
	wire[31:0] inst;
	wire[31:0] addr;
	wire[31:0] aluout;
	wire[31:0] memout;
	wire inta;
	
	
    Main main(.Clk(Clock), .Clrn(Reset), .inst(inst), .addr(addr), .aluout(aluout), .memout(memout),
     .intr(intr), .inta(inta));
    initial begin
		$dumpfile("test.vcd");  
        $dumpvars(0,test_main);
		Clock = 0;
		Reset = 0;
        intr = 0;
		#100;
		Reset <= 1;

		#3000 $finish();
	end
	
	always begin
	   #25;
	   Clock = ~Clock; 
	end
endmodule