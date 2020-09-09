# Compile
vcom Y:/Microelectronic_Systems/DLX-Project/src/000-globals.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/01-fa.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/01-generic_mux21.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/01-generic_rca.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/01-generic_register.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/01-ivx.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/01-nand2.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.a-adder.core/a.b.a.a.a-pg_network.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.a-adder.core/a.b.a.a.b-g_block.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.a-adder.core/a.b.a.a.c-pg_block.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.a-adder.core/a.b.a.a.d-carry_select_block.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.a-adder.core/a.b.a.a.e-sum_generator.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.a-adder.core/a.b.a.a.f-sparse_tree.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.b-shifter.core/a.b.a.b.a-mask_generator.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.b-shifter.core/a.b.a.b.b-coarse_shift.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.b-shifter.core/a.b.a.b.c-fine_shift.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.c-logic.core/a.b.a.c.a-nand3.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.c-logic.core/a.b.a.c.b-nand4.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.a-adder.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.b-shifter.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.c-logic.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.d-comparator.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.e-zero_detector.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.f-booth_encoder.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.g-multiplier.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/a.b-DataPath.core/a.b.a-ALU.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/a.b-DataPath.core/a.b.b-register_file.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/a.a-CU_HW_v2.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/a.b-DataPath.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/a-DLX.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/b-IRAM.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/c-DRAM.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src/test_bench/TB_DLX.vhd

# Start simulation
vsim -t 10ps work.dlx_tb(testbench)

################################## DLX ##################################
add wave -label CLK -radix binary sim:/dlx_tb/uut/clk
add wave -label RST -radix binary sim:/dlx_tb/uut/rst
add wave -label EN -radix binary sim:/dlx_tb/uut/en
add wave -label IRAM_ADDR -radix hex sim:/dlx_tb/uut/iram_addr
add wave -label IRAM_DATA -radix hex sim:/dlx_tb/uut/iram_data
add wave -label	DRAM_WE -radix hex sim:/dlx_tb/uut/dram_we
add wave -label	DRAM_ADDR -radix hex sim:/dlx_tb/uut/dram_addr
add wave -label	DRAM_DIN  -radix hex sim:/dlx_tb/uut/dram_din
add wave -label	DRAM_DOUT -radix hex sim:/dlx_tb/uut/dram_dout

################################## CONTROL UNIT ##################################
add wave -group Control -label INSTRUCTION -radix hex sim:/dlx_tb/uut/cu/ir_in
add wave -group Control -label OPCODE -radix hex sim:/dlx_tb/uut/cu/ir_opcode
add wave -group Control -label FUNCTION -radix hex sim:/dlx_tb/uut/cu/ir_func
add wave -group Control -label IR_LATCH_EN -radix binary sim:/dlx_tb/uut/cu/IR_LATCH_EN
add wave -group Control -label NPC_LATCH_EN -radix binary sim:/dlx_tb/uut/cu/NPC_LATCH_EN
add wave -group Control -label RegA_LATCH_EN -radix binary sim:/dlx_tb/uut/cu/RegA_LATCH_EN
add wave -group Control -label RegB_LATCH_EN -radix binary sim:/dlx_tb/uut/cu/RegB_LATCH_EN
add wave -group Control -label RegIMM_LATCH_EN -radix binary sim:/dlx_tb/uut/cu/RegIMM_LATCH_EN
add wave -group Control -label MUXA_SEL -radix binary sim:/dlx_tb/uut/cu/MUXA_SEL
add wave -group Control -label MUXB_SEL -radix binary sim:/dlx_tb/uut/cu/MUXB_SEL
add wave -group Control -label ALU_OUTREG_EN -radix binary sim:/dlx_tb/uut/cu/ALU_OUTREG_EN
add wave -group Control -label EQ_COND -radix binary sim:/dlx_tb/uut/cu/EQ_COND
add wave -group Control -label DRAM_RW -radix binary sim:/dlx_tb/uut/cu/DRAM_WE
add wave -group Control -label LMD_LATCH_EN -radix binary sim:/dlx_tb/uut/cu/LMD_LATCH_EN
add wave -group Control -label JUMP_EN -radix binary sim:/dlx_tb/uut/cu/JUMP_EN
add wave -group Control -label PC_LATCH_EN -radix binary sim:/dlx_tb/uut/cu/PC_LATCH_EN
add wave -group Control -label WB_MUX_SEL -radix binary sim:/dlx_tb/uut/cu/WB_MUX_SEL
add wave -group Control -label RF_WE -radix binary sim:/dlx_tb/uut/cu/RF_WE
add wave -group Control -label ALU_OPCODE -radix symbolic sim:/dlx_tb/uut/cu/ALU_OPCODE

