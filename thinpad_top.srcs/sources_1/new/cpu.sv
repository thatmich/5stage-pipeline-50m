`include "constants.svh"
`timescale 1ns / 1ps
`default_nettype none
module cpu (
    input wire clk_i,
    input wire rst_i,

    output reg wbm0_cyc_o,
    output reg wbm0_stb_o,
    input wire wbm0_ack_i,
    output reg [`ADDR_WIDTH-1:0] wbm0_adr_o,
    output reg [`DATA_WIDTH-1:0] wbm0_dat_o,
    input wire [`DATA_WIDTH-1:0] wbm0_dat_i,
    output reg [3:0] wbm0_sel_o,
    output reg wbm0_we_o,

    output reg wbm1_cyc_o,
    output reg wbm1_stb_o,
    input wire wbm1_ack_i,
    output reg [`ADDR_WIDTH-1:0] wbm1_adr_o,
    output reg [`DATA_WIDTH-1:0] wbm1_dat_o,
    input wire [`DATA_WIDTH-1:0] wbm1_dat_i,
    output reg [3:0] wbm1_sel_o,
    output reg wbm1_we_o
);

    // signals
    logic stall;
    logic if_master_stall;
    logic mem_master_stall;
    assign stall = if_master_stall | mem_master_stall;

    logic branch;
    logic [`ADDR_WIDTH-1:0] target_branch;
 
    logic if_id_hold;
    logic id_ex_hold;
    logic if_id_flush;
    logic id_ex_flush;
    logic ex_mem_flush;
    logic mem_wb_flush;


    // signals for the stages
    // if signals
    logic [`ADDR_WIDTH-1:0] if_pc;
    logic [`INST_WIDTH-1:0] if_inst;

    // id signals
    logic [`ADDR_WIDTH-1:0] id_pc;
    logic [`INST_WIDTH-1:0] id_inst;

    logic [`DATA_WIDTH-1:0] id_rf_data_a;
    logic [`DATA_WIDTH-1:0] id_rf_data_b;
    logic id_rf_wen;
    logic [`REG_ADDR_WIDTH-1:0] id_rf_waddr;
    logic id_rf_wb_from_mem;

    logic [`ALU_OP_WIDTH-1:0] id_alu_op;
    logic id_alu_a_pc;
    logic id_alu_b_imm;

    logic id_wb_mem_en;
    logic id_wb_wen;
    logic [3:0] id_wb_sel;
    logic id_wb_read_signed;

    logic [`REG_ADDR_WIDTH-1:0] id_rs1;
    logic [`REG_ADDR_WIDTH-1:0] id_rs2;
    logic [`DATA_WIDTH-1:0] id_imm;

    // ex signals
    logic [`ADDR_WIDTH-1:0] ex_pc;
    logic [`INST_WIDTH-1:0] ex_inst;
    logic [`DATA_WIDTH-1:0] ex_rf_data_a;
    logic [`DATA_WIDTH-1:0] ex_rf_data_b;
    logic [`ALU_OP_WIDTH-1:0] ex_alu_op;
    logic ex_alu_a_pc;
    logic ex_alu_b_imm;
    logic [`DATA_WIDTH-1:0] ex_imm;
    logic [`REG_ADDR_WIDTH-1:0] ex_rs1;
    logic [`REG_ADDR_WIDTH-1:0] ex_rs2;

    logic [`DATA_WIDTH-1:0] ex_alu_result;
    logic ex_wb_wen;
    logic ex_wb_mem_en;
    logic [3:0] ex_wb_sel;
    logic ex_wb_read_signed;
    logic ex_rf_wen;
    logic [`REG_ADDR_WIDTH-1:0] ex_rf_waddr;
    logic ex_rf_wb_from_mem;

    logic [`DATA_WIDTH-1:0] ex_alu_a;
    logic [`DATA_WIDTH-1:0] ex_alu_b;

    logic [1:0] ex_alu_sel_a;
    logic [1:0] ex_alu_sel_b;

    // mem signals
    logic [`ADDR_WIDTH-1:0] mem_pc;
    logic [`INST_WIDTH-1:0] mem_inst;
    logic [`ADDR_WIDTH-1:0] mem_wb_addr;
    logic [`DATA_WIDTH-1:0] mem_wb_data;
    logic mem_wb_wen;
    logic mem_wb_mem_en;
    logic [`DATA_WIDTH/8-1:0] mem_wb_sel;
    logic mem_wb_read_signed;
    logic [`DATA_WIDTH-1:0] mem_read_data;

    logic mem_rf_wen;
    logic [`REG_ADDR_WIDTH-1:0] mem_rf_waddr;
    logic [`DATA_WIDTH-1:0] mem_rf_wdata;
    logic mem_rf_wb_from_mem;

    // wb signals
    logic wb_rf_wen;
    logic [`REG_ADDR_WIDTH-1:0] wb_rf_waddr;
    logic [`DATA_WIDTH-1:0] wb_rf_wdata;

    logic [`DATA_WIDTH-1:0] forwarded_rf_data_a;
    logic [`DATA_WIDTH-1:0] forwarded_rf_data_b;

    // if stage components
    if_master u_if_master (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .stall_i(stall),
        .hold_i(if_id_hold),
        .branch_i(branch),
        .branch_target_i(target_branch),
        .wb_ack_i(wbm0_ack_i),
        .wb_dat_i(wbm0_dat_i),
        .wb_cyc_o(wbm0_cyc_o),
        .wb_stb_o(wbm0_stb_o),
        .wb_adr_o(wbm0_adr_o),
        .wb_dat_o(wbm0_dat_o),
        .wb_sel_o(wbm0_sel_o),
        .wb_we_o(wbm0_we_o),
        .inst_o(if_inst),
        .pc_o(if_pc),
        .if_master_stall_o(if_master_stall)
    );


    if_id u_if_id (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .stall_i(stall),
        .flush_i(if_id_flush),
        .hold_i(if_id_hold),
        .pc_i(if_pc),
        .inst_i(if_inst),
        .pc_o(id_pc),
        .inst_o(id_inst)
    );

    // id stage components
    regfile u_regfile (
        .clk(clk_i),
        .rst(rst_i),
        .waddr(wb_rf_waddr),
        .wdata(wb_rf_wdata),
        .wen(wb_rf_wen),
        .raddr_a(id_inst[19:15]),
        .rdata_a(id_rf_data_a),
        .raddr_b(id_inst[24:20]),
        .rdata_b(id_rf_data_b)
    );

    imm_gen u_imm_gen (
        .inst(id_inst),
        .imm(id_imm)
    );

    control u_control (
        .pc(id_pc),
        .inst(id_inst),
        .alu_a_pc(id_alu_a_pc),
        .alu_b_imm(id_alu_b_imm),
        .alu_op(id_alu_op),
        .wb_mem_en(id_wb_mem_en),
        .wb_wen(id_wb_wen),
        .wb_sel(id_wb_sel),
        .wb_read_signed(id_wb_read_signed),
        .rf_wen(id_rf_wen),
        .rf_wb_from_mem(id_rf_wb_from_mem)
    );

    assign id_rf_waddr = id_inst[11:7];
    assign id_rs1 = id_inst[19:15];
    assign id_rs2 = id_inst[24:20];

    id_ex u_id_ex (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .stall_i(stall),
        .flush_i(id_ex_flush),
        .hold_i(id_ex_hold),
        .id_pc_i(id_pc),
        .id_inst_i(id_inst),
        .id_rf_data_a_i(id_rf_data_a),
        .id_rf_data_b_i(id_rf_data_b),
        .id_rf_wen_i(id_rf_wen),
        .id_rf_waddr_i(id_rf_waddr),
        .id_rf_wb_from_mem_i(id_rf_wb_from_mem),
        .id_alu_op_i(id_alu_op),
        .id_alu_a_pc_i(id_alu_a_pc),
        .id_alu_b_imm_i(id_alu_b_imm),
        .id_wb_mem_en_i(id_wb_mem_en),
        .id_wb_wen_i(id_wb_wen),
        .id_wb_sel_i(id_wb_sel),
        .id_wb_read_signed_i(id_wb_read_signed),
        .id_rs1_i(id_rs1),
        .id_rs2_i(id_rs2),
        .id_imm_i(id_imm),
        .ex_pc_o(ex_pc),
        .ex_inst_o(ex_inst),
        .ex_rf_data_a_o(ex_rf_data_a),
        .ex_rf_data_b_o(ex_rf_data_b),
        .ex_rf_wen_o(ex_rf_wen),
        .ex_rf_waddr_o(ex_rf_waddr),
        .ex_rf_wb_from_mem_o(ex_rf_wb_from_mem),
        .ex_alu_op_o(ex_alu_op),
        .ex_alu_a_pc_o(ex_alu_a_pc),
        .ex_alu_b_imm_o(ex_alu_b_imm),
        .ex_wb_mem_en_o(ex_wb_mem_en),
        .ex_wb_wen_o(ex_wb_wen),
        .ex_wb_sel_o(ex_wb_sel),
        .ex_wb_read_signed_o(ex_wb_read_signed),
        .ex_rs1_o(ex_rs1),
        .ex_rs2_o(ex_rs2),
        .ex_imm_o(ex_imm)
    );


    // ex stage components

    always_comb begin
        case (ex_alu_sel_a)
            ALU_SEL_NOP: forwarded_rf_data_a = 0;
            ALU_SEL_EX:  forwarded_rf_data_a = ex_rf_data_a; 
            ALU_SEL_MEM: forwarded_rf_data_a = mem_rf_wdata;  
            ALU_SEL_WB:  forwarded_rf_data_a = wb_rf_wdata;
        endcase        
    end

    always_comb begin
        case (ex_alu_sel_b)
            ALU_SEL_NOP: forwarded_rf_data_b = 0;
            ALU_SEL_EX:  forwarded_rf_data_b = ex_rf_data_b; 
            ALU_SEL_MEM: forwarded_rf_data_b = mem_rf_wdata;  
            ALU_SEL_WB:  forwarded_rf_data_b = wb_rf_wdata;
        endcase
    end

    always_comb begin
        ex_alu_a = ex_alu_a_pc ? ex_pc : forwarded_rf_data_a;

        if (ex_inst[6:0] == `OPCODE_JAL || ex_inst[6:0] == `OPCODE_JALR) begin
            ex_alu_b = 4;
        end else begin
            ex_alu_b = ex_alu_b_imm ? ex_imm : forwarded_rf_data_b;
        end
    end

    alu u_alu (
        .a(ex_alu_a),
        .b(ex_alu_b),
        .op(ex_alu_op),
        .y(ex_alu_result)
    );

    branch_comp u_branch_comp (
        .inst(ex_inst),
        .a(forwarded_rf_data_a),
        .b(forwarded_rf_data_b),
        .pc(ex_pc),
        .imm(ex_imm),
        .branch(branch),
        .target_branch(target_branch)
    );

    forward_unit u_forward_unit (
        .ex_rs1(ex_rs1),
        .ex_rs2(ex_rs2),
        .mem_rd(mem_rf_waddr),
        .mem_rf_wen(mem_rf_wen),
        .wb_rd(wb_rf_waddr),
        .wb_rf_wen(wb_rf_wen),
        .alu_sel_a(ex_alu_sel_a),
        .alu_sel_b(ex_alu_sel_b)
    );


    ex_mem u_ex_mem (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .stall_i(stall),
        .flush_i(ex_mem_flush),
        .ex_pc_i(ex_pc),
        .ex_inst_i(ex_inst),
        .ex_wb_adr_i(ex_alu_result), // calculated address from alu
        .ex_wb_dat_i(forwarded_rf_data_b), // rs2
        .ex_wb_wen_i(ex_wb_wen),
        .ex_wb_mem_en_i(ex_wb_mem_en),
        .ex_wb_sel_i(ex_wb_sel),
        .ex_wb_read_signed_i(ex_wb_read_signed),
        .ex_rf_wen_i(ex_rf_wen),
        .ex_rf_waddr_i(ex_rf_waddr),
        // .ex_rf_wdata_i(ex_alu_result),
        .ex_rf_wb_from_mem_i(ex_rf_wb_from_mem),
        .mem_pc_o(mem_pc),
        .mem_inst_o(mem_inst),
        .mem_wb_adr_o(mem_wb_addr),
        .mem_wb_dat_o(mem_wb_data),
        .mem_wb_wen_o(mem_wb_wen),
        .mem_wb_mem_en_o(mem_wb_mem_en),
        .mem_wb_sel_o(mem_wb_sel),
        .mem_wb_read_signed_o(mem_wb_read_signed),
        .mem_rf_wen_o(mem_rf_wen), // rf signals are passed to wb
        .mem_rf_waddr_o(mem_rf_waddr),
        // .mem_rf_wdata_o(mem_rf_wdata),
        .mem_rf_wb_from_mem_o(mem_rf_wb_from_mem)
    );

    // mem stage components
    mem_master u_mem_master (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .addr_i(mem_wb_addr),
        .data_i(mem_wb_data),
        .mem_en_i(mem_wb_mem_en),
        .wen_i(mem_wb_wen),
        .sel_i(mem_wb_sel),
        .stall_i(stall),
        .read_signed_i(mem_wb_read_signed),
        .mem_read_data_o(mem_read_data),
        .mem_master_stall_o(mem_master_stall),
        .wb_cyc_o(wbm1_cyc_o),
        .wb_stb_o(wbm1_stb_o),
        .wb_adr_o(wbm1_adr_o),
        .wb_dat_o(wbm1_dat_o),
        .wb_sel_o(wbm1_sel_o),
        .wb_we_o(wbm1_we_o),
        .wb_ack_i(wbm1_ack_i),
        .wb_dat_i(wbm1_dat_i)
    );

    assign mem_rf_wdata = mem_rf_wb_from_mem ? mem_read_data : mem_wb_addr;

    mem_wb u_mem_wb (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .stall_i(stall),
        .flush_i(mem_wb_flush),
        .rf_wen_i(mem_rf_wen),
        .rf_waddr_i(mem_rf_waddr),
        .rf_wdata_i(mem_rf_wdata),
        .rf_wen_o(wb_rf_wen),
        .rf_waddr_o(wb_rf_waddr),
        .rf_wdata_o(wb_rf_wdata)
    );

    hazard_detection_unit u_hazard_detection_unit (
        .id_inst(id_inst),
        .ex_rf_wen(ex_rf_wen),
        .ex_rf_waddr(ex_rf_waddr),
        .branch(branch),
        .if_id_hold(if_id_hold),
        .id_ex_hold(id_ex_hold),
        .if_id_flush(if_id_flush),
        .id_ex_flush(id_ex_flush),
        .ex_mem_flush(ex_mem_flush),
        .mem_wb_flush(mem_wb_flush)
    );
    

endmodule