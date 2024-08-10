`include "../constants.svh"
`timescale 1ns / 1ps
`default_nettype none
module mem_master (
    input wire clk_i,
    input wire rst_i,

    // for cpu
    input wire [`ADDR_WIDTH-1:0] addr_i,
    input wire [`DATA_WIDTH-1:0] data_i,
    input wire mem_en_i,
    input wire wen_i,
    input wire [`DATA_WIDTH/8-1:0] sel_i,
    input wire stall_i,
    input wire read_signed_i,

    output reg [`DATA_WIDTH-1:0] mem_read_data_o,
    output reg mem_master_stall_o,

    // for mem slave
    output reg wb_cyc_o,
    output reg wb_stb_o,
    output reg [`ADDR_WIDTH-1:0] wb_adr_o,
    output reg [`DATA_WIDTH-1:0] wb_dat_o,
    output reg [`DATA_WIDTH/8-1:0] wb_sel_o,
    output reg wb_we_o,

    input wire wb_ack_i,
    input wire [`DATA_WIDTH-1:0] wb_dat_i
);
    // states
    typedef enum logic [2:0] {
        IDLE = 0,
        READ_ACTION = 1,
        WRITE_ACTION = 2,
        DONE = 3
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
            mem_master_stall_o <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (mem_en_i) begin
                        if (wen_i) begin // write
                            state <= WRITE_ACTION;
                            wb_adr_o <= addr_i;
                            wb_dat_o <= data_i;
                            wb_sel_o <= sel_i << addr_i[1:0];
                            wb_cyc_o <= 1;
                            wb_stb_o <= 1;
                            wb_we_o <= 1;
                            mem_master_stall_o <= 1;
                        end else begin // read
                            state <= READ_ACTION;
                            wb_adr_o <= addr_i;
                            wb_sel_o <= sel_i << addr_i[1:0];
                            wb_cyc_o <= 1;
                            wb_stb_o <= 1;
                            wb_we_o <= 0;
                            mem_master_stall_o <= 1;
                        end
                    end
                end
                READ_ACTION: begin
                    if (wb_ack_i) begin
                        state <= DONE;
                        wb_cyc_o <= 0;
                        wb_stb_o <= 0;
                        mem_master_stall_o <= 0;
                        // since sel is not processed by sram controller for write, we process the output
                        case (wb_sel_o)
                            4'b0001: mem_read_data_o <= (read_signed_i ? {{24{wb_dat_i[7]}}, wb_dat_i[7:0]} : {24'b0, wb_dat_i[7:0]});
                            4'b0010: mem_read_data_o <= (read_signed_i ? {{24{wb_dat_i[15]}}, wb_dat_i[15:8]} : {24'b0, wb_dat_i[15:8]});
                            4'b0100: mem_read_data_o <= (read_signed_i ? {{24{wb_dat_i[23]}}, wb_dat_i[23:16]} : {24'b0, wb_dat_i[23:16]});
                            4'b1000: mem_read_data_o <= (read_signed_i ? {{24{wb_dat_i[31]}}, wb_dat_i[31:24]} : {24'b0, wb_dat_i[31:24]});
                            4'b0011: mem_read_data_o <= (read_signed_i ? {{16{wb_dat_i[15]}}, wb_dat_i[15:0]} : {16'b0, wb_dat_i[15:0]});
                            4'b0110: mem_read_data_o <= (read_signed_i ? {{16{wb_dat_i[23]}}, wb_dat_i[23:8]} : {16'b0, wb_dat_i[23:8]});
                            4'b1100: mem_read_data_o <= (read_signed_i ? {{16{wb_dat_i[31]}}, wb_dat_i[31:16]} : {16'b0, wb_dat_i[31:16]});
                            4'b1111: mem_read_data_o <= wb_dat_i;
                            default: mem_read_data_o <= 0;
                        endcase
                    end else begin
                        state <= READ_ACTION;
                    end
                end
                WRITE_ACTION: begin
                    if (wb_ack_i) begin
                        state <= DONE;
                        mem_master_stall_o <= 0;
                        wb_cyc_o <= 0;
                        wb_stb_o <= 0;
                        wb_we_o <= 0;
                    end else begin
                        state <= WRITE_ACTION;
                    end
                end
                DONE: begin
                    if (!stall_i)
                        state <= IDLE;
                    // otherwise, it'll just hold
                end
            endcase
        end
    end
endmodule