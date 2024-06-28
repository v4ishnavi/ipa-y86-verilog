`timescale 1ns / 1ps

`include "fetch.v"
`include "execute.v"
`include "memory.v"
`include "pc_update.v"
`include "register_file.v"

module SEQ_processor;
    
    reg clk;
    reg [63:0] pc;
    reg [1:0] status; 
    /*
    status[0] = AOK
    status[1] = HLT
    status[2] = ADS
    status[3] = INS
    */

    wire [3:0] icode;
    wire [3:0] ifun;
    wire [3:0] rA;
    wire [3:0] rB; 
    wire [63:0] valC;
    wire [63:0] valP;
    wire invalid_instruction;
    wire invalid_instruction_address;
    wire [63:0] valA;
    wire [63:0] valB;
    wire [63:0] valE;
    wire [63:0] valM;
    wire cnd;
    wire hlt;
    wire [63:0] new_pc;

    wire [63:0] register0;
    wire [63:0] register1;
    wire [63:0] register2;
    wire [63:0] register3;
    wire [63:0] register4;
    wire [63:0] register5;
    wire [63:0] register6;
    wire [63:0] register7;
    wire [63:0] register8;
    wire [63:0] register9;
    wire [63:0] registerA;
    wire [63:0] registerB;
    wire [63:0] registerC;
    wire [63:0] registerD;
    wire [63:0] registerE;
    wire invalid_data_address;

    wire sign_flag;
    wire zero_flag;
    wire overflow_flag;

    fetch fetch(
        .icode(icode),
        .ifun(ifun),
        .rA(rA),
        .rB(rB),
        .valC(valC),
        .valP(valP),
        .hlt(hlt),
        .invalid_instruction(invalid_instruction),
        .invalid_instruction_address(invalid_instruction_address),
        .clk(clk),
        .pc(pc)
    );

    execute execute(
        .valE(valE),
        .cnd(cnd), .zero_flag(zero_flag), .overflow_flag(overflow_flag), .sign_flag(sign_flag),
        .clk(clk),
        .icode(icode), .ifun(ifun),
        .valA(valA), .valB(valB), .valC(valC)
    );

    register_file register_file(
        .valA(valA),
        .valB(valB),
        .reg0(register0),
        .reg1(register1),
        .reg2(register2),
        .reg3(register3),
        .reg4(register4),
        .reg5(register5),
        .reg6(register6),
        .reg7(register7),
        .reg8(register8),
        .reg9(register9),
        .regA(registerA),
        .regB(registerB),
        .regC(registerC),
        .regD(registerD),
        .regE(registerE),
        .clk(clk),
        .icode(icode),
        .rA(rA),
        .rB(rB),
        .cnd(cnd),
        .valE(valE),
        .valM(valM)
    );

    memory memory(
        .clk(clk),
        .icode(icode),
        .valA(valA),
        .valE(valE),
        .valP(valP),
        .valM(valM),
        .error(invalid_data_address)
    );

    pc_update pc_update(
        .new_pc(new_pc),
        .icode(icode),
        .valC(valC),
        .valP(valP),
        .valM(valM),
        .cnd(cnd),
        .clk(clk)
    );

    initial begin
        $dumpfile("seq.vcd");
        $dumpvars(0,SEQ_processor);
        status = 0;
        clk = 0;
        pc = 0;
        forever begin
            #10; clk = ~clk;
        end
    end

    always @(*) begin
        // if(clk)
            pc = new_pc;
    end

    always @(*) begin
        if(status != 0)
            $finish;
    end

    always @(*) begin
        if(hlt)
            status = 1; //hlt
        else if(invalid_data_address | invalid_instruction_address)
            status = 2; //ads
        else if(invalid_instruction)
            status = 3; //ins
    end

    initial begin
        // $monitor("pc = %d, clk = %b, icode = %h, ifun = %h, valE = %d, valM = %d, valA = %d, valB = %d, valC = %d, valP = %d, status = %d", 
        // pc, clk, icode, ifun, valE,valM,valA,valB,valC,valP,status);
        // $monitor("pc = %d, rax = %d, status = %d", pc, register0, status);

        //for monitoring decode stage: 
        // $monitor("clk = %d, pc = %d, icode = %d ,valA = %d, valB = %d", clk, pc, icode, valA, valB);

        //for monitoring execute stage: 
        // $monitor("clk=%d icode=%h ifun=%h valA=%d valB=%d valC=%d valE=%d \n zf=%b of=%b sf=%b cnd=%b \n",
        // clk,icode,ifun,valA,valB,valC,valE, zero_flag, overflow_flag, sign_flag, cnd);

        //for monitoring memory stage: 
        // $monitor("icode=%h, valA=%d, valE=%d, valP=%d, valM=%d, error=%b",
        //           icode, valA, valE, valP, valM, invalid_data_address);

        //monitoring write back stage: 
        // $monitor("clk = %d, icode = %d, rbx = %d, rdx = %d, valE = %d, valM = %d",
        // clk, icode, register3, register2, valE, valM);

        //monitoring pc update
        // $monitor("clk = %d, icode=%d, cnd=%d, valC=%d, valP=%d, valM=%d -> pc=%d",
        //           clk, icode, cnd, valC, valP, valM, pc);

        //for rmmovq and mrmorq
        // $monitor("clk = %d, icode = %d, valA = %d, valB = %d,\n valC= %d, valE = %d, valM = %d\n",
        // clk, icode, valA, valB, valC, valE, valM);

        //for testing push and pop 
        // $monitor("clk = %d, icode = %d, valA = %d, valB = %d,\n valE = %d, valM = %d\n",
        // clk, icode, valA, valB, valE, valM);

        //for multiplying 10 and 19: 
        // $monitor("icode = %d, reg10 = %d, reg11 = %d, reg12= %d, reg13= %d, valE= %d, status = %d",
        //         icode, registerA, registerB, registerC, registerD, valE, status);

        //for testing call and return
        $monitor("icode = %d, valA = %d, valB = %d, valC = %d, valE = %d, \n valM = %d", 
        icode, valA, valB, valC, valE, valM);
    end
    
endmodule