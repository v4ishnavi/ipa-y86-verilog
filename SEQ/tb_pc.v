`timescale 1ns / 1ps

module pc_update_tb;

    reg [3:0] icode;
    reg [63:0] valC;
    reg [63:0] valP;
    reg [63:0] valM;
    reg cnd;
    reg clk;
    wire[63:0] pc;

    pc_update uut (
        .pc(pc),
        .icode(icode),
        .valC(valC),
        .valP(valP),
        .valM(valM),
        .cnd(cnd),
        .clk(clk)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        icode = 4'hF;
        valC = 0;
        valP = 0;
        valM = 0;
        cnd = 0;

        #100;

        icode = 4'h7; // jXX
        valC = 64'h20; 
        valP = 64'h10; //next
        cnd = 1; // Condition is true
        #10;

        cnd = 0; // Condition is false
        #10;

        icode = 4'h8; // call
        valC = 64'h30; 
        #10;


        icode = 4'h9; // ret
        valM = 64'h40;
        #10;

        icode = 4'h2; //def
        valP = 64'h50;
        #10;

        $finish;
    end


    initial begin
        $monitor("At time %t, icode=%h, cnd=%b, valC=%h, valP=%h, valM=%h -> pc=%h",
                  $time, icode, cnd, valC, valP, valM, pc);
    end

endmodule
