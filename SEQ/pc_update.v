`timescale 1ns / 1ps

module pc_update(
    output reg [63:0] new_pc,
    input[3:0] icode,
    input[63:0] valC,
    input[63:0] valP,
    input[63:0] valM,
    input cnd,
    input clk
);
    
    always @(*) begin
        if(clk) begin
            case(icode)

                4'h7: begin
                    new_pc = cnd?valC:valP; //jXX
                end
                4'h8: begin
                    new_pc = valC; //call
                end
                4'h9: begin
                    new_pc = valM; //ret
                end
                default: begin
                    new_pc = valP; //remaining instructions
                end
            endcase
        end
    end
endmodule