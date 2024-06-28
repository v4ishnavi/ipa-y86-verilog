`timescale 1ns / 1ps
`include "fetch.v"
`include "decode.v"
`include "execute.v"

module tb_execute;
    
    reg clk;
    reg [63:0] pc;
    reg [63:0] registers[0:14];
    wire [3:0] icode;
    wire [3:0] ifun;
    wire [3:0] rA;
    wire [3:0] rB; 
    wire [63:0] valC;
    wire [63:0] valP;
    wire [63:0] valA;
    wire [63:0] valB;
    wire [63:0] valE;
    wire hlt, ins, imem_error;
    wire cnd, zero_flag, sign_flag, overflow_flag;

    integer i;
    initial begin
        clk = 0;
        pc = 0;
        for (i = 0; i < 15; i = i + 1 ) begin
            registers[i] = i;
        end
    end

    
    fetch fetch(
        .icode(icode),
        .ifun(ifun),
        .rA(rA),
        .rB(rB),
        .valC(valC),
        .valP(valP),
        .hlt(hlt),
        .invalid_instruction(ins),
        .invalid_instruction_address(imem_error),
        .clk(clk),
        .pc(pc)
    );

    decode decode(
        .valA(valA),
        .valB(valB),
        .clk(clk),
        .icode(icode),
        .rA(rA),
        .rB(rB),
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

    execute execute(
        .valE(valE),
        .cnd(cnd), .zero_flag(zero_flag), .overflow_flag(overflow_flag), .sign_flag(sign_flag),
        .clk(clk),
        .icode(icode), .ifun(ifun),
        .valA(valA), .valB(valB), .valC(valC)
    );

    initial begin
        forever begin
            #10;clk = ~clk;
            pc = valP;
            #10;
            clk = ~clk;
        end
    end

    initial begin
        $monitor("time=%d clk=%d icode=%h ifun=%h rA=%h rB=%h valA=%d valB=%d valC=%d valE=%d\nzf=%b of=%b sf=%b cnd=%b",
        $time, clk,icode,ifun,rA,rB,valA,valB,valC,valE, zero_flag, overflow_flag, sign_flag, cnd);
    end

endmodule