`timescale 1ns / 1ps

module m_register(
    input clk,
    input M_bubble,
    input [1:0] e_stat,
    input [3:0] e_icode,
    input  e_cnd,
    input [63:0] e_valE,
    input [63:0] e_valA,
    input [3:0] e_dstE,
    input [3:0] e_dstM,

    output reg [1:0] M_stat,
    output reg [3:0] M_icode,
    output reg M_cnd, 
    output reg[63:0] M_valE,
    output reg[63:0] M_valA,
    output reg[3:0] M_dstE, 
    output reg[3:0] M_dstM
);

always @(posedge clk) begin
    
    if(!M_bubble) begin
        M_stat <= e_stat;
        M_cnd <= e_cnd;
        M_valE <= e_valE;
        M_valA <= e_valA;
        M_icode <= e_icode;
        M_dstE <= e_dstE;
        M_dstM <= e_dstM;
    end
    
    else begin
        M_stat <= 0;
        M_cnd <= 0;
        M_valE <= 0;
        M_valA <= 0;
        M_icode <= 4'h1;
        M_dstE <= 4'hF;
        M_dstM <= 4'hF;
    end
end


endmodule