module ControlUnit(Op, Func, Z,Op1,rd, Wmem, Wreg, Regrt, Reg2reg, Aluc, Shift, Aluqb, Pcsrc, jal, Se,
intr,inta,ov,sta,cause,exc,wsta,wcau,wepc,mtc0,mfc0,selpc);
	
	input [5:0] Op, Func;
	input [4:0] Op1, rd;
	input Z;
	output [3:0] Aluc;
	output [1:0] Pcsrc;
	output Wmem, Wreg, Regrt, Se, Shift, Aluqb, Reg2reg, jal;
	
	input intr, ov;
	input [31:0]sta;
	output inta, exc,wsta, wcau, wepc, mtc0;
	output [1:0]mfc0,selpc;
	output [31:0] cause;
	
	    // R型指
        wire i_add = (Op == 6'b000000 & Func == 6'b100000)?1:0;
        wire i_sub = (Op == 6'b000000 & Func == 6'b100010)?1:0;
        wire i_and = (Op == 6'b000000 & Func == 6'b100100)?1:0;
        wire i_or  = (Op == 6'b000000 & Func == 6'b100101)?1:0;
        wire i_xor = (Op == 6'b000000 & Func == 6'b100110)?1:0;
        wire i_sll = (Op == 6'b000000 & Func == 6'b000000)?1:0;
        wire i_srl = (Op == 6'b000000 & Func == 6'b000010)?1:0;
        wire i_sra = (Op == 6'b000000 & Func == 6'b000011)?1:0;
        wire i_jr  = (Op == 6'b000000 & Func == 6'b001000)?1:0;
    
        // I型指
        wire i_addi = (Op == 6'b001000)?1:0;
        wire i_andi = (Op == 6'b001100)?1:0; 
        wire i_ori  = (Op == 6'b001101)?1:0;
        wire i_xori = (Op == 6'b001110)?1:0;
        wire i_lw   = (Op == 6'b100011)?1:0;
        wire i_sw   = (Op == 6'b101011)?1:0;
        wire i_beq  = (Op == 6'b000100)?1:0;
        wire i_bne  = (Op == 6'b000101)?1:0;
        wire i_lui  = (Op == 6'b001111)?1:0;
    
        // J型指
        wire i_j    = (Op == 6'b000010)?1:0;
        wire i_jal  = (Op == 6'b000011)?1:0; 
	
	// 判断是否为R型指令
    wire r_type = ~|Op;

	//判断是否为系统调用指令
	wire i_syscall = (r_type &(Func == 6'b001100))?1:0;

	//ov: alu运算时判断的是否溢出
	wire overflow = ov & (i_add | i_sub | i_addi);

	// 未实现命令集
	wire unimplemented_inst = ~(i_mfc0 | i_mtc0 | i_eret | i_syscall | i_add | i_sub | i_and | i_or| 
	i_xor| i_sll | i_srl | i_sra | i_jr | i_addi | i_andi | i_ori | i_xori | i_lw | i_sw | i_beq | i_bne |
	i_lui | i_j | i_jal);


	// sta 0: 外部中断, 1: 系统调用, 2: 未实现指令, 3: 溢出 
	//为“1”表示允许中断或异常
	wire int_int = sta[0] & intr;
	assign inta = int_int;

	wire exc_sys = sta[1] & i_syscall;
	wire exc_uni = sta[2] & unimplemented_inst;
	wire exc_ovr = sta[3] & overflow;
	assign exc = int_int | exc_sys | exc_uni | exc_ovr;
	
	// exccode(cause) 00 外部中断 01 系统调用 10 未实现指令 11 溢出
	wire ExcCode0 = i_syscall | overflow;
	wire ExcCode1 = unimplemented_inst | overflow;
	assign cause = {28'h0,ExcCode1, ExcCode0,2'b00};

	// 判断是什么指令
	wire c0_type = (Op == 6'b010000)?1:0;
	wire i_mfc0 = (c0_type &(Op1 == 5'b00000))?1:0;
	wire i_mtc0 = (c0_type &(Op1 == 5'b00100))?1:0; 
	wire i_eret = (c0_type &(Op1 == 5'b10000) & (Func == 6'b011000))?1:0;
	
	// 生成3个寄存器写使能信号, 根据rd判断
	wire rd_is_status = (rd == 5'd12);
	wire rd_is_cause = (rd == 5'd13);
	wire rd_is_epc = (rd == 5'd14);
    assign mtc0 = i_mtc0;

	//i_eret 更新status
    assign wsta = exc | mtc0 & rd_is_status | i_eret;
    assign wcau = exc | mtc0 & rd_is_cause;
    assign wepc = exc | mtc0 & rd_is_epc;

	// 执行mfc0 选择什么寄存器 00 原来  01 : Status 10: Cause 11: EPC 
    assign mfc0[0] = i_mfc0 & rd_is_status | i_mfc0 & rd_is_epc;
    assign mfc0[1] = i_mfc0 & rd_is_cause | i_mfc0 & rd_is_epc;

	// 执行PC 选择什么  00 原来   01: EPC 10 处理异常入口  
    assign selpc[0] = i_eret;
    assign selpc[1] = exc;	
	
	
	assign Wreg  = i_add  | i_sub  | i_and | i_or | i_xor  | 
	i_sll | i_srl |i_sra |	i_addi | i_andi | 
	i_ori | i_or | i_xori | i_lw  | i_lui |i_jal | i_mfc0;
	assign Regrt  = i_addi | i_andi | i_ori | i_xori |i_lw |i_lui | i_mfc0;//mfc0选择rt输入
	assign jal = i_jal;
	assign Reg2reg  = i_lw;
	assign Shift  = i_sll | i_srl |i_sra;
	assign Aluqb = i_addi | i_andi | i_ori | i_xori | i_lw | i_lui |i_sw;
	assign Se = i_addi | i_lw | i_sw | i_beq | i_bne;
	assign Aluc[3] = i_sra;
	assign Aluc[2] = i_sub |i_or | i_srl | i_sra | i_ori |i_lui;
	assign Aluc[1] = i_xor | i_sll | i_srl | i_sra | i_xori |
	 i_beq | i_bne | i_lui;
	assign Aluc[0] = i_and | i_or | i_sll | i_srl |i_sra |
	 i_andi  | i_ori;
	assign Wmem  = i_sw;
	assign Pcsrc[1] = i_jr | i_j | i_jal;
	assign Pcsrc[0] = i_beq & Z | i_bne&~Z | i_j | i_jal;
endmodule
