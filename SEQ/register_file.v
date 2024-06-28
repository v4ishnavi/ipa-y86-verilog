`timescale 1ns / 1ps

module register_file(
    output reg [63:0] valA,
    output reg [63:0] valB,
    output reg [63:0] reg0,
    output reg [63:0] reg1,
    output reg [63:0] reg2,
    output reg [63:0] reg3,
    output reg [63:0] reg4,
    output reg [63:0] reg5,
    output reg [63:0] reg6,
    output reg [63:0] reg7,
    output reg [63:0] reg8,
    output reg [63:0] reg9,
    output reg [63:0] regA,
    output reg [63:0] regB,
    output reg [63:0] regC,
    output reg [63:0] regD,
    output reg [63:0] regE,
    input clk,
    input [3:0] icode,
    input [3:0] rA,
    input [3:0] rB,
    input cnd,
    input [63:0] valE,
    input [63:0] valM
);

    reg [63:0] registers [0:14];
    integer i;
    initial begin
        for (i = 0; i < 15; i = i + 1 ) begin
            registers[i] = i;
        end
        //initializing for testing purpose
    end

    always @(*) begin
        case (icode)
            4'h2:begin
                valA = registers[rA]; //cmovxx
                valB = 0;
            end
            4'h3: valB = registers[rB]; //irmovq
            4'h4: begin //rmmovq
                valA = registers[rA];
                valB = registers[rB];
            end
            4'h5: begin //mrmovq
                valA = registers[rA];
                valB = registers[rB];
            end
            4'h6: begin //opq
                valA = registers[rA];
                valB = registers[rB];
            end
            4'h8: valB = registers[4]; //call register4 = rsp
            4'h9: begin //ret
                valA = registers[4];
                valB = registers[4];
            end
            4'hA: begin 
                // valA = registers[rA]; // pushq
                valA = registers[rA];
                valB = registers[4];
            end
            4'hB: begin 
                valA = registers[4]; //popq
                valB = registers[4];
            end
        endcase

    end

    always @(negedge clk ) begin
        case (icode)
            
            4'h2:begin
                if(cnd) 
                begin
                    registers[rB] = valE;
                end
            end
            4'h3: begin
                registers[rB] = valE;
            end
            4'h5: begin //mrmovq
                registers[rA] = valM;
            end
            4'h6: begin //opq
                registers[rB] = valE;
            end
            4'h8: begin //call
                registers[4] = valE;
            end
            4'h9: begin //ret
                registers[4] = valE;
            end
            4'hA: begin
                registers[4] = valE;
            end
            4'hB: begin
                registers[4] = valE;
                registers[rA] = valM;
            end
    
        endcase
        reg0 = registers[0];
        reg1 = registers[1];
        reg2 = registers[2];
        reg3 = registers[3];
        reg4 = registers[4];
        reg5 = registers[5];
        reg6 = registers[6];
        reg7 = registers[7];
        reg8 = registers[8];
        reg9 = registers[9];
        regA = registers[10];
        regB = registers[11];
        regC = registers[12];
        regD = registers[13];
        regE = registers[14];
    end
    
endmodule
