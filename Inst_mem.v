module INSTMEM(Addr, Inst); 
	input  [31:0] Addr;
	output [31:0] Inst;
	wire [31:0] Ram [0:31];
	assign Ram[5'h00] = 32'h23DE000F; // addi R30 0x000F
	assign Ram[5'h01] = 32'h409e6000; //mtc0 R30 Status
	assign Ram[5'h02] = 32'h3C018000; //lui R1 , 0x1000
	assign Ram[5'h03] = 32'h3C028000; //lui R2 , 0x1000
	assign Ram[5'h04] = 32'h00411820; //add R3 , R1 , R2
	assign Ram[5'h05] = 32'h10220001; //beq R2 , R1 , 1
	assign Ram[5'h07] = 32'h00222824; // and  R5, R1, R2
	assign Ram[5'h08] = 32'h00210826;  //xor R1 R1 R1
	assign Ram[5'h09] = 32'h14610001; // bne R3 , R1 , 1
	assign Ram[5'h0A] = 32'h00222020;  //add R4 , R1 , R2
	assign Ram[5'h0B] = 32'h0000000C;  // syscall
	assign Ram[5'h0C] = 32'h00412822;  // sub R4 , R2 , R1
	assign Ram[5'h0D] = 32'hFFFFFFFF; // XXX
	assign Ram[5'h0E] = 32'h00021880; //sll R3 , R2 , 2
	assign Ram[5'h0F] = 32'h00021882; //srl R3 , R2 , 2

    //处理中断异常的指令
	assign Ram[5'h10] = 32'h400ba800; //mfc0 R29, Cause
	assign Ram[5'h11] = 32'h401c7000; //mfc0 R28,EPC;
	assign Ram[5'h12] = 32'h239C0004; //addi R28, R28, 4;
	assign Ram[5'h13] = 32'h409c7000; //mtc R28, EPC;
	assign Ram[5'h14] = 32'h42000018; //eret

	assign Inst = Ram[Addr[6:2]];
endmodule
