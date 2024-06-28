`timescale 10ns/1ps

module alu_tb;

initial 
begin
    $dumpfile("tb_and.vcd");
    $dumpvars(0, alu_tb);    
end

reg signed [63:0] a;
reg signed [63:0] b;
reg [1:0] select;
wire signed [63:0] s;
wire overflow;
integer i;

ALU uut(
    .num1(a),
    .num2(b),
    .result(s), 
    .overflow_flag(overflow),
    .operation(select)
);

initial
begin
    select = 2'b10;
    a = -5;
    b = 107;

    for(i = 0; i < 10; i = i + 1) begin
        #10;
        a = $random;
        b = $random;
    end

    for(i = 0; i < 10; i = i + 1) begin
        #10;
        a = $random << 32;
        a |= $random;
        b = $random << 32;
        b |= $random;
    end

end

initial 
begin
    $monitor("time = %3d, a = %d, b = %d, s = %d, overflow = %1b, select = %d", $time, a, b, s, overflow, select);
end

endmodule