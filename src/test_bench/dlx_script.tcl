# Start simulation
vsim -t 10ps work.dlx_tb(testbench)

################################## DLX ##################################
add wave -label CLK -radix binary sim:/dlx_tb/uut/clk
add wave -label RST -radix binary sim:/dlx_tb/uut/clk
add wave -label EN -radix binary sim:/dlx_tb/s_en

################################## CONTROL UNIT ##################################
add wave -group Control -label INSTRUCTION -radix hex sim:/dlx_tb/uut/cu/ir_data_in
add wave -group Control -label OPCODE -radix hex sim:/dlx_tb/uut/cu/ir_opcode
add wave -group Control -label FUNCTION -radix hex sim:/dlx_tb/uut/cu/ir_func
add wave -group Control -label IR_LATCH_EN -radix binary sim:/dlx_tb/uut/cu/IR_LATCH_EN
add wave -group Control -label NPC_LATCH_EN -radix binary sim:/dlx_tb/uut/cu/NPC_LATCH_EN
add wave -group Control -label RF_LATCH_EN -radix binary sim:/dlx_tb/uut/cu/RF_LATCH_EN 
add wave -group Control -label RegA_LATCH_EN -radix binary sim:/dlx_tb/uut/cu/RegA_LATCH_EN
add wave -group Control -label RegB_LATCH_EN -radix binary sim:/dlx_tb/uut/cu/RegB_LATCH_EN
add wave -group Control -label RegIMM_LATCH_EN -radix binary sim:/dlx_tb/uut/cu/RegIMM_LATCH_EN
add wave -group Control -label MUXA_SEL -radix binary sim:/dlx_tb/uut/cu/MUXA_SEL
add wave -group Control -label MUXB_SEL -radix binary sim:/dlx_tb/uut/cu/MUXB_SEL
add wave -group Control -label ALU_OUTREG_EN -radix binary sim:/dlx_tb/uut/cu/ALU_OUTREG_EN
add wave -group Control -label EQ_COND -radix binary sim:/dlx_tb/uut/cu/EQ_COND
add wave -group Control -label DRAM_RW -radix binary sim:/dlx_tb/uut/cu/DRAM_RW
add wave -group Control -label LMD_LATCH_EN -radix binary sim:/dlx_tb/uut/cu/LMD_LATCH_EN
add wave -group Control -label JUMP_EN -radix binary sim:/dlx_tb/uut/cu/JUMP_EN
add wave -group Control -label PC_LATCH_EN -radix binary sim:/dlx_tb/uut/cu/PC_LATCH_EN
add wave -group Control -label WB_MUX_SEL -radix binary sim:/dlx_tb/uut/cu/WB_MUX_SEL
add wave -group Control -label RF_WE -radix binary sim:/dlx_tb/uut/cu/RF_WE
add wave -group Control -label ALU_OPCODE -radix symbolic sim:/dlx_tb/uut/cu/ALU_OPCODE

################################## Stage 1 ##################################
# Control word
add wave -color gold -group Pipe1 -label CW1 -radix binary sim:/dlx_tb/uut/cu/cw1
# Program Counter
add wave -group Pipe1 -label PC_EN -radix binary sim:/dlx_tb/uut/dp/pc/en
add wave -group Pipe1 -label PC_DIN -radix hex sim:/dlx_tb/uut/dp/pc/din
add wave -group Pipe1 -label PC_DOUT -radix hex sim:/dlx_tb/uut/dp/pc/dout
# IRAM
add wave -group Pipe1 -label IRAM_EN -radix binary sim:/dlx_tb/iram/en
add wave -group Pipe1 -label IRAM_ADDR -radix unsigned sim:/dlx_tb/iram/addr
add wave -group Pipe1 -label IRAM_DATA -radix hex sim:/dlx_tb/iram/data
add wave -group Pipe1 -label IRAM_MEM -radix hex sim:/dlx_tb/iram/memory
# Instruction Register
add wave -group Pipe1 -label IR_EN -radix binary sim:/dlx_tb/uut/dp/ir/en
add wave -group Pipe1 -label IR_DIN -radix hex sim:/dlx_tb/uut/dp/ir/din
add wave -group Pipe1 -label IR_DOUT -radix hex sim:/dlx_tb/uut/dp/ir/dout
# Next Program Counter
add wave -group Pipe1 -label NPC_EN -radix binary sim:/dlx_tb/uut/dp/npc/en
add wave -group Pipe1 -label NPC_DIN -radix hex sim:/dlx_tb/uut/dp/npc/din
add wave -group Pipe1 -label NPC_DOUT -radix hex sim:/dlx_tb/uut/dp/npc/dout

