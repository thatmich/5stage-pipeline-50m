`include "../constants.svh"
`timescale 1ns / 1ps
`default_nettype none
module id_ex (
    input wire clk_i,
    input wire rst_i,
    input wire stall_i,
    input wire flush_i,
    input wire hold_i,

    input wire [`ADDR_WIDTH-1:0] id_pc_i,
    input wire [`INST_WIDTH-1:0] id_inst_i,

    input wire [`DATA_WIDTH-1:0] id_rf_data_a_i,
    input wire [`DATA_WIDTH-1:0] id_rf_data_b_i,
    input wire id_rf_wen_i,
    input wire [`REG_ADDR_WIDTH-1:0] id_rf_waddr_i,
    input wire id_rf_wb_from_mem_i,

    input wire [`ALU_OP_WIDTH-1:0] id_alu_op_i,
    input wire id_alu_a_pc_i,
    input wire id_alu_b_imm_i,

    input wire id_wb_mem_en_i,
    input wire id_wb_wen_i,
    input wire [3:0] id_wb_sel_i,
    input wire id_wb_read_signed_i,

    input wire [`REG_ADDR_WIDTH-1:0] id_rs1_i,
    input wire [`REG_ADDR_WIDTH-1:0] id_rs2_i,
    input wire [`DATA_WIDTH-1:0] id_imm_i,

    output reg [`ADDR_WIDTH-1:0] ex_pc_o,
    output reg [`INST_WIDTH-1:0] ex_inst_o,

    output reg [`DATA_WIDTH-1:0] ex_rf_data_a_o,
    output reg [`DATA_WIDTH-1:0] ex_rf_data_b_o,
    output reg ex_rf_wen_o,
    output reg [`REG_ADDR_WIDTH-1:0] ex_rf_waddr_o,
    output reg ex_rf_wb_from_mem_o,

    output reg [`ALU_OP_WIDTH-1:0] ex_alu_op_o,
    output reg ex_alu_a_pc_o,
    output reg ex_alu_b_imm_o,

    output reg ex_wb_mem_en_o,
    output reg ex_wb_wen_o,
    output reg [3:0] ex_wb_sel_o,
    output reg ex_wb_read_signed_o,
    
    output reg [`REG_ADDR_WIDTH-1:0] ex_rs1_o,
    output reg [`REG_ADDR_WIDTH-1:0] ex_rs2_o,
    output reg [`DATA_WIDTH-1:0] ex_imm_o
);
    always_ff @ (posedge clk_i) begin
        if (rst_i) begin
            ex_pc_o <= 32'h00000000;
            ex_inst_o <= `NOP;
            ex_rf_data_a_o <= 0;
            ex_rf_data_b_o <= 0;
            ex_rf_wen_o <= 0;
            ex_rf_waddr_o <= 0;
            ex_rf_wb_from_mem_o <= 0;
            ex_alu_op_o <= 0;
            ex_alu_a_pc_o <= 0;
            ex_alu_b_imm_o <= 0;
            ex_wb_mem_en_o <= 0;
            ex_wb_wen_o <= 0;
            ex_wb_sel_o <= 0;
            ex_wb_read_signed_o <= 0;
            ex_rs1_o <= 0;
            ex_rs2_o <= 0;
            ex_imm_o <= 0;
        end else if (!stall_i) begin
            if (flush_i) begin
                ex_pc_o <= 32'h00000000;
                ex_inst_o <= `NOP;
                ex_rf_data_a_o <= 0;
                ex_rf_data_b_o <= 0;
                ex_rf_wen_o <= 0;
                ex_rf_waddr_o <= 0;
                ex_rf_wb_from_mem_o <= 0;
                ex_alu_op_o <= 0;
                ex_alu_a_pc_o <= 0;
                ex_alu_b_imm_o <= 0;
                ex_wb_mem_en_o <= 0;
                ex_wb_wen_o <= 0;
                ex_wb_sel_o <= 0;
                ex_wb_read_signed_o <= 0;
                ex_rs1_o <= 0;
                ex_rs2_o <= 0;
                ex_imm_o <= 0;
            end else if (!hold_i) begin
                ex_pc_o <= id_pc_i;
                ex_inst_o <= id_inst_i;
                ex_rf_data_a_o <= id_rf_data_a_i;
                ex_rf_data_b_o <= id_rf_data_b_i;
                ex_rf_wen_o <= id_rf_wen_i;
                ex_rf_waddr_o <= id_rf_waddr_i;
                ex_rf_wb_from_mem_o <= id_rf_wb_from_mem_i;
                ex_alu_op_o <= id_alu_op_i;
                ex_alu_a_pc_o <= id_alu_a_pc_i;
                ex_alu_b_imm_o <= id_alu_b_imm_i;
                ex_wb_mem_en_o <= id_wb_mem_en_i;
                ex_wb_wen_o <= id_wb_wen_i;
                ex_wb_sel_o <= id_wb_sel_i;
                ex_wb_read_signed_o <= id_wb_read_signed_i;
                ex_rs1_o <= id_rs1_i;
                ex_rs2_o <= id_rs2_i;
                ex_imm_o <= id_imm_i;
            end
        end
    end

endmodule