`timescale 1ns / 1ps

module e_register(
input E_bubble,
input clk,
input [1:0] d_stat,
input[3:0] d_icode,
input [3:0] d_ifun,
input[63:0] d_valC,
input[63:0] d_valB,
input[63:0] d_valA,
input[3:0] d_dstE,
input[3:0] d_dstM,

//NOT REQUIRED IN NEXTSTAGES, but still for structure
input[3:0] d_srcA, 
input[3:0] d_srcB,

output reg [1:0] E_stat,
output reg [3:0] E_icode,
output reg [3:0] E_ifun,
output reg [63:0] E_valC,
output reg [63:0] E_valB,
output reg [63:0] E_valA,
output reg [3:0] E_dstE, 
output reg [3:0] E_dstM,

//NOT REQUIRED FOR NEXT STAGES, but according to textbook.
output reg [3:0] E_srcA,
output reg [3:0] E_srcB
);

always @ (posedge clk) begin
    
    if(!E_bubble)begin
        E_stat <= d_stat;
        E_valC <= d_valC;
        E_valB <= d_valB;
        E_valA <= d_valA;
        E_icode <= d_icode;
        E_ifun <= d_ifun;
        E_dstE <= d_dstE;
        E_dstM <= d_dstM;
        E_srcA <= d_srcA;
        E_srcB <= d_srcB;
    end

    else begin
        E_stat <= 0;
        E_valC <= 0;
        E_valB <= 0;
        E_valA <= 0;
        E_icode <= 4'h1;
        E_dstE <= 4'hF;
        E_dstM <= 4'hF;
        E_srcA <= 4'hF;
        E_srcB <= 4'hF;
    end

end

endmodule