################################## Stage 2 ##################################
# Control word
add wave -color gold -group Pipe2 -label CW2 -radix binary sim:/dlx_tb/uut/cu/cw2
# Register File
add wave -group Pipe2 -label RF_EN -radix binary sim:/dlx_tb/uut/dp/rf/en
add wave -group Pipe2 -label RF_RD1 -radix binary sim:/dlx_tb/uut/dp/rf/rd1
add wave -group Pipe2 -label RF_RD2 -radix binary sim:/dlx_tb/uut/dp/rf/rd2
add wave -group Pipe2 -label RF_ADDR1 -radix unsigned sim:/dlx_tb/uut/dp/rf/add_rd1
add wave -group Pipe2 -label RF_ADDR2 -radix unsigned sim:/dlx_tb/uut/dp/rf/add_rd2
add wave -group Pipe2 -label RF_OUT1 -radix hex sim:/dlx_tb/uut/dp/rf/out1
add wave -group Pipe2 -label RF_OUT2 -radix hex sim:/dlx_tb/uut/dp/rf/out2
add wave -group Pipe2 -label RF_WR -radix binary sim:/dlx_tb/uut/dp/rf/wr
add wave -group Pipe2 -label RF_ADDR_WR -radix unsigned sim:/dlx_tb/uut/dp/rf/add_wr
add wave -group Pipe2 -label RF_IN -radix hex sim:/dlx_tb/uut/dp/rf/datain
add wave -group Pipe2 -label RF_REG -radix hex sim:/dlx_tb/uut/dp/rf/registers
# Register A
add wave -group Pipe2 -label REG_A_EN -radix binary sim:/dlx_tb/uut/dp/reg_a/en
add wave -group Pipe2 -label REG_A_DIN -radix hex sim:/dlx_tb/uut/dp/reg_a/din
add wave -group Pipe2 -label REG_A_DOUT -radix hex sim:/dlx_tb/uut/dp/reg_a/dout
# Register B
add wave -group Pipe2 -label REG_B_EN -radix binary sim:/dlx_tb/uut/dp/reg_b/en
add wave -group Pipe2 -label REG_B_DIN -radix hex sim:/dlx_tb/uut/dp/reg_b/din
add wave -group Pipe2 -label REG_B_DOUT -radix hex sim:/dlx_tb/uut/dp/reg_b/dout
# Sign extend
add wave -group Pipe2 -label IMMU -radix hex sim:/dlx_tb/uut/dp/w_immu
add wave -group Pipe2 -label IMMS -radix hex sim:/dlx_tb/uut/dp/w_imms
# Register IMM
add wave -group Pipe2 -label REG_IMM_EN -radix binary sim:/dlx_tb/uut/dp/imm/en
add wave -group Pipe2 -label REG_IMM_DIN -radix hex sim:/dlx_tb/uut/dp/imm/din
add wave -group Pipe2 -label REG_IMM_DOUT -radix hex sim:/dlx_tb/uut/dp/imm/dout

