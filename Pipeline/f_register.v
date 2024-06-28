`timescale 1ns / 1ps
module f_register (
input F_stall,
input[63:0] f_predPC,
input clk,
// input[3:0] f_pc, //the input pc. 
// input [3:0] F_stat,
output reg [63:0] F_pc_prelim //goes into F stage.
// output reg [3:0] f_stat
);

always @(posedge clk) begin

    if(!F_stall)begin
        F_pc_prelim = f_predPC;
    end

end

endmodule