`timescale 1ns / 1ps

module ALU #(
    parameter BUS_WIDTH = 64,
    parameter SELECT_WIDTH = 2
) (
    output [BUS_WIDTH-1:0]result,
    output overflow_flag,
    input [BUS_WIDTH-1:0]num1,
    input [BUS_WIDTH-1:0]num2,
    input [SELECT_WIDTH-1:0]operation
);

//00 ADDITION
//01 SUBTRACTION
//10 BITWISE AND
//11 BITWISE XOR

wire inverted_selection[SELECT_WIDTH-1:0]; // for the decoding of the selection, we will also need their NOT values
genvar i;
generate
    for (i = 0; i < SELECT_WIDTH; i = i+1) begin
        not(inverted_selection[i], operation[i]);
    end
endgenerate //loop only for scaling/modularity purpose

wire and_enable, xor_enable;
and(and_enable, operation[1], inverted_selection[0]);
and(xor_enable, operation[1], operation[0]);

wire [BUS_WIDTH-1:0]add_sub_result;
wire sum_overflow;
wire [BUS_WIDTH-1:0]bitwise_and_result;
wire [BUS_WIDTH-1:0]bitwise_xor_result;

adder_subtractor ADD_SUB1(
    .result(add_sub_result),
    .overflow_flag(sum_overflow),
    .num1(num1),
    .num2(num2),
    .mode(operation[0])
);

bitwise_and BITWISE_AND1(
    .result(bitwise_and_result),
    .num1(num1),
    .num2(num2)
);

bitwise_xor BITWISE_XOR1(
    .result(bitwise_xor_result),
    .num1(num1),
    .num2(num2)
);

wire addsub_effective_result[BUS_WIDTH-1:0];
wire bitwise_and_effective_result[BUS_WIDTH-1:0];
wire bitwise_xor_effective_result[BUS_WIDTH-1:0];
//the effective result bit is 1 iff the result is 1 and the required operation is triggered

generate
    for (i = 0; i < BUS_WIDTH ; i = i + 1) begin
        and(addsub_effective_result[i], add_sub_result[i], inverted_selection[1]);
        and(bitwise_and_effective_result[i], bitwise_and_result[i], and_enable);
        and(bitwise_xor_effective_result[i], bitwise_xor_result[i], xor_enable);
        or(result[i], addsub_effective_result[i], bitwise_and_effective_result[i], bitwise_xor_effective_result[i]);
    end
endgenerate
and(overflow_flag, sum_overflow, inverted_selection[1]);
    
endmodule

module half_adder (
    output S, C,
    input A, B
);

    xor(S, A, B);
    and(C, A, B);
    
endmodule

module full_adder (
    output S, C,
    input A, B, Cin
);

    wire S0, C0;
    half_adder ha1(
        .A(A),
        .B(B),
        .S(S0),
        .C(C0)
    );

    wire C1;
    half_adder ha2(
        .A(S0),
        .B(Cin),
        .S(S),
        .C(C1)
    );

    or(C, C0, C1);
    
endmodule

module adder_subtractor #(
    parameter BUS_WIDTH = 64
) (
    output [BUS_WIDTH-1:0]result,
    output overflow_flag,
    input [BUS_WIDTH-1:0]num1,
    input [BUS_WIDTH-1:0]num2,
    input mode
);

    wire [BUS_WIDTH:0]carry;
    wire [BUS_WIDTH-1:0] num2_effective;

    assign carry[0] = mode;

    genvar i;
    generate
        for (i = 0; i < BUS_WIDTH; i = i + 1) begin
            xor(num2_effective[i], num2[i], mode);
        end
    endgenerate
    generate
        for (i = 0; i <  BUS_WIDTH; i = i + 1) begin
            full_adder FA1(result[i], carry[i+1], num1[i], num2_effective[i], carry[i]);
        end
    endgenerate
    
    xor(overflow_flag, carry[BUS_WIDTH], carry[BUS_WIDTH-1]);

endmodule

module bitwise_and #(
    parameter BUS_WIDTH = 64
) (
    output [BUS_WIDTH-1:0]result,
    input [BUS_WIDTH-1:0]num1,
    input [BUS_WIDTH-1:0]num2
);

genvar i;
generate
    for(i = 0; i < BUS_WIDTH; i = i + 1) begin
        and(result[i], num1[i], num2[i]);
    end
endgenerate
    
endmodule

module bitwise_xor #(
    parameter BUS_WIDTH = 64
) (
    output [BUS_WIDTH-1:0]result,
    output overflow_flag,
    input [BUS_WIDTH-1:0]num1,
    input [BUS_WIDTH-1:0]num2
);

genvar i;
generate
    for(i = 0; i < BUS_WIDTH; i = i + 1) begin
        xor(result[i], num1[i], num2[i]);
    end
endgenerate
    
endmodule