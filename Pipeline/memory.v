`timescale 1ns / 1ps

module memory #(
    parameter mem_size = 512,  // Memory size remains the same
    parameter reg_size = 8     // Changed to 8 bits for byte-addressable memory
) (
    input clk,
    input [1:0] M_stat,
    input wire [3:0] M_icode,
    input wire [63:0] M_valA,
    input wire [63:0] M_valE,
    // input wire [63:0] valP, part of M_valA 
    input [3:0] M_dstE,
    input [3:0] M_dstM,

    output reg [3:0] m_icode,
    output reg [63:0] m_valM,
    output reg [1:0] m_stat,
    output reg [63:0] m_valE,
    output reg [3:0] m_dstE,
    output reg [3:0] m_dstM
);
    // Memory block now stores 8-bit values
    reg error;
    reg [reg_size-1:0] memory_block [0:mem_size-1];  // Adjusted for byte-addressability

    initial begin
        error = 0;
        m_valM = 0; 
    end

    always @(*) begin
        error = 0;
        // M_stat = 0; 
        case(M_icode)
            4'h5: begin // mrmovq, read
                if ((M_valE) < mem_size) begin
                    m_valM = {memory_block[(M_valE)+7],
                            memory_block[(M_valE)+6], 
                            memory_block[(M_valE)+5],
                            memory_block[(M_valE)+4], 
                            memory_block[(M_valE)+3], 
                            memory_block[(M_valE)+2], 
                            memory_block[(M_valE)+1], 
                            memory_block[M_valE]};
                end else begin
                    error = 1;
                    m_stat = 2; 
                end
            end

            4'h9, 4'hB: begin // ret and popq, read
                if ((M_valA) < mem_size) begin
                    m_valM = {memory_block[(M_valA)+7],
                            memory_block[(M_valA)+6], 
                            memory_block[(M_valA)+5], 
                            memory_block[(M_valA)+4], 
                            memory_block[(M_valA)+3], 
                            memory_block[(M_valA)+2], 
                            memory_block[(M_valA)+1], 
                            memory_block[M_valA]};
                end else begin
                    error = 1;
                    m_stat = 2; 
                end
            end
        endcase
    end

    always @(posedge clk) begin
        case (M_icode)
            4'h4, 4'hA: begin // rmmovq and pushq, write
                if ((M_valE) < mem_size) begin
                    {memory_block[(M_valE)+7],
                    memory_block[(M_valE)+6], 
                    memory_block[(M_valE)+5], 
                    memory_block[(M_valE)+4], 
                    memory_block[(M_valE)+3], 
                    memory_block[(M_valE)+2], 
                    memory_block[(M_valE)+1], 
                    memory_block[M_valE]} = M_valA;
                end else begin
                    error = 1;
                    m_stat = 2; 
                end
            end

            4'h8: begin // call, write
                if ((M_valE) < mem_size) begin
                    {memory_block[(M_valE)+7], 
                    memory_block[(M_valE)+6], 
                    memory_block[(M_valE)+5], 
                    memory_block[(M_valE)+4], 
                    memory_block[(M_valE)+3], 
                    memory_block[(M_valE)+2], 
                    memory_block[(M_valE)+1], 
                    memory_block[M_valE]} = M_valA;
                end else begin
                    error = 1;
                    m_stat = 2; 
                end
            end
        endcase
    end

    always @(*) begin
        if(!error) begin
        m_stat = M_stat; end
        m_icode = M_icode;
        m_valE = M_valE;
        m_dstE = M_dstE;
        m_dstM = M_dstM;
    end

endmodule