`include "../constants.svh"
`timescale 1ns / 1ps
`default_nettype none
module if_id (
    input wire clk_i,
    input wire rst_i,
    input wire stall_i,
    input wire flush_i,
    input wire hold_i,

    input wire [`ADDR_WIDTH-1:0] pc_i,
    input wire [`INST_WIDTH-1:0] inst_i,

    output reg [`ADDR_WIDTH-1:0] pc_o,
    output reg [`INST_WIDTH-1:0] inst_o
);
    always_ff @ (posedge clk_i) begin
        if (rst_i) begin
            pc_o <= 0;
            inst_o <= `NOP;
        end else begin
            if (!stall_i) begin // not stalled
                if (flush_i) begin
                    pc_o <= 0;
                    inst_o <= `NOP;
                end else begin
                    if (~hold_i) begin // proceed normally
                        pc_o <= pc_i;
                        inst_o <= inst_i;
                    end
                end
            end
        end
    end
endmodule