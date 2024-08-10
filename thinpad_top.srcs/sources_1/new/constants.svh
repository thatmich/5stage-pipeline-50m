`ifndef _CONSTANTS_SVH_
`define _CONSTANTS_SVH_

// WIDTH
`define ADDR_WIDTH 32 // address width
`define DATA_WIDTH 32 // data width
`define INST_WIDTH 32 // instruction width


`define REG_NUM 32 // number of registers
`define REG_ADDR_WIDTH 5

`define ALU_OP_WIDTH 5
typedef enum logic [4:0] {
    ALU_OP_NOP   = 5'b00000,
    ALU_OP_ADD   = 5'b00001,
    ALU_OP_SUB   = 5'b00010,
    ALU_OP_AND   = 5'b00011,
    ALU_OP_OR    = 5'b00100,
    ALU_OP_XOR   = 5'b00101,
    ALU_OP_SLL   = 5'b00110,
    ALU_OP_SRL   = 5'b00111,
    ALU_OP_SRA   = 5'b01000,
    ALU_OP_B     = 5'b01001, // select b directly
    ALU_OP_SLT   = 5'b01010,
    ALU_OP_SLTU  = 5'b01011,
    ALU_OP_SBCLR = 5'b01110, // TODO: single bit clear
    ALU_OP_CLZ   = 5'b01111, // TODO: Count leading zeros
    ALU_OP_SBSET = 5'b10000, // TODO: single bit set
    ALU_OP_NOT   = 5'b10001,
    ALU_OP_A     = 5'b10010, // select a directly
    ALU_OP_CRAS16 = 5'b10011 // TODO: CRAS16
} alu_op_t;

typedef enum logic [1:0] {
    ALU_SEL_NOP = 2'b00,
    ALU_SEL_EX = 2'b01,
    ALU_SEL_MEM = 2'b10,
    ALU_SEL_WB   = 2'b11
} alu_sel_t;

// OPCODE
`define OPCODE_LUI 7'b0110111
`define OPCODE_AUIPC 7'b0010111
`define OPCODE_B_TYPE 7'b1100011
`define OPCODE_I_TYPE 7'b0010011
`define OPCODE_L 7'b0000011
`define OPCODE_JALR 7'b1100111
`define OPCODE_S_TYPE 7'b0100011
`define OPCODE_JAL 7'b1101111
`define OPCODE_R_TYPE 7'b0110011


`define NOP 32'h00000013
`endif