################################## Stage 1 ##################################
# Control word
add wave -color gold -group Stage1 -label CW1 -radix binary sim:/dlx_tb/uut/cu/cw1
# Program Counter
add wave -group Stage1 -group PC -label EN -radix binary sim:/dlx_tb/uut/dp/pc/en
add wave -group Stage1 -group PC -label DIN -radix hex sim:/dlx_tb/uut/dp/pc/din
add wave -group Stage1 -group PC -label DOUT -radix hex sim:/dlx_tb/uut/dp/pc/dout
# IRAM
add wave -group Stage1 -group IRAM -label EN -radix binary sim:/dlx_tb/iram/en
add wave -group Stage1 -group IRAM -label ADDR -radix unsigned sim:/dlx_tb/iram/addr
add wave -group Stage1 -group IRAM -label DATA -radix hex sim:/dlx_tb/iram/data
add wave -group Stage1 -group IRAM -label MEM -radix hex sim:/dlx_tb/iram/memory
# Instruction Register
add wave -group Stage1 -group IR -label EN -radix binary sim:/dlx_tb/uut/dp/ir/en
add wave -group Stage1 -group IR -label DIN -radix hex sim:/dlx_tb/uut/dp/ir/din
add wave -group Stage1 -group IR -label DOUT -radix hex sim:/dlx_tb/uut/dp/ir/dout
# Next Program Counter
add wave -group Stage1 -group NPC -label EN -radix binary sim:/dlx_tb/uut/dp/npc/en
add wave -group Stage1 -group NPC -label DIN -radix hex sim:/dlx_tb/uut/dp/npc/din
add wave -group Stage1 -group NPC -label DOUT -radix hex sim:/dlx_tb/uut/dp/npc/dout

################################## Stage 2 ##################################
# Control word
add wave -color gold -group Stage2 -label CW2 -radix binary sim:/dlx_tb/uut/cu/cw2
# Register File
add wave -group Stage2 -group RF -label EN -radix binary sim:/dlx_tb/uut/dp/rf/en
add wave -group Stage2 -group RF -label RD1 -radix binary sim:/dlx_tb/uut/dp/rf/rd1
add wave -group Stage2 -group RF -label RD2 -radix binary sim:/dlx_tb/uut/dp/rf/rd2
add wave -group Stage2 -group RF -label ADDR1 -radix unsigned sim:/dlx_tb/uut/dp/rf/add_rd1
add wave -group Stage2 -group RF -label ADDR2 -radix unsigned sim:/dlx_tb/uut/dp/rf/add_rd2
add wave -group Stage2 -group RF -label OUT1 -radix hex sim:/dlx_tb/uut/dp/rf/out1
add wave -group Stage2 -group RF -label OUT2 -radix hex sim:/dlx_tb/uut/dp/rf/out2
add wave -group Stage2 -group RF -label WR -radix binary sim:/dlx_tb/uut/dp/rf/wr
add wave -group Stage2 -group RF -label ADDR_WR -radix unsigned sim:/dlx_tb/uut/dp/rf/add_wr
add wave -group Stage2 -group RF -label IN -radix hex sim:/dlx_tb/uut/dp/rf/datain
add wave -group Stage2 -group RF -label REG -radix hex sim:/dlx_tb/uut/dp/rf/registers
# Register A
add wave -group Stage2 -group RegA -label EN -radix binary sim:/dlx_tb/uut/dp/reg_a/en
add wave -group Stage2 -group RegA -label DIN -radix hex sim:/dlx_tb/uut/dp/reg_a/din
add wave -group Stage2 -group RegA -label DOUT -radix hex sim:/dlx_tb/uut/dp/reg_a/dout
# Register B
add wave -group Stage2 -group RegB -label EN -radix binary sim:/dlx_tb/uut/dp/reg_b/en
add wave -group Stage2 -group RegB -label DIN -radix hex sim:/dlx_tb/uut/dp/reg_b/din
add wave -group Stage2 -group RegB -label DOUT -radix hex sim:/dlx_tb/uut/dp/reg_b/dout
# Register IMM
add wave -group Stage2 -group RegIMM -label EN -radix binary sim:/dlx_tb/uut/dp/imm/en
add wave -group Stage2 -group RegIMM -label DIN -radix hex sim:/dlx_tb/uut/dp/imm/din
add wave -group Stage2 -group RegIMM -label DOUT -radix hex sim:/dlx_tb/uut/dp/imm/dout

