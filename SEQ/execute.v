`include "../ALU/ALU.v"
`timescale 1ns / 1ps

module execute (
    output reg [63:0] valE,
    output reg cnd, zero_flag, sign_flag, overflow_flag,
    input clk,
    input [3:0] icode,
    input [3:0] ifun,
    input [63:0] valA,
    input [63:0] valB,
    input [63:0] valC
);

    initial begin
        valE = 0;
        cnd = 0;
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
        if(clk && icode == 4'h6) begin
            zero_flag = (alu_output == 64'b0);
            sign_flag = alu_output[63];
            overflow_flag = overflow;
        end
    end

    always @(*) begin
        
        if(clk) begin
            case (icode)

                4'h2: begin
                    //cmovxx
                    num1 = valA;
                    num2 = valB;
                    operation = 2'b00;
                    // #1;
                    valE = alu_output;

                    case (ifun)
                        4'h0: cnd = 1; //no condition to satisfy
                        4'h1: cnd = (sign_flag ^ overflow_flag) | zero_flag;// cmovle
                        4'h2: cnd = sign_flag ^ overflow_flag;// cmovl
                        4'h3: cnd = zero_flag;// cmove
                        4'h4: cnd = ~zero_flag;// cmovne
                        4'h5: cnd = ~(sign_flag ^ overflow_flag); // cmovge
                        4'h6: cnd = ~((sign_flag ^ overflow_flag) | zero_flag);// cmovg
                    endcase

                end

                4'h3:begin
                    //irmovq
                    valE = valC;
                end

                4'h4: begin
                    //rmmovq
                    num1 = valB;
                    num2 = valC;
                    operation = 2'b00;
                    // #1;
                    valE = alu_output;
                end

                4'h5: begin
                    //mrmovq
                    num1 = valB;
                    num2 = valC;
                    operation = 2'b00;
                    // #1;
                    valE = alu_output;
                end

                4'h6: begin
                    //OPq -> valB OP valA
                    // #3;
                    num1 = valB;
                    num2 = valA;
                    operation = ifun;
                    // #1;
                    valE = alu_output;
                end

                4'h7: begin
                    //jxx
                    case (ifun)
                        4'h0: cnd = 1; //no condition to satisfy
                        4'h1: cnd = (sign_flag ^ overflow_flag) | zero_flag;// jle
                        4'h2: cnd = sign_flag ^ overflow_flag;// jl
                        4'h3: cnd = zero_flag;// je
                        4'h4: cnd = ~zero_flag;// jne
                        4'h5: cnd = ~(sign_flag ^ overflow_flag); // jge
                        4'h6: cnd = ~((sign_flag ^ overflow_flag) | zero_flag);// jg
                    endcase
                end

                4'h8: begin
                    //call
                    num1 = valB;
                    num2 = -8;
                    operation = 2'b00;
                    // #1;
                    valE = alu_output;
                end

                4'h9: begin
                    //ret
                    num1 = valB;
                    num2 = 8;
                    operation = 2'b00;
                    // #1;
                    valE = alu_output;
                end

                4'hA: begin
                    //pushq
                    num1 = valB;
                    num2 = -8;
                    operation = 2'b00;
                    // #1;
                    valE = alu_output;
                end

                4'hB: begin
                    //popq
                    num1 = valB;
                    num2 = 8;
                    operation = 2'b00;
                    // #1;
                    valE = alu_output;
                end
                
            endcase
        end
    end

    
endmodule