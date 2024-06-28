`timescale 1ns / 1ps

`include "control.v"

`include "f_register.v"
`include "d_register.v"
`include "e_register.v"
`include "m_register.v"
`include "w_register.v"

`include "fetch_pc.v"
`include "decode_wb.v"
`include "execute.v"
`include "memory.v"

module pipeline_processor;
    
    reg clk;
    reg stat;
    initial begin
        $dumpfile("pipe.vcd");
        $dumpvars(0,pipeline_processor);
        clk = 0;
        forever begin
            #5;
            clk = ~clk;
        end
    end

    wire F_stall, D_bubble, D_stall, E_bubble, M_bubble, W_stall;
    wire [63:0] F_pc_prelim;
    wire [63:0] f_predPC;
    wire [1:0] f_stat;
    wire [3:0] f_icode;
    wire [3:0] f_ifun; 
    wire [3:0] f_rA;
    wire [3:0] f_rB;
    wire [63:0] f_valC;
    wire [63:0] f_valP;
    wire [63:0] f_pc;
    wire [3:0] M_icode;
    wire [3:0] W_icode;
    wire [63:0] M_valA;
    wire [63:0] W_valM;
    wire  M_cnd;
    wire [1:0] D_stat;
    wire [3:0] D_icode;
    wire [3:0] D_ifun; 
    wire [3:0] D_rA;
    wire [3:0] D_rB;
    wire [63:0] D_valC;
    wire [63:0] D_valP;
    wire [1:0] d_stat;
    wire[3:0] d_icode;
    wire [3:0] d_ifun;
    wire[63:0] d_valC;
    wire[63:0] d_valB;
    wire[63:0] d_valA;
    wire[3:0] d_dstE;
    wire[3:0] d_dstM;
    wire[3:0] d_srcA; 
    wire[3:0] d_srcB;
    wire [1:0] E_stat;
    wire [3:0] E_icode;
    wire [3:0] E_ifun;
    wire [63:0] E_valC;
    wire [63:0] E_valB;
    wire [63:0] E_valA;
    wire [3:0] E_dstE; 
    wire [3:0] E_dstM;
    wire [3:0] E_srcA;
    wire [3:0] E_srcB;
    wire [1:0] e_stat;
    wire [3:0] e_icode;
    wire  e_cnd, zero_flag, sign_flag, overflow_flag;
    wire [63:0] e_valE;
    wire [63:0] e_valA;
    wire [3:0] e_dstE;
    wire [3:0] e_dstM;
    wire [1:0] M_stat;
    wire[63:0] M_valE;
    wire[3:0] M_dstE; 
    wire[3:0] M_dstM;
    wire [1:0] m_stat;
    wire [3:0] m_icode;
    wire [63:0] m_valE;
    wire [63:0] m_valM;
    wire [3:0] m_dstE;
    wire [3:0] m_dstM;
    wire [1:0] W_stat;
    wire [63:0] W_valE;
    wire [3:0] W_dstE;
    wire [3:0] W_dstM;

    wire [63:0] registers[0:14];

    control control(
        .clk(clk),
        .d_srcA(d_srcA), .d_srcB(d_srcB), .D_icode(D_icode),
        .E_dstM(E_dstM), .E_icode(E_icode),
        .e_cnd(e_cnd), 
        .M_icode(M_icode),
        .W_stat(W_stat), .m_stat(m_stat),
        .F_stall(F_stall),
        .D_bubble(D_bubble), .D_stall(D_stall),
        .E_bubble(E_bubble),
        .set_cc(set_cc),
        .M_bubble(M_bubble),
        .W_stall(W_stall)
    ); 

    f_register f_register(
        .F_stall(F_stall),
        .f_predPC(f_predPC),
        .clk(clk),
        .F_pc_prelim(F_pc_prelim)
    );

    pc_update pc_update(
        .f_pc(f_pc),
        .M_icode(M_icode),
        .W_icode(W_icode),
        .M_valA(M_valA),
        .W_valM(W_valM),
        .M_cnd(M_cnd),
        .F_pc_prelim(F_pc_prelim),
        .clk(clk)
    );

    fetch fetch(
        .f_icode(f_icode),
        .f_ifun(f_ifun),
        .f_rA(f_rA),
        .f_rB(f_rB),
        .f_valC(f_valC),
        .f_valP(f_valP),
        .clk(clk),
        .f_pc(f_pc),
        .f_predPC(f_predPC),
        .f_stat(f_stat)
    );

    d_register d_register(
        .clk(clk), .D_bubble(D_bubble), .D_stall(D_stall),
        .f_stat(f_stat),
        .f_icode(f_icode),
        .f_ifun(f_ifun),
        .f_rA(f_rA),
        .f_rB(f_rB),
        .f_valC(f_valC),
        .f_valP(f_valP),
        .D_stat(D_stat),
        .D_icode(D_icode),
        .D_ifun(D_ifun),
        .D_rA(D_rA),
        .D_rB(D_rB),
        .D_valC(D_valC),
        .D_valP(D_valP)
    );

    decode_wb decode_wb(
        .clk(clk),
        .D_stat(D_stat),
        .D_icode(D_icode),
        .D_ifun(D_ifun),
        .D_rA(D_rA),
        .D_rB(D_rB),
        .D_valC(D_valC),
        .D_valP(D_valP),
        .e_dstE(e_dstE),
        .e_valE(e_valE),
        .M_dstE(M_dstE),
        .M_valE(M_valE),
        .M_dstM(M_dstM),
        .m_valM(m_valM),
        .W_stat(W_stat),
        .W_icode(W_icode),
        .W_valE(W_valE),
        .W_valM(W_valM),
        .W_dstE(W_dstE),
        .W_dstM(W_dstM),
        .d_stat(d_stat),
        .d_icode(d_icode),
        .d_ifun(d_ifun),
        .d_valC(d_valC),
        .d_valA(d_valA),
        .d_valB(d_valB),
        .d_dstE(d_dstE),
        .d_dstM(d_dstM),
        .d_srcA(d_srcA),
        .d_srcB(d_srcB),
        .reg0(registers[0]),
        .reg1(registers[1]),
        .reg2(registers[2]), 
        .reg3(registers[3]),
        .reg4(registers[4]),
        .reg5(registers[5]),
        .reg6(registers[6]),
        .reg7(registers[7]),
        .reg8(registers[8]),
        .reg9(registers[9]),
        .regA(registers[10]),
        .regB(registers[11]),
        .regC(registers[12]),
        .regD(registers[13]),
        .regE(registers[14])
    );

    e_register e_register(
        .E_bubble(E_bubble),
        .clk(clk),
        .d_stat(d_stat),
        .d_icode(d_icode),
        .d_ifun(d_ifun),
        .d_valC(d_valC),
        .d_valB(d_valB),
        .d_valA(d_valA),
        .d_dstE(d_dstE),
        .d_dstM(d_dstM),
        .d_srcA(d_srcA),
        .d_srcB(d_srcB),
        .E_stat(E_stat),
        .E_icode(E_icode),
        .E_ifun(E_ifun),
        .E_valC(E_valC),
        .E_valB(E_valB),
        .E_valA(E_valA),
        .E_dstE(E_dstE),
        .E_dstM(E_dstM),
        .E_srcA(E_srcA),
        .E_srcB(E_srcB)
    );

    execute execute(
        .e_valE(e_valE),
        .e_cnd(e_cnd), .zero_flag(zero_flag), .sign_flag(sign_flag), .overflow_flag(overflow_flag),
        .e_valA(e_valA),
        .e_dstE(e_dstE), .e_dstM(e_dstM), .e_icode(e_icode),
        .e_stat(e_stat),
        .clk(clk),
        .E_icode(E_icode),
        .E_ifun(E_ifun),
        .E_valA(E_valA),
        .E_valB(E_valB),
        .E_valC(E_valC),
        .E_dstE(E_dstE),
        .E_dstM(E_dstM),
        .E_stat(E_stat),
        .set_cc(set_cc)
    );

    m_register m_register(
        .clk(clk),
        .M_bubble(M_bubble),
        .e_stat(e_stat),
        .e_icode(e_icode),
        .e_cnd(e_cnd),
        .e_valE(e_valE),
        .e_valA(e_valA),
        .e_dstE(e_dstE),
        .e_dstM(e_dstM),
        .M_stat(M_stat),
        .M_icode(M_icode),
        .M_cnd(M_cnd),
        .M_valE(M_valE),
        .M_valA(M_valA),
        .M_dstE(M_dstE),
        .M_dstM(M_dstM)
    );

    memory memory(
        .clk(clk),
        .M_stat(M_stat),
        .M_icode(M_icode),
        .M_valA(M_valA),
        .M_valE(M_valE),
        .M_dstE(M_dstE),
        .M_dstM(M_dstM),
        .m_icode(m_icode),
        .m_valM(m_valM),
        .m_stat(m_stat),
        .m_valE(m_valE),
        .m_dstE(m_dstE),
        .m_dstM(m_dstM)
    );

    w_register w_register(
        .clk(clk), .W_stall(W_stall),
        .m_stat(m_stat), 
        .m_icode(m_icode),
        .m_valE(m_valE),
        .m_valM(m_valM),
        .m_dstE(m_dstE),
        .m_dstM(m_dstM),
        .W_stat(W_stat),
        .W_icode(W_icode),
        .W_valE(W_valE),
        .W_valM(W_valM),
        .W_dstE(W_dstE),
        .W_dstM(W_dstM)
    );

    always @(*) begin
        stat = W_stat;
        if(stat == 1 || stat == 2 || stat == 3) begin
            $finish;
        end
    end

    initial begin
        // $monitor("pc = %d, clk = %b, icode = %h, ifun = %h, valE = %d, valM = %d, valA = %d, valB = %d, valC = %d, valP = %d, status = %d", 
        // pc, clk, icode, ifun, valE,valM,valA,valB,valC,valP,status);
        // $monitor("pc = %d, rax = %d, status = %d", pc, register0, status);
        // $monitor("pc = %d, clk = %b, f_icode = %d, f_valC = %d, stat = %d,F_stall= %b, D_bubble = %b, D_stall = %b, W_dstE = %h", 
        // f_pc, clk, f_icode, f_valC, D_stat,F_stall, D_bubble, D_stall, W_dstE);
        // $monitor("clk = %b, pc = %d, W_icode = %h, W_valE = %d, W_stat = %d, r10 = %d, r11 = %d, r12 = %d, r13 = %d", 
        // clk, f_pc, W_icode, W_valE, W_stat, registers[10], registers[11], registers[12], registers[13]);


        // $monitor("clk = %b, stat = %d, f_pc = %d, f_icode = %h, f_ifun = %h, f_rA = %d, f_rB = %d, D_icode = %h, D_ifun = %h, D_rA = %d, D_rB = %d, D_valP = %d, d_icode = %h, d_ifun = %h, d_valA = %d, d_valB = %d, d_valC = %d, d_srcA = %d, d_srcB = %d, d_dstM = %d, d_dstE = %d, E_icode = %h, E_ifun = %h, E_valA = %d, E_valB = %d, E_valC = %d, E_srcA = %d, E_srcB = %d, E_dstM = %d, E_dstE = %d, reg[0] = %d, reg[1] = %d, reg[2] = %d, reg[3] = %d, reg[4] = %d, reg[6] = %d, reg[7] = %d", 
        // clk, stat, f_pc, f_icode, f_ifun, f_rA, f_rB, D_icode, D_ifun, D_rA, D_rB, D_valP, d_icode, d_ifun, d_valA, d_valB, d_valC, d_srcA, d_srcB, d_dstM, d_dstE, E_icode, E_ifun, E_valA, E_valB, E_valC, E_srcA, E_srcB, E_dstM, E_dstE, 
        // registers[0], registers[1], registers[2], registers[3], registers[4], registers[6], registers[7]);
    

    // $monitor("clk = %b, f_pc = %d, f_icode = %h, f_ifun = %h, f_rA = %d, f_rB = %d, d_valA = %d, d_valB = %d, d_valC = %d, , E_valA = %d, E_valB = %d, E_valC = %d, e_valE = %d , reg[0] = %d, reg[2] = %d, reg[4] = %d", 
    //     clk, f_pc, f_icode, f_ifun, f_rA, f_rB,d_valA, d_valB, d_valC,E_valA, E_valB, E_valC, e_valE,
    //     registers[0], registers[1], registers[2],registers[4]);
    

    //monitoring 1.txt 
    // $monitor("clk = %b, stat = %d, f_pc = %d, f_icode = %h, f_ifun = %h, f_rA = %d, f_rB = %d, d_valA = %d,\n d_valB = %d, d_valC = %d, reg[2] = %d, reg[3] = %d", 
    //     clk, stat, f_pc, f_icode, f_ifun, f_rA, f_rB,d_valA, d_valB, d_valC, 
    //     registers[2], registers[3]);

    //monitoring rmmovq and mrmovq 
        // $monitor("clk = %d, f_icode = %d, d_valA = %d, d_valB = %d,\n f_valC= %d, e_valE = %d, m_valM = %d",
        // clk, f_icode, d_valA, d_valB, f_valC, e_valE, m_valM);

    //for testing push and pop 
        // $monitor("clk = %d, icode = %d, valA = %d, valB = %d,\n valE = %d, valM = %d",
        // clk, f_icode, d_valA, d_valB, e_valE, m_valM);
    
    //testing call and return
     $monitor("clk = %d, f_icode = %d, d_valA = %d, d_valB = %d, f_valC = %d,\n e_valE = %d, m_valM = %d, status = %d", 
        clk, f_icode, d_valA, d_valB, f_valC, e_valE, m_valM, stat);
    end

endmodule