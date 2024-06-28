`timescale 1ns / 1ps

module fetch #(
    parameter size = 512 //no of bytes instruction memory can store
)(
    output reg[3:0] icode,
    output reg[3:0] ifun,
    output reg[3:0] rA,
    output reg[3:0] rB,
    output reg[63:0] valC,
    output reg[63:0] valP,
    output reg hlt,
    output reg invalid_instruction,
    output reg invalid_instruction_address,
    input clk,
    input [63:0] pc
);

    reg [7:0] instruction_memory[0:size-1];
    integer  k;
    initial begin
        $readmemb("../SampleTestcase/call_ret.txt", instruction_memory);
        // for (k = 0; k < 210; k = k + 1) begin
        //     $display("%d:%b", k, instruction_memory[k]);
        // end
        icode = 0;
        ifun = 0;
        rA = 0;
        rB = 0;
        valC = 0;
        valP = 0;
        invalid_instruction_address = 0;
        invalid_instruction = 0;
        hlt = 0;
    end

    always @(posedge clk) begin
        
        if(pc >= size) begin
            invalid_instruction_address = 1;
            $finish;
        end

        icode = instruction_memory[pc][7:4];
        ifun = instruction_memory[pc][3:0];

        if(icode > 4'hB) begin 
            invalid_instruction = 1;
            $finish;
        end

        case(icode)

            4'h0: begin
                //halt
                if(ifun > 4'h0) invalid_instruction = 1;
                else hlt = 1;
                $finish;
            end

            4'h1: begin
                //nop
                if(ifun > 4'h0) begin
                    invalid_instruction = 1;
                    $finish;
                end
                valP = pc + 1;
            end

            4'h2: begin
                //cmovxx
                if(ifun > 4'h6) invalid_instruction = 1;
                else if(pc + 1 >= size) invalid_instruction_address = 1;
                if(invalid_instruction | invalid_instruction_address) $finish;
                rA = instruction_memory[pc + 1][7:4];
                rB = instruction_memory[pc + 1][3:0];
                if(rA == 4'hF || rB == 4'hF) begin
                    invalid_instruction = 1;
                    rA = 0;
                    rB = 0;
                    $finish;
                end
                valP = pc + 2;

            end

            4'h3: begin
                //irmovq
                if(ifun > 0 | (pc + 1 < size & instruction_memory[pc + 1][7:4] < 4'hF)) invalid_instruction = 1;
                else if(pc + 9 >= size) invalid_instruction_address = 1;     
                if(invalid_instruction | invalid_instruction_address) $finish;
                
                rA = 4'hF;
                rB = instruction_memory[pc + 1][3:0];
                if(rB == 4'hF) begin
                    invalid_instruction = 1;
                    rB = 0;
                    $finish;
                end
                valC = {
                    instruction_memory[pc + 9],
                    instruction_memory[pc + 8],
                    instruction_memory[pc + 7],
                    instruction_memory[pc + 6],
                    instruction_memory[pc + 5],
                    instruction_memory[pc + 4],
                    instruction_memory[pc + 3],
                    instruction_memory[pc + 2]
                };
                valP = pc + 10;

            end

            4'h4: begin

                //rmmovq
                if(ifun > 4'h0) invalid_instruction = 1;
                else if(pc + 9 >= size) invalid_instruction_address = 1; 
                if(invalid_instruction | invalid_instruction_address) $finish;
              
                
                rA = instruction_memory[pc + 1][7:4];
                rB = instruction_memory[pc + 1][3:0];

                if(rA == 4'hF || rB == 4'hF) begin
                    invalid_instruction = 1;
                    rA = 0;
                    rB = 0;
                    $finish;
                end
                valC = {
                    instruction_memory[pc + 9],
                    instruction_memory[pc + 8],
                    instruction_memory[pc + 7],
                    instruction_memory[pc + 6],
                    instruction_memory[pc + 5],
                    instruction_memory[pc + 4],
                    instruction_memory[pc + 3],
                    instruction_memory[pc + 2]
                };
                valP = pc + 10;
                
            end

            4'h5: begin

                //mrmovq
                if(ifun > 4'h0) invalid_instruction = 1;
                else if(pc + 9 >= size) invalid_instruction_address = 1;
                if(invalid_instruction | invalid_instruction_address) $finish;         
                
                rA = instruction_memory[pc + 1][7:4];
                rB = instruction_memory[pc + 1][3:0];
                if(rA == 4'hF || rB == 4'hF) begin
                    invalid_instruction = 1;
                    rA = 0;
                    rB = 0;
                    $finish;
                end
                valC = {
                    instruction_memory[pc + 9],
                    instruction_memory[pc + 8],
                    instruction_memory[pc + 7],
                    instruction_memory[pc + 6],
                    instruction_memory[pc + 5],
                    instruction_memory[pc + 4],
                    instruction_memory[pc + 3],
                    instruction_memory[pc + 2]
                };
                valP = pc + 10;
                
            end

            4'h6: begin

                //OPq
                if(ifun > 4'h3) invalid_instruction = 1;
                else if(pc + 1 >= size) invalid_instruction_address = 1;
                if(invalid_instruction | invalid_instruction_address) $finish;

                rA = instruction_memory[pc + 1][7:4];
                rB = instruction_memory[pc + 1][3:0];
                if(rA == 4'hF || rB == 4'hF) begin
                    invalid_instruction = 1;
                    rA = 0;
                    rB = 0;
                    $finish;
                end
                valP = pc + 2;
                
            end

            4'h7: begin

                //jxx
                if(ifun > 4'h6) invalid_instruction = 1;
                else if(pc + 8 >= size) invalid_instruction_address = 1;
                if(invalid_instruction | invalid_instruction_address) $finish;

                valC = {
                    instruction_memory[pc + 8],
                    instruction_memory[pc + 7],
                    instruction_memory[pc + 6],
                    instruction_memory[pc + 5],
                    instruction_memory[pc + 4],
                    instruction_memory[pc + 3],
                    instruction_memory[pc + 2],
                    instruction_memory[pc + 1]
                };
                valP = pc + 9;
                
            end

            4'h8: begin

                //call
                if(ifun > 4'h0) invalid_instruction = 1;
                else if(pc + 8 >= size) invalid_instruction_address = 1;
                if(invalid_instruction | invalid_instruction_address) $finish;

                valC = {
                    instruction_memory[pc + 8],
                    instruction_memory[pc + 7],
                    instruction_memory[pc + 6],
                    instruction_memory[pc + 5],
                    instruction_memory[pc + 4],
                    instruction_memory[pc + 3],
                    instruction_memory[pc + 2],
                    instruction_memory[pc + 1]
                };
                valP = pc + 9;
                
            end

            4'h9: begin
                //ret
                if(ifun > 4'h0) begin
                    invalid_instruction = 1;
                    $finish;
                end                
            end

            4'hA: begin
                //pushq         
                if(ifun > 4'h0 | (pc + 1 < size & instruction_memory[pc + 1][3:0] < 4'hF)) invalid_instruction = 1;
                else if(pc + 1 >= size) invalid_instruction_address = 1;
                if(invalid_instruction | invalid_instruction_address) $finish;
                
                rA = instruction_memory[pc + 1][7:4];
                rB = instruction_memory[pc + 1][3:0];
                if(rA == 4'hF) begin
                    invalid_instruction = 1;
                    rA = 0;
                    $finish;
                end
                valP = pc + 2;
            end

            4'hB: begin
                //popq 
                if(ifun > 4'h0 | (pc + 1 < size & instruction_memory[pc + 1][3:0] < 4'hF)) invalid_instruction = 1;
                else if(pc + 1 >= size) invalid_instruction_address = 1;
                if(invalid_instruction | invalid_instruction_address) $finish;
                
                rA = instruction_memory[pc + 1][7:4];
                rB = instruction_memory[pc + 1][3:0];
                if(rA == 4'hF) begin
                    invalid_instruction = 1;
                    rA = 0;
                    $finish;
                end
                valP = pc + 2;
            end

            default:begin
                invalid_instruction = 1;
                $finish;
            end

        endcase

    end
    
endmodule