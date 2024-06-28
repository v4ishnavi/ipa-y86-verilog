`timescale 1ns / 1ps

module d_register (
    
    input clk, D_bubble, D_stall,
    input [1:0] f_stat,
    input [3:0] f_icode,
    input [3:0] f_ifun, 
    input [3:0] f_rA,
    input [3:0] f_rB,
    input [63:0] f_valC,
    input [63:0] f_valP,

    output reg [1:0] D_stat,
    output reg [3:0] D_icode,
    output reg [3:0] D_ifun, 
    output reg [3:0] D_rA,
    output reg [3:0] D_rB,
    output reg [63:0] D_valC,
    output reg [63:0] D_valP

);

    always @(posedge clk ) begin
        
        if(D_stall == 1) begin
            
        end

        else if(D_bubble == 1) begin
            D_stat <= 0;
            D_icode <= 4'h1;
            D_ifun <= 4'h0;
            D_rA <= 4'hF;
            D_rB <= 4'hF;
            D_valC <= 0;
            D_valP <= 0;
            // $display("D is bubbled. ");
        end

        else if(f_stat != 0) begin
            D_stat <= f_stat;
            D_icode <= 4'h0;
            D_ifun <= 4'h0;
            D_rA <= 4'hF;
            D_rB <= 4'hF;
            D_valC <= 0;
            D_valP <= 0;
            // $display("F is stalled. Halt Condition reached. ");
        end

        else begin
            D_stat <= f_stat;
            D_icode <= f_icode;
            D_ifun <= f_ifun;
            D_rA <= f_rA;
            D_rB <= f_rB;
            D_valC <= f_valC;
            D_valP <= f_valP;
            // $display("Regular Decode. ");
        end

    end

    
endmodule
