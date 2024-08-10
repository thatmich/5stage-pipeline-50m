`include "../constants.svh"
`timescale 1ns / 1ps
`default_nettype none
module control (
    input wire [`ADDR_WIDTH-1:0] pc,
    input wire [`INST_WIDTH-1:0] inst,

    // alu
    output reg alu_a_pc, // whether to use pc or reg for operand a
    output reg alu_b_imm, // whether to use imm or reg for operand b
    output reg [`ALU_OP_WIDTH-1:0] alu_op,
    // wishbone
    output reg wb_mem_en, // whether to use the memory
    output reg wb_wen,
    output reg [3:0] wb_sel,
    output reg wb_read_signed, // for data less than 4 bytes, whether it will sign extend
    // regfile
    output reg rf_wen,
    output reg rf_wb_from_mem // the data to be written to rd is from mem and not alu
);

    // generate the control signals during instruction decode

    reg [6:0] opcode;
    reg [2:0] func3;
    reg [6:0] func7;

    assign opcode = inst[6:0];
    assign func3 = inst[14:12];
    assign func7 = inst[31:25];

    // alu signals
    always_comb begin
        if (opcode == `OPCODE_JAL || opcode == `OPCODE_JALR || opcode == `OPCODE_AUIPC || opcode == `OPCODE_B_TYPE) begin
            alu_a_pc = 1;
        end else begin
            alu_a_pc = 0;
        end

        if (opcode == `OPCODE_R_TYPE || opcode == 7'b1110111) begin
            alu_b_imm = 0;
        end else begin
            alu_b_imm = 1;
        end

        if (opcode == `OPCODE_I_TYPE) begin
            case (func3)
                3'b000: begin
                    alu_op = ALU_OP_ADD;
                end
                3'b001: begin
                    if (func7 == 7'b0110000) begin
                        alu_op = ALU_OP_CLZ;
                    end else begin
                        alu_op = ALU_OP_SLL;
                    end
                end
                3'b010: begin
                    alu_op = ALU_OP_SLT;
                end
                3'b011: begin
                    alu_op = ALU_OP_SLTU;
                end
                3'b100: begin
                    alu_op = ALU_OP_XOR;
                end
                3'b101: begin
                    if (func7 == 7'b0100000) begin
                        alu_op = ALU_OP_SRA;
                    end else begin
                        alu_op = ALU_OP_SRL;
                    end
                end
                3'b110: begin
                    alu_op = ALU_OP_OR;
                end
                3'b111: begin
                    alu_op = ALU_OP_AND;
                end
                default: begin
                    alu_op = ALU_OP_NOP;
                end
            endcase
        end else if (opcode == `OPCODE_R_TYPE) begin
            case (func3)
                3'b000: begin
                    if (func7 == 7'b0000000) begin
                        alu_op = ALU_OP_ADD;
                    end else begin
                        alu_op = ALU_OP_SUB;
                    end
                end
                3'b001: begin
                    if (func7 == 7'b0100100) begin // SBCLR
                        alu_op = ALU_OP_SBCLR;
                    end else if (func7 == 7'b0010100) begin // SBSET
                        alu_op = ALU_OP_SBSET;
                    end else begin
                        alu_op = ALU_OP_SLL;
                    end
                end
                3'b010: begin
                    alu_op = ALU_OP_SLT;
                end
                3'b011: begin
                    alu_op = ALU_OP_SLTU;
                end
                3'b100: begin
                    alu_op = ALU_OP_XOR;
                end
                3'b101: begin
                    if (func7 == 7'b0100000) begin
                        alu_op = ALU_OP_SRA;
                    end else begin
                        alu_op = ALU_OP_SRL;
                    end
                end
                3'b110: begin
                    alu_op = ALU_OP_OR;
                end
                3'b111: begin
                    alu_op = ALU_OP_AND;
                end
                default: begin
                    alu_op = ALU_OP_NOP;
                end
            endcase
        end else if (opcode == `OPCODE_LUI) begin
            alu_op = ALU_OP_B;
        end else if (opcode == `OPCODE_JAL || opcode == `OPCODE_JALR) begin
            alu_op = ALU_OP_ADD; // TODO: how to implement + 4. remember to set operand b to 4
        end else if (opcode == 7'b1110111) begin
            if (func3 == 3'b000 && func7 == 7'b0100010) begin
                alu_op = ALU_OP_CRAS16;
            end
        end else begin // including b-type
            alu_op = ALU_OP_ADD;
        end
    end

    // wishbone signals
    always_comb begin
        if (opcode == `OPCODE_S_TYPE) begin
            wb_wen = 1;
            wb_mem_en = 1;
        end else if (opcode == `OPCODE_L) begin
            wb_wen = 0;
            wb_mem_en = 1;
        end else begin
            wb_wen = 0;
            wb_mem_en = 0;
        end

        case (func3)
            3'b000: begin wb_sel = 4'b0001; wb_read_signed = 1; end // b
            3'b001: begin wb_sel = 4'b0011; wb_read_signed = 1; end // h
            3'b010: begin wb_sel = 4'b1111; wb_read_signed = 1; end // w
            3'b100: begin wb_sel = 4'b0001; wb_read_signed = 0; end // bu (unsigned)
            3'b101: begin wb_sel = 4'b0011; wb_read_signed = 0; end // hu (unsigned)
            default: begin wb_sel = 4'b0000; wb_read_signed = 0; end
        endcase
    end

    // rf signals
    always_comb begin
        if (opcode == `OPCODE_S_TYPE || opcode == `OPCODE_B_TYPE) begin
            rf_wen = 0;
        end else begin
            rf_wen = 1;
        end

        if (opcode == `OPCODE_L) begin
            rf_wb_from_mem = 1;
        end
        else begin
            rf_wb_from_mem = 0;
        end
    end
endmodule