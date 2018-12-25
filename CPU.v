module CPU(Clk, Clrn, Inst, Dread, Iaddr, Wmem, Dwirte, Daddr, intr, inta);

	input Clk, Clrn, intr;
	input [31:0] Inst, Dread;
	output [31:0] Iaddr, Daddr, Dwirte;
	output Wmem, inta;
	
    parameter EXC_BASE = 32'h00000040;
    wire [31:0] p4, adr, npc, res, ra, alu_mem, alua, alub;
    wire [4:0] reg_dest, wn;
    wire [3:0] aluc;
    wire [1:0] Pcsrc;
    wire zero, wreg, regrt, reg2reg, shift, aluqb, jal, se, overflow;
    

	wire [31:0] sa = {27'b0 , Inst[10:6]};  

	wire e = se & Inst[15];

	wire [15:0] sign = {16{e}};

	wire [31:0] offset = {sign[13:0], Inst[15:0], 2'b00}; 
		 
    wire [31:0] immdiate = {sign , Inst[15:0]}; 
    
    wire exc, wsta, wcau, wepc, mtc0;
    wire [31:0] sta, cau, epc, sta_in, cau_in, epc_in, sta_l1_a0, epc_l1_a0, cause, alu_mem_c0,next_pc;
    wire [1:0] mfc0, selpc;
    wire [31:0] jpc = {p4[31:28] , Inst[25:0],2'b00}; 

	// 三个寄存器
    dffe32 c0_Status (sta_in, Clk, Clrn, wsta, sta);
	dffe32 c0_Cause (cau_in, Clk, Clrn, wcau, cau);
	dffe32 c0_EPC (epc_in,Clk,Clrn, wepc, epc);


    ControlUnit CU (Inst[31:26], Inst[5:0], zero,Inst[25:21],Inst[15:11],  Wmem, wreg, regrt, reg2reg, aluc,shift, aluqb, Pcsrc, jal, se,
        intr,inta,overflow,sta,cause,exc,wsta,wcau,wepc,mtc0,mfc0,selpc);
        
	dff32 ip (next_pc , Clk , Clrn , Iaddr); 

	cla32 pcplus4(Iaddr , 32'h4 , 1'b0 , p4);

	cla32 br_adr(p4, offset, 1'b0, adr);

	
	
	assign wn = reg_dest | {5{jal}}; 
	RegFile rf (Inst[25:21], Inst[20:16], res, wn,
	                wreg, Clk, Clrn, ra, Daddr);               
			
	MUX2X32 alu_a (ra , sa , shift , alua);
	MUX2X32 alu_b (Daddr, immdiate, aluqb, alub);

	ALU alu(alua, alub, aluc, Dwirte, zero, overflow);
	
	MUX2X5 reg_wn (Inst[15:11], Inst[20:16], regrt, reg_dest);

	MUX2X32 res_mem(Dwirte, Dread, reg2reg , alu_mem);
	MUX4X32 nextpc( p4 , adr , ra , jpc , Pcsrc , npc);		
	

	
	
	MUX2X32 sta_l1 (sta_l1_a0, Daddr,mtc0,sta_in);
	MUX2X32 sta_l2 ({4'h0,sta[31:4]}, {sta[27:0],4'h0}, exc, sta_l1_a0);
	
	MUX2X32 cau_l1 (cause, Daddr, mtc0,cau_in);
	
	MUX2X32 epc_l1 (epc_l1_a0, Daddr, mtc0, epc_in);
	MUX2X32 epc_l2 (Iaddr, npc, inta, epc_l1_a0);
	
	
	// PC跳转
	MUX4X32 irq_pc (npc, epc,EXC_BASE, 32'h0, selpc, next_pc);
	
	MUX4X32 fromc0 (alu_mem, sta, cau, epc, mfc0,alu_mem_c0);
    MUX2X32 link(alu_mem_c0,  p4 , jal , res);

	
endmodule