################################## Stage 3 ##################################
# Control word
add wave -color gold -group Pipe3 -label CW3 -radix binary sim:/dlx_tb/uut/cu/cw3
# Mux A
add wave -group Pipe3 -label MUX_A_S0 -radix hex sim:/dlx_tb/uut/dp/mux_a/s0
add wave -group Pipe3 -label MUX_A_S1 -radix hex sim:/dlx_tb/uut/dp/mux_a/s1
add wave -group Pipe3 -label MUX_A_SEL -radix binary sim:/dlx_tb/uut/dp/mux_a/sel
add wave -group Pipe3 -label MUX_A_OUT -radix hex sim:/dlx_tb/uut/dp/mux_a/y
# Mux B
add wave -group Pipe3 -label MUX_B_S0 -radix hex sim:/dlx_tb/uut/dp/mux_b/s0
add wave -group Pipe3 -label MUX_B_S1 -radix hex sim:/dlx_tb/uut/dp/mux_b/s1
add wave -group Pipe3 -label MUX_B_SEL -radix binary sim:/dlx_tb/uut/dp/mux_b/sel
add wave -group Pipe3 -label MUX_B_OUT -radix hex sim:/dlx_tb/uut/dp/mux_b/y
# ALU
add wave -group Pipe3 -label ALU_A -radix hex sim:/dlx_tb/uut/dp/alu1/a
add wave -group Pipe3 -label ALU_B -radix hex sim:/dlx_tb/uut/dp/alu1/b
add wave -group Pipe3 -label ALU_OP -radix symbolic sim:/dlx_tb/uut/dp/alu1/op
add wave -group Pipe3 -label ALU_OUT -radix hex sim:/dlx_tb/uut/dp/alu1/y
# ALU Register
add wave -group Pipe3 -label REG_ALU_EN -radix binary sim:/dlx_tb/uut/dp/alu_reg/en
add wave -group Pipe3 -label REG_ALU_DIN -radix hex sim:/dlx_tb/uut/dp/alu_reg/din
add wave -group Pipe3 -label REG_ALU_DOUT -radix hex sim:/dlx_tb/uut/dp/alu_reg/dout
# Zero Detector
add wave -group Pipe3 -label ZERO_A -radix unsigned sim:/dlx_tb/uut/dp/cond/a
add wave -group Pipe3 -label ZERO_Z -radix unsigned sim:/dlx_tb/uut/dp/cond/y
# Branch Condition
add wave -group Pipe3 -label COND -radix binary sim:/dlx_tb/uut/dp/w_cmp_out

################################## Stage 4 ##################################
# Control word
add wave -color gold -group Pipe4 -label CW4 -radix binary sim:/dlx_tb/uut/cu/cw4
# DRAM
add wave -group Pipe4 -label DRAM_EN -radix binary sim:/dlx_tb/dram/en
add wave -group Pipe4 -label DRAM_RW -radix binary sim:/dlx_tb/dram/rw
add wave -group Pipe4 -label DRAM_ADDR -radix unsigned sim:/dlx_tb/dram/addr
add wave -group Pipe4 -label DRAM_DIN -radix hex sim:/dlx_tb/dram/din
add wave -group Pipe4 -label DRAM_DOUT -radix hex sim:/dlx_tb/dram/dout
add wave -group Pipe4 -label DRAM_MEM -radix hex sim:/dlx_tb/dram/memory
# LMD Register
add wave -group Pipe4 -label LMD_EN -radix binary sim:/dlx_tb/uut/dp/lmd/en
add wave -group Pipe4 -label LMD_DIN -radix hex sim:/dlx_tb/uut/dp/lmd/din
add wave -group Pipe4 -label LMD_DOUT -radix hex sim:/dlx_tb/uut/dp/lmd/dout
# Mux Memory Access
add wave -group Pipe4 -label MUX_MEM_S0 -radix hex sim:/dlx_tb/uut/dp/mux_mem/s0
add wave -group Pipe4 -label MUX_MEM_S1 -radix hex sim:/dlx_tb/uut/dp/mux_mem/s1
add wave -group Pipe4 -label MUX_MEM_SEL -radix binary sim:/dlx_tb/uut/dp/mux_mem/sel
add wave -group Pipe4 -label MUX_MEM_OUT -radix hex sim:/dlx_tb/uut/dp/mux_mem/y

################################## Stage 5 ##################################
# Control word
add wave -color gold -group Pipe5 -label CW5 -radix binary sim:/dlx_tb/uut/cu/cw5
# Mux Memory Access
add wave -group Pipe5 -label MUX_WB_S0 -radix hex sim:/dlx_tb/uut/dp/mux_wb/s0
add wave -group Pipe5 -label MUX_WB_S1 -radix hex sim:/dlx_tb/uut/dp/mux_wb/s1
add wave -group Pipe5 -label MUX_WB_SEL -radix binary sim:/dlx_tb/uut/dp/mux_wb/sel
add wave -group Pipe5 -label MUX_WB_OUT -radix hex sim:/dlx_tb/uut/dp/mux_wb/y

# Set unsigned as DEFAULT radix
radix -unsigned
# Run simulation
run 160 ns
# Print postscript waveform
#write wave p4adder.ps -start 0 -end 230000 -perpage 230000
