`include "../constants.svh"
`timescale 1ns / 1ps
`default_nettype none
module branch_comp (
    input wire [`INST_WIDTH-1:0] inst,
    input wire [`DATA_WIDTH-1:0] a,
    input wire [`DATA_WIDTH-1:0] b,
    input wire [`ADDR_WIDTH-1:0] pc,
    input wire [`DATA_WIDTH-1:0] imm,
    output reg branch,
    output reg [`INST_WIDTH-1:0] target_branch
);

always_comb begin
    if (inst[6:0] == `OPCODE_B_TYPE) begin
        case (inst[14:12])
            3'b000: begin // beq
                branch = (a == b);
            end
            3'b001: begin // bne
                branch = (a != b);
            end
            3'b100: begin // blt
                branch = ($signed(a) < $signed(b));
            end
            3'b101: begin // bgt
                branch = ($signed(a) > $signed(b));
            end
            3'b110: begin // bltu
                branch = (a < b);
            end
            3'b111: begin // bgeu
                branch = (a >= b);
            end
            default: begin
                branch = 0;
            end
        endcase
    end else if(inst[6:0] == `OPCODE_JAL || inst[6:0] == `OPCODE_JALR) begin
        branch = 1;
    end else begin
        branch = 0;
    end


    if (inst[6:0] == `OPCODE_JALR) begin
        target_branch = (a + imm) & 32'hfffffffe;
    end else begin
        target_branch = pc + imm;
    end
end
endmodule