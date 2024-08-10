`include "../constants.svh"
`timescale 1ns / 1ps
`default_nettype none
module regfile (
    input wire clk,
    input wire rst,
    //write
    input wire [`REG_ADDR_WIDTH-1:0] waddr,
    input wire [`DATA_WIDTH-1:0] wdata,
    input wire wen,
    //read
    input wire [`REG_ADDR_WIDTH-1:0] raddr_a,
    output reg [`DATA_WIDTH-1:0] rdata_a,
    input wire [`REG_ADDR_WIDTH-1:0] raddr_b,
    output reg [`DATA_WIDTH-1:0] rdata_b
);
    logic [`DATA_WIDTH-1:0] registers [`REG_NUM-1:0];

    always_ff @(posedge clk) begin
        if (rst) begin
            registers <= '{default: '0};
        end else begin
            if (wen) begin
                if (waddr != 5'b00000) begin
                    registers[waddr] <= wdata;
                end
            end
        end
    end

    always_comb begin
        rdata_a = registers[raddr_a];
        rdata_b = registers[raddr_b];
    end
endmodule