################################## Stage 3 ##################################
# Control word
add wave -color gold -group Stage3 -label CW3 -radix binary sim:/dlx_tb/uut/cu/cw3
# Mux A
add wave -group Stage3 -group MuxA -label S0 -radix hex sim:/dlx_tb/uut/dp/mux_a/s0
add wave -group Stage3 -group MuxA -label S1 -radix hex sim:/dlx_tb/uut/dp/mux_a/s1
add wave -group Stage3 -group MuxA -label SEL -radix binary sim:/dlx_tb/uut/dp/mux_a/sel
add wave -group Stage3 -group MuxA -label OUT -radix hex sim:/dlx_tb/uut/dp/mux_a/y
# Mux B
add wave -group Stage3 -group MuxB -label S0 -radix hex sim:/dlx_tb/uut/dp/mux_b/s0
add wave -group Stage3 -group MuxB -label S1 -radix hex sim:/dlx_tb/uut/dp/mux_b/s1
add wave -group Stage3 -group MuxB -label SEL -radix binary sim:/dlx_tb/uut/dp/mux_b/sel
add wave -group Stage3 -group MuxB -label OUT -radix hex sim:/dlx_tb/uut/dp/mux_b/y
# ALU
add wave -group Stage3 -group ALU -label A -radix hex sim:/dlx_tb/uut/dp/alu1/a
add wave -group Stage3 -group ALU -label B -radix hex sim:/dlx_tb/uut/dp/alu1/b
add wave -group Stage3 -group ALU -label OP -radix symbolic sim:/dlx_tb/uut/dp/alu1/op
add wave -group Stage3 -group ALU -label OUT -radix hex sim:/dlx_tb/uut/dp/alu1/y
# ALU Register
add wave -group Stage3 -group RegALU -label EN -radix binary sim:/dlx_tb/uut/dp/alu_reg/en
add wave -group Stage3 -group RegALU -label DIN -radix hex sim:/dlx_tb/uut/dp/alu_reg/din
add wave -group Stage3 -group RegALU -label DOUT -radix hex sim:/dlx_tb/uut/dp/alu_reg/dout
# Zero Detector
add wave -group Stage3 -group Zero? -label A -radix unsigned sim:/dlx_tb/uut/dp/cond/a
add wave -group Stage3 -group Zero? -label Z -radix unsigned sim:/dlx_tb/uut/dp/cond/y
# Branch Condition
add wave -group Stage3 -group Cond -label COND -radix binary sim:/dlx_tb/uut/dp/w_cmp_out

################################## Stage 4 ##################################
# Control word
add wave -color gold -group Stage4 -label CW4 -radix binary sim:/dlx_tb/uut/cu/cw4
# DRAM
add wave -group Stage4 -group DRAM -label EN -radix binary sim:/dlx_tb/dram/en
add wave -group Stage4 -group DRAM -label RW -radix binary sim:/dlx_tb/dram/rw
add wave -group Stage4 -group DRAM -label ADDR -radix unsigned sim:/dlx_tb/dram/addr
add wave -group Stage4 -group DRAM -label DIN -radix hex sim:/dlx_tb/dram/din
add wave -group Stage4 -group DRAM -label DOUT -radix hex sim:/dlx_tb/dram/dout
add wave -group Stage4 -group DRAM -label MEM -radix hex sim:/dlx_tb/dram/memory
# LMD Register
add wave -group Stage4 -group LMD -label EN -radix binary sim:/dlx_tb/uut/dp/lmd/en
add wave -group Stage4 -group LMD -label DIN -radix hex sim:/dlx_tb/uut/dp/lmd/din
add wave -group Stage4 -group LMD -label DOUT -radix hex sim:/dlx_tb/uut/dp/lmd/dout
# Mux Memory Access
add wave -group Stage4 -group MuxMEM -label S0 -radix hex sim:/dlx_tb/uut/dp/mux_mem/s0
add wave -group Stage4 -group MuxMEM -label S1 -radix hex sim:/dlx_tb/uut/dp/mux_mem/s1
add wave -group Stage4 -group MuxMEM -label SEL -radix binary sim:/dlx_tb/uut/dp/mux_mem/sel
add wave -group Stage4 -group MuxMEM -label OUT -radix hex sim:/dlx_tb/uut/dp/mux_mem/y

################################## Stage 5 ##################################
# Control word
add wave -color gold -group Stage5 -label CW5 -radix binary sim:/dlx_tb/uut/cu/cw5
# Mux Memory Access
add wave -group Stage5 -group MuxWB -label S0 -radix hex sim:/dlx_tb/uut/dp/mux_wb/s0
add wave -group Stage5 -group MuxWB -label S1 -radix hex sim:/dlx_tb/uut/dp/mux_wb/s1
add wave -group Stage5 -group MuxWB -label SEL -radix binary sim:/dlx_tb/uut/dp/mux_wb/sel
add wave -group Stage5 -group MuxWB -label OUT -radix hex sim:/dlx_tb/uut/dp/mux_wb/y

# Set unsigned as DEFAULT radix
radix -unsigned
# Run simulation
run 160 ns
# Print postscript waveform
#write wave p4adder.ps -start 0 -end 230000 -perpage 230000
