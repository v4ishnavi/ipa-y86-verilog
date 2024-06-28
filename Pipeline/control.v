`timescale 1ns / 1ps

module control(
    input clk,
    input [3:0] d_srcA, d_srcB, D_icode,
    input [3:0] E_dstM, E_icode, 
    input e_cnd,
    input [3:0] M_icode,
    input [1:0] W_stat, m_stat,

    output reg F_stall,
    output reg D_bubble, D_stall,
    output reg E_bubble, 
    output reg set_cc,
    output reg M_bubble, 
    output reg W_stall
);

initial begin
    F_stall = 0;
    D_bubble = 0;
    D_stall = 0;
    E_bubble = 0;
    set_cc = 0;
    M_bubble = 0;
    W_stall = 0;
end

always @(*) begin
    //F_stall conditions 
    if(((E_icode == 4'h5 || E_icode == 4'hB) && (E_dstM == d_srcA || E_dstM == d_srcB)) || (D_icode == 4'h9 || E_icode == 4'h9 || M_icode == 4'h9))
    begin
        F_stall = 1;
    end
    else begin
        F_stall = 0;
    end

    //D_stall conditions 
    if((E_icode == 4'h5 || E_icode == 4'hB) && (E_dstM == d_srcA || E_dstM == d_srcB))
    begin
        D_stall = 1;
    end
    else begin
        D_stall = 0; 
    end
    //D_bubble conditions
    if((E_icode == 4'h7 && !e_cnd) || !((E_icode == 4'h5 || E_icode == 4'hB) && (E_dstM == d_srcA || E_dstM == d_srcB)) && (D_icode == 4'h9 || E_icode == 4'h9 || M_icode == 4'h9))
    begin
        D_bubble = 1;
    end
    else begin
        D_bubble = 0;
    end

    //E_bubble conditions
    if((E_icode == 4'h7 && !e_cnd)|| (E_icode == 4'h5 || E_icode == 4'hB)&& (E_dstM == d_srcA || E_dstM == d_srcB))
    begin
        E_bubble = 1;
    end
    else begin
        E_bubble = 0;
    end

    //M_bubble conditions 
    if((m_stat == 1 || m_stat == 2 || m_stat == 3) || (W_stat == 1 || W_stat == 2 || W_stat == 3))begin
        M_bubble = 1;
    end
    else begin
        M_bubble = 0; 
    end
    //W_stall conditions 
    if(W_stat == 1 || W_stat == 2 || W_stat == 3)begin
        W_stall = 1;
    end
    else begin
        W_stall = 0; 
    end

    //set_cc conditions 
    if((E_icode == 4'h6) && !(m_stat!=0) && !(W_stat != 0))begin
        set_cc = 1;
    end
    else begin
        set_cc = 0; 
    end
end
endmodule