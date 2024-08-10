`include "../constants.svh"
`timescale 1ns / 1ps
`default_nettype none
module alu (
    input wire [`DATA_WIDTH-1:0] a,
    input wire [`DATA_WIDTH-1:0] b,
    input wire [`ALU_OP_WIDTH-1:0] op,
    output reg [`DATA_WIDTH-1:0] y
    );

    logic [4:0] clz_result;
    always_comb begin
        case(op)
            ALU_OP_ADD: begin
                y = a + b;
            end
            ALU_OP_SUB: begin
                y = a - b;
            end
            ALU_OP_AND: begin
                y = a & b;
            end
            ALU_OP_OR: begin
                y = a | b;
            end
            ALU_OP_XOR: begin
                y = a ^ b;
            end
            ALU_OP_NOT: begin
                y = ~a;
            end
            ALU_OP_SLL: begin
                y = a << (b & 32'h000F);
            end
            ALU_OP_SRL: begin
                // only consider least significant 4 bits
                y = a >> (b & 32'h000F);
            end
            ALU_OP_SRA: begin
                y = $signed(a) >>> (b & 32'h000F);
            end
            ALU_OP_A: begin
                y = a;
            end
            ALU_OP_B: begin
                y = b;
            end
            ALU_OP_SLT: begin
                y = {31'b0, ($signed(a) < $signed(b))};
            end
            ALU_OP_SLTU: begin
                y = {31'b0, (a<b)};
            end
            ALU_OP_SBCLR: begin
                y = a & ~(32'b1 << b[4:0]);
            end
            ALU_OP_SBSET: begin
                y = a | (32'b1 << b[4:0]);
            end
            ALU_OP_CLZ: begin
                y = ((a == 0) ? 32'd32 : {27'b0, clz_result});
                // y = clz_result;
            end
            ALU_OP_CRAS16: begin
                // y[31:16] = %lo16(a[31:16] + b[15:0]);
                // y[15:0] = %lo16(a[15:0] - b[31:16]);
                y[31:16] = (a[31:16] + b[15:0]);// & 16'hFFFF;
                y[15:0] = (a[15:0] - b[31:16]);// & 16'hFFFF;
            end
        endcase
    end

    // always_comb begin
    //     for (int i = 31; i >= 0; i = i - 1) begin
    //         if (a[i] == 1'b1) begin
    //             clz_result = 32'd31 - i;
    //             break;
    //         end
    //     end
    // end
    
    logic [31:0] clz_sel [4:0];
    clz_decoder #(
      .DATA_WIDTH(32)
    ) u_clz_decoder_0(
        .data(a),
        .sel(clz_result[4]),
        .data_sel(clz_sel[4])
    );

    genvar m;
    generate
        for (m = 4; m >= 1; m = m - 1)
        begin: generate_decoder
            clz_decoder #(
                .DATA_WIDTH(1 << m)
            )  u_clz_decoder(
                .data(clz_sel[m]),
                .sel(clz_result[m-1]),
                .data_sel(clz_sel[m-1])
            );
        end
    endgenerate




endmodule