`timescale 1ns / 1ps

module pc_update(
    output reg [63:0] f_pc,
    input[3:0] M_icode,
    input[3:0] W_icode,
    input[63:0] M_valA,
    input[63:0] W_valM,
    input[63:0] F_pc_prelim,
    input M_cnd,
    input clk
);
initial begin
    f_pc = 0;
end
always @(*)begin 
    if(M_icode == 4'h7 && !M_cnd)begin
        f_pc = M_valA;
    end
    else if(W_icode == 4'h9) f_pc = W_valM;
    else f_pc = F_pc_prelim;
end

endmodule


module fetch #(
    parameter size = 512 //no of bytes instruction memory can store
)(
    output reg[3:0] f_icode,
    output reg[3:0] f_ifun,
    output reg[3:0] f_rA,
    output reg[3:0] f_rB,
    output reg[63:0] f_valC,
    output reg[63:0] f_valP,
    // output reg hlt,
    // output reg invalid_instruction,
    // output reg invalid_instruction_address,
    input clk,
    input [63:0] f_pc,
    output reg[63:0] f_predPC,
    output reg [1:0] f_stat
);

    reg [7:0] instruction_memory[0:size-1];
    integer  k;
    initial begin
        $readmemb("../SampleTestcase/call_ret.txt", instruction_memory);
        // for (k = 0; k < 210; k = k + 1) begin
        //     $display("%d:%b", k, instruction_memory[k]);
        // end
        f_icode = 0;
        f_ifun = 0;
        f_rA = 0;
        f_rB = 0;
        f_valC = 0;
        f_valP = 0;
        // invalid_instruction_address = 0;
        // invalid_instruction = 0;
        // hlt = 0;
        f_stat = 0; 
        f_predPC = 0;
    end

    always @(negedge clk) begin
        
        if(f_pc >= size) begin
            // invalid_instruction_address = 1
            f_stat = 2; 
            // $finish;
        end

        f_icode = instruction_memory[f_pc][7:4];
        f_ifun = instruction_memory[f_pc][3:0];

        if(f_icode > 4'hB) begin 
            // invalid_instruction = 1;
            f_stat = 3; 
            // $finish;
        end

        case(f_icode)

            4'h0: begin
                //halt
                if(f_ifun > 4'h0) begin 
                    // invalid_instruction = 1;
                    f_stat = 3; 
                end 
                else begin 
                f_stat = 1;
                end
                // $finish;
            end

            4'h1: begin
                //nop
                if(f_ifun > 4'h0) begin
                    // invalid_instruction = 1;
                    f_stat = 3; 
                    // $finish;
                end
                else f_valP = f_pc + 1;
            end

            4'h2: begin
                //cmovxx
                if(f_ifun > 4'h6) begin 
                    // invalid_instruction = 1;
                f_stat = 3; 
                 end
                else if(f_pc + 1 >= size) begin 
                    // invalid_instruction_address = 1; 
                f_stat = 2; 
                end
                else begin
                // if(invalid_instruction | invalid_instruction_address) $finish;
                f_rA = instruction_memory[f_pc + 1][7:4];
                f_rB = instruction_memory[f_pc + 1][3:0];
                if(f_rA == 4'hF || f_rB == 4'hF) begin
                    // invalid_instruction = 1;
                    f_stat = 3; 
                    f_rA = 0;
                    f_rB = 0;
                    // $finish;
                end
                f_valP = f_pc + 2;
                end

            end

            4'h3: begin
                //irmovq
                if(f_ifun > 0 | (f_pc + 1 < size & instruction_memory[f_pc + 1][7:4] < 4'hF)) begin 
                // invalid_instruction = 1;
                f_stat = 3;  end
                else if(f_pc + 9 >= size) begin 
                // invalid_instruction_address = 1;
                f_stat = 2; 
                end  
                // if(invalid_instruction | invalid_instruction_address) $finish;
                else begin
                f_valC = {
                    instruction_memory[f_pc + 9],
                    instruction_memory[f_pc + 8],
                    instruction_memory[f_pc + 7],
                    instruction_memory[f_pc + 6],
                    instruction_memory[f_pc + 5],
                    instruction_memory[f_pc + 4],
                    instruction_memory[f_pc + 3],
                    instruction_memory[f_pc + 2]
                };
                f_rA = 4'hF;
                f_rB = instruction_memory[f_pc + 1][3:0];

                if(f_rB == 4'hF) begin
                    // invalid_instruction = 1;
                    f_rB = 0;
                    f_stat = 3; 
                    // $finish;
                end

                f_valP = f_pc + 10;
                end


            end

            4'h4: begin

                //rmmovq
                if(f_ifun > 4'h0) begin 
                    // invalid_instruction = 1; 
                    f_stat = 3;  
                    end 
                else if(f_pc + 9 >= size) begin 
                    // invalid_instruction_address = 1; 
                    f_stat = 2;  end
                // if(invalid_instruction | invalid_instruction_address) $finish;
                else begin
                f_rA = instruction_memory[f_pc + 1][7:4];
                f_rB = instruction_memory[f_pc + 1][3:0];

                if(f_rA == 4'hF || f_rB == 4'hF) begin
                    // invalid_instruction = 1;
                    f_stat = 3; 
                    f_rA = 0;
                    f_rB = 0;
                    // $finish;
                end
                f_valC = {
                    instruction_memory[f_pc + 9],
                    instruction_memory[f_pc + 8],
                    instruction_memory[f_pc + 7],
                    instruction_memory[f_pc + 6],
                    instruction_memory[f_pc + 5],
                    instruction_memory[f_pc + 4],
                    instruction_memory[f_pc + 3],
                    instruction_memory[f_pc + 2]
                };
                f_valP = f_pc + 10;
                end
                
            end

            4'h5: begin

                //mrmovq
                if(f_ifun > 4'h0) begin 
                    // invalid_instruction = 1; 
                    f_stat = 3; end 
                else if(f_pc + 9 >= size) begin 
                    // invalid_instruction_address = 1; 
                    f_stat = 2;  end
                // if(invalid_instruction | invalid_instruction_address) $finish;         
                else begin 
                f_rA = instruction_memory[f_pc + 1][7:4];
                f_rB = instruction_memory[f_pc + 1][3:0];
                if(f_rA == 4'hF || f_rB == 4'hF) begin
                    // invalid_instruction = 1;
                    f_stat = 3; 
                    f_rA = 0;
                    f_rB = 0;
                    // $finish;
                end
                f_valC = {
                    instruction_memory[f_pc + 9],
                    instruction_memory[f_pc + 8],
                    instruction_memory[f_pc + 7],
                    instruction_memory[f_pc + 6],
                    instruction_memory[f_pc + 5],
                    instruction_memory[f_pc + 4],
                    instruction_memory[f_pc + 3],
                    instruction_memory[f_pc + 2]
                };
                f_valP = f_pc + 10; 
                end
                
            end

            4'h6: begin

                //OPq
                if(f_ifun > 4'h3) begin 
                    // invalid_instruction = 1; 
                    f_stat = 3; 
                    end 
                else if(f_pc + 1 >= size) begin 
                    // invalid_instruction_address = 1; 
                    f_stat = 2; end 
                // if(invalid_instruction | invalid_instruction_address) $finish;
                else begin
                f_rA = instruction_memory[f_pc + 1][7:4];
                f_rB = instruction_memory[f_pc + 1][3:0];
                if(f_rA == 4'hF || f_rB == 4'hF) begin
                    // invalid_instruction = 1;
                    f_stat = 3; 
                    f_rA = 0;
                    f_rB = 0;
                    // $finish;
                end
                f_valP = f_pc + 2; 
                end
                
            end

            4'h7: begin

                //jxx
                if(f_ifun > 4'h6) begin 
                    // invalid_instruction = 1; 
                    f_stat = 3; end 
                else if(f_pc + 8 >= size) begin 
                    // invalid_instruction_address = 1; 
                    f_stat = 2; end
                // if(invalid_instruction | invalid_instruction_address) $finish;
                else begin
                f_valC = {
                    instruction_memory[f_pc + 8],
                    instruction_memory[f_pc + 7],
                    instruction_memory[f_pc + 6],
                    instruction_memory[f_pc + 5],
                    instruction_memory[f_pc + 4],
                    instruction_memory[f_pc + 3],
                    instruction_memory[f_pc + 2],
                    instruction_memory[f_pc + 1]
                };
                f_valP = f_pc + 9;
                end
                
                
            end

            4'h8: begin

                //call
                if(f_ifun > 4'h0) begin 
                    // invalid_instruction = 1; 
                    f_stat = 3;  end 
                else if(f_pc + 8 >= size) begin 
                    // invalid_instruction_address = 1; 
                    f_stat = 2; end 
                // if(invalid_instruction | invalid_instruction_address) $finish;
                else begin
                f_valC = {
                    instruction_memory[f_pc + 8],
                    instruction_memory[f_pc + 7],
                    instruction_memory[f_pc + 6],
                    instruction_memory[f_pc + 5],
                    instruction_memory[f_pc + 4],
                    instruction_memory[f_pc + 3],
                    instruction_memory[f_pc + 2],
                    instruction_memory[f_pc + 1]
                };
                f_valP = f_pc + 9;
                end 
                
                
            end

            4'h9: begin
                //ret
                if(f_ifun > 4'h0) begin
                    // invalid_instruction = 1;
                    f_stat = 3; 
                    // $finish;
                end
                // f_valP = f_pc + 1;              
            end

            4'hA: begin
                //pushq         
                if(f_ifun > 4'h0 | (f_pc + 1 < size & instruction_memory[f_pc + 1][3:0] < 4'hF)) begin 
                    // invalid_instruction = 1;
                    f_stat = 3; 
                 end
                else if(f_pc + 1 >= size) begin 
                    // invalid_instruction_address = 1; 
                    f_stat = 2; end 
                // if(invalid_instruction | invalid_instruction_address) $finish;
                else begin
                f_rA = instruction_memory[f_pc + 1][7:4];
                f_rB = instruction_memory[f_pc + 1][3:0];
                if(f_rA == 4'hF) begin
                    // invalid_instruction = 1;
                    f_stat = 3; 
                    f_rA = 0;
                    // $finish;
                end
                f_valP = f_pc + 2;
                end 
            end

            4'hB: begin
                //popq 
                if(f_ifun > 4'h0 | (f_pc + 1 < size & instruction_memory[f_pc + 1][3:0] < 4'hF)) begin
                    // invalid_instruction = 1;
                    f_stat = 3; 
                end
                else if(f_pc + 1 >= size) begin 
                    // invalid_instruction_address = 1; 
                    f_stat = 2; end
                // if(invalid_instruction | invalid_instruction_address) $finish;
                else begin
                f_rA = instruction_memory[f_pc + 1][7:4];
                f_rB = instruction_memory[f_pc + 1][3:0];
                if(f_rA == 4'hF) begin
                    // invalid_instruction = 1;
                    f_stat = 3; 
                    f_rA = 0;
                    // $finish;
                end
                f_valP = f_pc + 2;
                end
            end

            default:begin
                // invalid_instruction = 1;
                f_stat = 3; 
                // $finish;
            end

        endcase

    end
    
    // PC 
    always @(*) begin
        case(f_icode)

            4'h7, 4'h8: f_predPC = f_valC;
            default: f_predPC = f_valP;
            
        endcase
    end

    
endmodule