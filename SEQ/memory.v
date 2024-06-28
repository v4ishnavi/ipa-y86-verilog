`timescale 1ns / 1ps

module memory #(
    parameter mem_size = 512,  // Memory size remains the same
    parameter reg_size = 8     // Changed to 8 bits for byte-addressable memory
) (
    input clk,
    input wire [3:0] icode,
    input wire [63:0] valA,
    input wire [63:0] valE,
    input wire [63:0] valP,
    output reg [63:0] valM,
    output reg error
);

    // Memory block now stores 8-bit values
    reg [reg_size-1:0] memory_block [0:mem_size-1];  // Adjusted for byte-addressability

    initial begin
        error = 0;
        valM = 0; 
    end

    always @(*) begin
        error = 0;
        case(icode)
            4'h5: begin // mrmovq, read
                if ((valE) < mem_size) begin
                    valM = {memory_block[(valE)+7],
                            memory_block[(valE)+6], 
                            memory_block[(valE)+5],
                            memory_block[(valE)+4], 
                            memory_block[(valE)+3], 
                            memory_block[(valE)+2], 
                            memory_block[(valE)+1], 
                            memory_block[valE]};
                end else begin
                    error = 1;
                end
            end

            4'h9, 4'hB: begin // ret and popq, read
                if ((valA) < mem_size) begin
                    valM = {memory_block[(valA)+7],
                            memory_block[(valA)+6], 
                            memory_block[(valA)+5], 
                            memory_block[(valA)+4], 
                            memory_block[(valA)+3], 
                            memory_block[(valA)+2], 
                            memory_block[(valA)+1], 
                            memory_block[valA]};
                end else begin
                    error = 1;
                end
            end
        endcase
    end

    always @(negedge clk) begin
        case (icode)
            4'h4, 4'hA: begin // rmmovq and pushq, write
                if ((valE) < mem_size) begin
                    {memory_block[(valE)+7],
                    memory_block[(valE)+6], 
                    memory_block[(valE)+5], 
                    memory_block[(valE)+4], 
                    memory_block[(valE)+3], 
                    memory_block[(valE)+2], 
                    memory_block[(valE)+1], 
                    memory_block[valE]} = valA;
                end else begin
                    error = 1;
                end
            end

            4'h8: begin // call, write
                if ((valE) < mem_size) begin
                    {memory_block[(valE)+7], 
                    memory_block[(valE)+6], 
                    memory_block[(valE)+5], 
                    memory_block[(valE)+4], 
                    memory_block[(valE)+3], 
                    memory_block[(valE)+2], 
                    memory_block[(valE)+1], 
                    memory_block[valE]} = valP;
                end else begin
                    error = 1;
                end
            end
        endcase
    end

endmodule
