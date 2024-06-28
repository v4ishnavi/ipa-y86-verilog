`timescale 1ns / 1ps
`include "fetch.v"

module tb_fetch;

    reg clk;
    reg [63:0] pc;
    
    wire [3:0] icode;
    wire [3:0] ifun;
    wire [3:0] rA;
    wire [3:0] rB; 
    wire [63:0] valC;
    wire [63:0] valP;
    wire hlt, ins, imem_error;

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

    initial begin
        clk = 0;
        pc = 0;
    end

    initial begin
        forever begin
            clk = ~clk;
            pc = valP;
            #5;
            clk = ~clk;
            #5;
        end
    end
  
    initial 
		$monitor("clk=%d PC=%d icode=%h ifun=%h rA=%h rB=%h,valC=%d,valP=%d,hlt=%b,ins=%b,imem_error=%b\n",
        clk,pc,icode,ifun,rA,rB,valC,valP,hlt,ins,imem_error);

endmodule