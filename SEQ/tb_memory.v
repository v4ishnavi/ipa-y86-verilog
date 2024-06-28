`timescale 1ns / 1ps
 
module memory_tb;

    // Parameters of the memory module
    localparam mem_size = 512;
    localparam reg_size = 8;

    // Testbench signals
    reg clk;
    reg [3:0] icode;
    reg [63:0] valA, valE, valP;
    wire [63:0] valM;
    wire error;
    memory uut (
        .clk(clk),
        .icode(icode),
        .valA(valA),
        .valE(valE),
        .valP(valP),
        .valM(valM),
        .error(error)
    );
    initial begin
        forever begin
            #5;
            clk = ~clk;
        end
    end
    initial begin
        clk = 0;
    end
    initial begin
        // Initialize Inputs
        
        valA = 0;
        valE = 0;
        valP = 0;
        icode = 4'hF;
        #10;
        icode = 4'h4; // rmmovq instruction
        valA = 64'hA5A5A5A5A5A5A5A5;
        valE = 0; // write address

        #10;
        icode = 4'h5; // mrmovq instruction
        valE = 0; //read address

        #10;
        icode = 4'h4; // rmmovq instruction
        valA = 64'hFFFFFFFFFFFFFFFF;
        valE = mem_size; //error

        #10;
        icode = 4'h5; // mrmovq instruction
        valE = mem_size; //error

        
        #10;
        icode = 4'h8; // call instruction
        valE = 64'h10; //storing valP
        valP = 64'h100; // return address


        #20;
        icode = 4'h9; // ret instruction
        valA = 64'h10; //taking from valA

        #10;
        icode = 4'hA; // pushq instruction
        valA = 64'hDEADBEEFDEADBEEF;
        valE = 64'h20; //pointer after push

    
        #20;
        icode = 4'hB; // popq instruction
        valA = 64'h20; //pointer before pop

    
        #10;
        icode = 4'h4; // rmmovq instruction
        valA = 64'hCAFEBABECAFEBABE;
        valE = 64'h3;

        #10;
        valA = 64'hDEADDEADDEADDEAD; // overwrite

        #10;
        icode = 4'h5; // mrmovq instruction
        valE = 64'h3; //same as bef

        #10;
        icode = 4'h4; // rmmovq instruction
        valA = 64'hF00DF00DF00DF00D;
        valE = mem_size + 1; // error
        #10;
        $finish;
    end

    // Monitor changes
    initial begin
        $monitor("Time=%d, icode=%h, valA=%d, valE=%d, valP=%d, valM=%d, error=%b",
                  $time, icode, valA, valE, valP, valM, error);
    end

endmodule