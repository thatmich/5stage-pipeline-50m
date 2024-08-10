`include "../constants.svh"
`timescale 1ns / 1ps
`default_nettype none
module imm_gen (
    input wire [`INST_WIDTH-1:0] inst,
    output reg [`DATA_WIDTH-1:0] imm
);
    // return the immediate according to the instruction type
    always_comb begin
        case(inst[6:0])
            `OPCODE_LUI, `OPCODE_AUIPC: imm = {inst[31:12], 12'b0}; // u-type
            `OPCODE_B_TYPE: imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0}; // b-type
            `OPCODE_I_TYPE, `OPCODE_L, `OPCODE_JALR: imm = {{20{inst[31]}}, inst[31:20]}; // i-type, l, jalr
            `OPCODE_S_TYPE: imm = {{20{inst[31]}}, inst[31:25], inst[11:7]}; // s-type
            `OPCODE_JAL: imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0}; // jal
            default: imm = 32'd0;
        endcase
    end
endmodule