`timescale 1ns / 1ps

module decode_wb(
    input clk,

    input [1:0] D_stat,
    input [3:0] D_icode,
    input [3:0] D_ifun,
    input [3:0] D_rA,
    input [3:0] D_rB,
    input [63:0] D_valC,
    input [63:0] D_valP, 
    
    input [3:0] e_dstE,
    input [63:0] e_valE,
    input [3:0] M_dstE,
    input [63:0] M_valE,
    input [3:0] M_dstM,
    input [63:0] m_valM,

    input [1:0] W_stat,
    input [3:0] W_icode,
    input [63:0] W_valE,
    input [63:0] W_valM,
    input [3:0] W_dstE,
    input [3:0] W_dstM,

    output reg [1:0] d_stat,
    output reg [3:0] d_icode,
    output reg [3:0] d_ifun,
    output reg [63:0] d_valC, 
    output reg [63:0] d_valA,
    output reg [63:0] d_valB,
    output reg [3:0] d_dstE,
    output reg [3:0] d_dstM,
    output reg [3:0] d_srcA,
    output reg [3:0] d_srcB,

    output reg [63:0] reg0,
    output reg [63:0] reg1,
    output reg [63:0] reg2,
    output reg [63:0] reg3,
    output reg [63:0] reg4,
    output reg [63:0] reg5,
    output reg [63:0] reg6,
    output reg [63:0] reg7,
    output reg [63:0] reg8,
    output reg [63:0] reg9,
    output reg [63:0] regA,
    output reg [63:0] regB,
    output reg [63:0] regC,
    output reg [63:0] regD,
    output reg [63:0] regE

);

    reg [63:0]r_valE;
    reg  [63:0]r_valM;
    wire [63:0]r_valA;
    wire  [63:0]r_valB;
    reg [63:0] registers[0:14];

    //decode
    // always @(negedge clk) begin
    always @(*) begin
        d_stat = D_stat;
        d_icode = D_icode;
        d_ifun = D_ifun;
        d_valC = D_valC;

        
        case (d_icode)

            4'h0: begin //halt
                d_srcA = 4'hF;
                d_srcB = 4'hF;
                d_dstE = 4'hF;
                d_dstM = 4'hF;
            end

            4'h1:begin //nop
                d_srcA = 4'hF;
                d_srcB = 4'hF;
                d_dstE = 4'hF;
                d_dstM = 4'hF;
            end

            4'h2: begin //cmovxx
                d_srcA = D_rA;
                d_srcB = D_rB;
                d_dstE = D_rB;
                d_dstM = 4'hF;
            end

            4'h3: begin //irmovq
                d_srcA = 4'hF;
                d_srcB = D_rB;
                d_dstE = D_rB;
                d_dstM = 4'hF;
            end

            4'h4: begin //rmmovq
                d_srcA = D_rA;
                d_srcB = D_rB;
                d_dstE = 4'hF;
                d_dstM = 4'hF;
            end

            4'h5: begin //mrmovq
                d_srcA = 4'hF;
                d_srcB = D_rB;
                d_dstE = 4'hF;
                d_dstM = D_rA;
            end

            4'h6: begin //OPq
                d_srcA = D_rA;
                d_srcB = D_rB;
                d_dstE = D_rB;
                d_dstM = 4'hF;
            end

            4'h7: begin //JXX
                d_srcA = 4'hF;
                d_srcB = 4'hF;
                d_dstE = 4'hF;
                d_dstM = 4'hF;
            end

            4'h8: begin //call
                d_srcA = 4'hF;
                d_srcB = 4;
                d_dstE = 4;
                d_dstM = 4'hF;
            end

            4'h9: begin //ret
                d_srcA = 4;
                d_srcB = 4;
                d_dstE = 4;
                d_dstM = 4'hF;
            end

            4'hA: begin //push
                d_srcA = D_rA;
                d_srcB = 4;
                d_dstE = 4;
                d_dstM = 4'hF;
            end

            4'hB: begin //pop
                d_srcA = 4;
                d_srcB = 4;
                d_dstE = 4;
                d_dstM = D_rA;
            end

        endcase

        d_valA = (d_srcA == 15? 0: registers[d_srcA]);
        d_valB = (d_srcB == 15? 0: registers[d_srcB]);

        if(D_icode == 4'h8 || D_icode == 4'h7) d_valA = D_valP;
        
        if(d_srcA != 4'hF) begin
            
            if(e_dstE == d_srcA) d_valA = e_valE;
            else if(M_dstM == d_srcA) d_valA = m_valM;
            else if(M_dstE == d_srcA) d_valA = M_valE;
            else if(W_dstE == d_srcA) d_valA = W_valE;
            else if(W_dstM == d_srcA) d_valA = W_valM;
        end

        if(d_srcB != 4'hF) begin
            // if(D_icode == 4'h8 || D_icode == 4'h7) d_valA = D_valP;
            if(e_dstE == d_srcB) d_valB = e_valE;
            else if(M_dstM == d_srcB) d_valB = m_valM;
            else if(M_dstE == d_srcB) d_valB = M_valE;
            else if(W_dstE == d_srcB) d_valB = W_valE;
            else if(W_dstM == d_srcB) d_valB = W_valM;
        end

    end

    //writeback
    always @(posedge clk) begin
        if(W_stat == 0) begin
            if(W_dstE != 15) registers[W_dstE] = W_valE;
            if(W_dstM != 15) registers[W_dstM] = W_valM;
        end
    end

    always @(*) begin
        reg0 = registers[0];
        reg1 = registers[1];
        reg2 = registers[2];
        reg3 = registers[3];
        reg4 = registers[4];
        reg5 = registers[5];
        reg6 = registers[6];
        reg7 = registers[7];
        reg8 = registers[8];
        reg9 = registers[9];
        regA = registers[10];
        regB = registers[11];
        regC = registers[12];
        regD = registers[13];
        regE = registers[14];
    end

endmodule