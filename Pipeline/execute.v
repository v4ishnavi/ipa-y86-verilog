`include "../ALU/ALU.v"
`timescale 1ns / 1ps

module execute (
    output reg [63:0] e_valE,
    output reg e_cnd, zero_flag, sign_flag, overflow_flag,
    output reg[63:0] e_valA,
    output reg[3:0] e_dstE, e_dstM,e_icode,
    output reg[1:0] e_stat,
    input clk,
    input [3:0] E_icode,
    input [3:0] E_ifun,
    input [63:0] E_valA,
    input [63:0] E_valB,
    input [63:0] E_valC,
    input [3:0] E_dstE, 
    input [3:0] E_dstM,
    input [1:0] E_stat,
    input set_cc
);

    initial begin
        e_valE = 0;
        e_cnd = 0;
        // e_icode = 0;
        // e_valA = 0;
        // e_dstM = 0;
        // e_dstE = 0;
        zero_flag = 0;
        sign_flag = 0;
        overflow_flag = 0;
    end

    wire signed [63:0] alu_output;
    reg signed [63:0] num1;
    reg signed [63:0] num2;
    reg [1:0] operation;
    wire overflow;

    ALU alu1(
        .result(alu_output),
        .overflow_flag(overflow),
        .num1(num1),
        .num2(num2),
        .operation(operation)
    );

    initial begin
        num1 = 0;
        num2 = 0;
        operation = 0;
    end

    always @(*) begin
        //doing this only at positive level so that writebacks can happen at negative edge
        if(e_icode == 4'h6 && set_cc) begin
            zero_flag = (alu_output == 64'b0);
            sign_flag = alu_output[63];
            overflow_flag = overflow;
        end
    end

    always @(*) begin
        
            case (e_icode)

                4'h2: begin
                    //cmovxx
                    num1 = E_valA;
                    num2 = E_valB;
                    operation = 2'b00;
                    // #1;
                    e_valE = alu_output;

                    case (E_ifun)
                        4'h0: e_cnd = 1; //no condition to satisfy
                        4'h1: e_cnd = (sign_flag ^ overflow_flag) | zero_flag;// cmovle
                        4'h2: e_cnd = sign_flag ^ overflow_flag;// cmovl
                        4'h3: e_cnd = zero_flag;// cmove
                        4'h4: e_cnd = ~zero_flag;// cmovne
                        4'h5: e_cnd = ~(sign_flag ^ overflow_flag); // cmovge
                        4'h6: e_cnd = ~((sign_flag ^ overflow_flag) | zero_flag);// cmovg
                    endcase

                end

                4'h3:begin
                    //irmovq
                    e_valE = E_valC;
                end

                4'h4: begin
                    //rmmovq
                    num1 = E_valB;
                    num2 = E_valC;
                    operation = 2'b00;
                    // #1;
                    e_valE = alu_output;
                end

                4'h5: begin
                    //mrmovq
                    num1 = E_valB;
                    num2 = E_valC;
                    operation = 2'b00;
                    // #1;
                    e_valE = alu_output;
                end

                4'h6: begin
                    //OPq -> E_valB OP e_valA
                    // #3;
                    num1 = E_valB;
                    num2 = E_valA;
                    operation = E_ifun;
                    // #1;
                    e_valE = alu_output;
                end

                4'h7: begin
                    //jxx
                    case (E_ifun)
                        4'h0: e_cnd = 1; //no condition to satisfy
                        4'h1: e_cnd = (sign_flag ^ overflow_flag) | zero_flag;// jle
                        4'h2: e_cnd = sign_flag ^ overflow_flag;// jl
                        4'h3: e_cnd = zero_flag;// je
                        4'h4: e_cnd = ~zero_flag;// jne
                        4'h5: e_cnd = ~(sign_flag ^ overflow_flag); // jge
                        4'h6: e_cnd = ~((sign_flag ^ overflow_flag) | zero_flag);// jg
                    endcase
                end

                4'h8: begin
                    //call
                    num1 = E_valB;
                    num2 = -8;
                    operation = 2'b00;
                    // #1;
                    e_valE = alu_output;
                end

                4'h9: begin
                    //ret
                    num1 = E_valB;
                    num2 = 8;
                    operation = 2'b00;
                    // #1;
                    e_valE = alu_output;
                end

                4'hA: begin
                    //pushq
                    num1 = E_valB;
                    num2 = -8;
                    operation = 2'b00;
                    // #1;
                    e_valE = alu_output;
                end

                4'hB: begin
                    //popq
                    num1 = E_valB;
                    num2 = 8;
                    operation = 2'b00;
                    // #1;
                    e_valE = alu_output;
                end
                
            endcase
    end

    always @(*) begin
        e_stat = E_stat;
        e_icode = E_icode;
        e_valA = E_valA;
        e_dstM = E_dstM;
        e_dstE = (E_icode == 2 && !e_cnd) ? 4'hF: E_dstE;
    end

    
endmodule