`timescale 1ns / 1ps
`default_nettype none
module sram_controller #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,

    parameter SRAM_ADDR_WIDTH = 20,
    parameter SRAM_DATA_WIDTH = 32,

    localparam SRAM_BYTES = SRAM_DATA_WIDTH / 8,
    localparam SRAM_BYTE_WIDTH = $clog2(SRAM_BYTES)
) (
    // clk and reset
    input wire clk_i,
    input wire rst_i,

    // wishbone slave interface
    input wire wb_cyc_i,
    input wire wb_stb_i,
    output reg wb_ack_o,
    input wire [ADDR_WIDTH-1:0] wb_adr_i,
    input wire [DATA_WIDTH-1:0] wb_dat_i,
    output reg [DATA_WIDTH-1:0] wb_dat_o,
    input wire [DATA_WIDTH/8-1:0] wb_sel_i,
    input wire wb_we_i,

    // sram interface
    output reg [SRAM_ADDR_WIDTH-1:0] sram_addr,
    inout wire [SRAM_DATA_WIDTH-1:0] sram_data,
    output reg sram_ce_n,
    output reg sram_oe_n,
    output reg sram_we_n,
    output reg [SRAM_BYTES-1:0] sram_be_n
);

    typedef enum logic [2:0] {
        STATE_IDLE = 0,
        STATE_READ = 1,
        STATE_READ_2 = 2,
        STATE_WRITE = 3,
        STATE_WRITE_2 = 4,
        STATE_WRITE_3 = 5,
        STATE_DONE = 6
    } state_t;

    state_t state;

    always_ff @ (posedge clk_i) begin
        if (rst_i) begin
            state <= STATE_IDLE;
            sram_ce_n <= 1;
            sram_oe_n <= 1;
            sram_we_n <= 1;
            sram_be_n <= '{default: '0};
            wb_ack_o <= 0;
            wb_dat_o <= '{default: '0};
        end else begin
            case (state)
                STATE_IDLE: begin
                    wb_ack_o <= 0;
                    sram_addr <= wb_adr_i[21:2];
                    if (wb_stb_i && wb_cyc_i) begin
                        sram_ce_n <= 0;
                        if (wb_we_i) begin
                            sram_be_n <= ~wb_sel_i;
                            state <= STATE_WRITE;
                        end else begin
                            sram_oe_n <= 0;
                            state <= STATE_READ;
                        end
                    end
                end
                STATE_READ: begin
                    state <= STATE_READ_2;
                end
                STATE_READ_2: begin
                    sram_ce_n <= 1;
                    sram_oe_n <= 1;
                    wb_ack_o <= 1;
                    wb_dat_o <= sram_data;
                    state <= STATE_DONE;
                end
                STATE_WRITE: begin
                    sram_we_n <= 0;
                    state <= STATE_WRITE_2;
                end
                STATE_WRITE_2: begin
                    sram_we_n <= 1;
                    state <= STATE_WRITE_3;
                end
                STATE_WRITE_3: begin
                    sram_ce_n <= 1;
                    wb_ack_o <= 1;
                    sram_be_n <= '{default: '0};
                    state <= STATE_DONE;
                end
                STATE_DONE: begin
                    state <= STATE_IDLE;
                    wb_ack_o <= 0;
                end
                default: begin
                    state <= STATE_IDLE;
                end
            endcase
        end
    end

    assign sram_data = sram_we_n ? 32'bz : wb_dat_i;

endmodule
