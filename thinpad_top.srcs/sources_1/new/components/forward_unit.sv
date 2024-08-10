`include "../constants.svh"
`timescale 1ns / 1ps
`default_nettype none
module forward_unit(
    input wire [`REG_ADDR_WIDTH-1:0] ex_rs1,
    input wire [`REG_ADDR_WIDTH-1:0] ex_rs2,
    input wire [`REG_ADDR_WIDTH-1:0] mem_rd,
    input wire mem_rf_wen, 
    input wire [`REG_ADDR_WIDTH-1:0] wb_rd,
    input wire wb_rf_wen,

    output reg [1:0] alu_sel_a,
    output reg [1:0] alu_sel_b
);
    always_comb begin
        if (mem_rf_wen && mem_rd != 0 && ex_rs1 == mem_rd) begin
            alu_sel_a = ALU_SEL_MEM;
        end else if (wb_rf_wen && wb_rd != 0 && ex_rs1 == wb_rd) begin
            alu_sel_a = ALU_SEL_WB;
        end else begin
            alu_sel_a = ALU_SEL_EX;
        end

        if (mem_rf_wen && mem_rd != 0 && ex_rs2 == mem_rd) begin
            alu_sel_b = ALU_SEL_MEM;
        end else if (wb_rf_wen && wb_rd != 0 && ex_rs2 == wb_rd) begin
            alu_sel_b = ALU_SEL_WB;
        end else begin
            alu_sel_b = ALU_SEL_EX;
        end
    end
endmodule