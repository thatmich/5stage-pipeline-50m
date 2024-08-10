`include "../constants.svh"
`timescale 1ns / 1ps
`default_nettype none
module mem_wb (
    input wire clk_i,
    input wire rst_i,
    input wire stall_i,
    input wire flush_i,

    // input wire [`ADDR_WIDTH-1:0] pc_i,
    // input wire [`INST_WIDTH-1:0] inst_i,
    // inputs from mem stage
    input wire rf_wen_i,
    input wire [`REG_ADDR_WIDTH-1:0] rf_waddr_i,
    input wire [`DATA_WIDTH-1:0] rf_wdata_i,
    // outputs to wb stage
    output reg rf_wen_o,
    output reg [`REG_ADDR_WIDTH-1:0] rf_waddr_o,
    output reg [`DATA_WIDTH-1:0] rf_wdata_o
);
    // output signals for the wb stage next cycle
    always_ff @ (posedge clk_i) begin
        if (rst_i) begin
            rf_wen_o <= 0;
            rf_waddr_o <= '{default: '0};
            rf_wdata_o <= '{default: '0};
        end else begin
            if (!stall_i) begin
                if (flush_i) begin
                    rf_wen_o <= 0;
                    rf_waddr_o <= '{default: '0};
                    rf_wdata_o <= '{default: '0};
                end else begin
                    rf_wen_o <= rf_wen_i;
                    rf_waddr_o <= rf_waddr_i;
                    rf_wdata_o <= rf_wdata_i;
                end
            end
        end
    end
endmodule