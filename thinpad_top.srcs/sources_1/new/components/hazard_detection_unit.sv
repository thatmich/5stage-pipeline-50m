`include "../constants.svh"
`timescale 1ns / 1ps
`default_nettype none
module hazard_detection_unit (
    // for detecting load hazard
    input wire [`INST_WIDTH-1:0] id_inst,
    input wire ex_rf_wen, 
    input wire [`REG_ADDR_WIDTH-1:0] ex_rf_waddr,

    input wire branch,

    output reg if_id_hold,
    output reg id_ex_hold,

    output reg if_id_flush,
    output reg id_ex_flush,
    output reg ex_mem_flush,
    output reg mem_wb_flush
);

    // detect hazard caused by load
    always_comb begin
        if (branch) begin
            if_id_flush = 1;
            id_ex_flush = 1;

            if_id_hold = 0;
            id_ex_hold = 0;
            ex_mem_flush = 0;
            mem_wb_flush = 0;
        end else if (id_inst[6:0] == `OPCODE_L) begin
            if (ex_rf_wen && (ex_rf_waddr == id_inst[19:15] || ex_rf_waddr == id_inst[24:20])) begin
                if_id_hold = 1;
                id_ex_flush = 1;

                id_ex_hold = 0;
                if_id_flush = 0;
                ex_mem_flush = 0;
                mem_wb_flush = 0;
            end else begin
                if_id_hold = 0;
                id_ex_flush = 0;

                id_ex_hold = 0;
                if_id_flush = 0;
                ex_mem_flush = 0;
                mem_wb_flush = 0;
            end
        end else begin
            if_id_hold = 0;
            id_ex_flush = 0;

            id_ex_hold = 0;
            if_id_flush = 0;
            ex_mem_flush = 0;
            mem_wb_flush = 0;
        end
    end

endmodule