`include "../constants.svh"
`timescale 1ns / 1ps
`default_nettype none
module ex_mem (
    input wire clk_i,
    input wire rst_i,
    input wire stall_i,
    input wire flush_i,

    // input from ex stage
    input wire [`ADDR_WIDTH-1:0] ex_pc_i,
    input wire [`INST_WIDTH-1:0] ex_inst_i,
    input wire [`DATA_WIDTH-1:0] ex_wb_adr_i, // calculated address
    input wire [`DATA_WIDTH-1:0] ex_wb_dat_i, // data to write
    input wire ex_wb_wen_i,
    input wire ex_wb_mem_en_i,
    input wire [3:0] ex_wb_sel_i,
    input wire ex_wb_read_signed_i,
    // regfile
    input wire ex_rf_wen_i,
    input wire [`REG_ADDR_WIDTH-1:0] ex_rf_waddr_i,
    // input wire [`DATA_WIDTH-1:0] ex_rf_wdata_i,
    input wire ex_rf_wb_from_mem_i,

    // output to mem stage
    output reg [`ADDR_WIDTH-1:0] mem_pc_o,
    output reg [`INST_WIDTH-1:0] mem_inst_o,

    output reg [`ADDR_WIDTH-1:0] mem_wb_adr_o,
    output reg [`DATA_WIDTH-1:0] mem_wb_dat_o,
    output reg mem_wb_wen_o,
    output reg mem_wb_mem_en_o,
    output reg [3:0] mem_wb_sel_o,
    output reg mem_wb_read_signed_o,
    output reg mem_rf_wen_o,
    output reg [`REG_ADDR_WIDTH-1:0] mem_rf_waddr_o,
    // output reg [`DATA_WIDTH-1:0] mem_rf_wdata_o,
    output reg mem_rf_wb_from_mem_o
);

    always_ff @ (posedge clk_i) begin
        if (rst_i) begin
            mem_pc_o <= 0;
            mem_inst_o <= `NOP;
            mem_wb_adr_o <= 0;
            mem_wb_dat_o <= 0;
            mem_wb_wen_o <= 0;
            mem_wb_mem_en_o <= 0;
            mem_wb_sel_o <= 0;
            mem_wb_read_signed_o <= 0;
            mem_rf_wen_o <= 0;
            mem_rf_waddr_o <= 0;
            // mem_rf_wdata_o <= 0;
            mem_rf_wb_from_mem_o <= 0;
        end else begin
            if (!stall_i) begin
                if (flush_i) begin
                    mem_pc_o <= 0;
                    mem_inst_o <= `NOP;
                    mem_wb_adr_o <= 0;
                    mem_wb_dat_o <= 0;
                    mem_wb_wen_o <= 0;
                    mem_wb_mem_en_o <= 0;
                    mem_wb_sel_o <= 0;
                    mem_wb_read_signed_o <= 0;
                    mem_rf_wen_o <= 0;
                    mem_rf_waddr_o <= 0;
                    // mem_rf_wdata_o <= 0;
                    mem_rf_wb_from_mem_o <= 0;
                end else begin
                    mem_pc_o <= ex_pc_i;
                    mem_inst_o <= ex_inst_i;
                    mem_wb_adr_o <= ex_wb_adr_i;
                    mem_wb_dat_o <= ex_wb_dat_i;
                    mem_wb_wen_o <= ex_wb_wen_i;
                    mem_wb_mem_en_o <= ex_wb_mem_en_i;
                    mem_wb_sel_o <= ex_wb_sel_i;
                    mem_wb_read_signed_o <= ex_wb_read_signed_i;
                    mem_rf_wen_o <= ex_rf_wen_i;
                    mem_rf_waddr_o <= ex_rf_waddr_i;
                    mem_rf_wb_from_mem_o <= ex_rf_wb_from_mem_i;
                end
            end
        end

    end

endmodule