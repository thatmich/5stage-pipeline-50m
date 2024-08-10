`include "../constants.svh"
`timescale 1ns / 1ps
`default_nettype none
module if_master (
    input wire clk_i,
    input wire rst_i,
    input wire stall_i,
    input wire hold_i,

    input wire branch_i,
    input wire [`ADDR_WIDTH-1:0] branch_target_i,

    input wire wb_ack_i,
    input wire [`DATA_WIDTH-1:0] wb_dat_i,
    
    output reg wb_cyc_o,
    output reg wb_stb_o,
    output reg [`ADDR_WIDTH-1:0] wb_adr_o,
    output reg [`DATA_WIDTH-1:0] wb_dat_o,
    output reg [`DATA_WIDTH/8-1:0] wb_sel_o,
    output reg wb_we_o,

    // cpu if
    output reg [`INST_WIDTH-1:0 ] inst_o,
    output reg [`ADDR_WIDTH-1:0] pc_o,
    output reg if_master_stall_o
);
    logic [`ADDR_WIDTH-1:0] pc_reg; // next pc

    typedef enum logic [1:0] {
        IDLE = 0,
        READ_ACTION = 1
    } state_t;
    state_t state;

    always_ff @ (posedge clk_i) begin
        if (rst_i) begin
            state <= IDLE;
            wb_cyc_o <= 0;
            wb_stb_o <= 0;
            wb_adr_o <= '{default: '0};
            wb_dat_o <= '{default: '0};
            wb_sel_o <= '{default: '0};
            wb_we_o <= 0;
            inst_o <= `NOP;
            pc_o <= 32'h80000000;
            pc_reg <= 32'h80000000 - 4;
            if_master_stall_o <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (!stall_i) begin
                        state <= READ_ACTION;
                        wb_cyc_o <= 1;
                        wb_stb_o <= 1;
                        if (branch_i) begin
                            wb_adr_o <= branch_target_i;
                            pc_reg <= branch_target_i;
                        end else begin
                            wb_adr_o <= pc_reg + 4;
                            pc_reg <= pc_reg + 4;;
                        end
                        wb_dat_o <= '{default: '0};
                        wb_sel_o <= 4'hf;
                        wb_we_o <= 0;
                        if_master_stall_o <= 1;
                    end
                end
                READ_ACTION: begin
                    if (wb_ack_i) begin
                        state <= IDLE;
                        wb_cyc_o <= 0;
                        wb_stb_o <= 0;
                        if_master_stall_o <= 0;
                        pc_o <= pc_reg;
                        inst_o <= wb_dat_i;
                        if (hold_i) begin
                            pc_reg <= pc_reg - 4;
                        end
                    end
                end
            endcase
        end
    end
endmodule