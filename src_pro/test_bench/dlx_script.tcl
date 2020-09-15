# Compile
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/000-globals.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/01-fa.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/01-generic_mux21.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/01-generic_mux31.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/01-generic_rca.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/01-generic_register.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/01-ivx.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/01-nand2.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.a-adder.core/a.b.a.a.a-pg_network.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.a-adder.core/a.b.a.a.b-g_block.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.a-adder.core/a.b.a.a.c-pg_block.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.a-adder.core/a.b.a.a.d-carry_select_block.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.a-adder.core/a.b.a.a.e-sum_generator.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.a-adder.core/a.b.a.a.f-sparse_tree.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.b-shifter.core/a.b.a.b.a-mask_generator.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.b-shifter.core/a.b.a.b.b-coarse_shift.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.b-shifter.core/a.b.a.b.c-fine_shift.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.c-logic.core/a.b.a.c.a-nand3.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.c-logic.core/a.b.a.c.b-nand4.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.f-multiplier.core/a.b.a.f.a-booth_encoder.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.f-multiplier.core/a.b.a.f.b-rca_mul.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.a-adder.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.b-shifter.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.c-logic.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.d-comparator.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.e-zero_detector.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/a.b-DataPath.core/a.b.a-ALU.core/a.b.a.f-multiplier.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/a.b-DataPath.core/a.b.a-ALU.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/a.b-DataPath.core/a.b.b-register_file.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/a.b-DataPath.core/a.b.c-sign_extend.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/a.b-DataPath.core/a.b.d-branch_unit.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/a.b-DataPath.core/a.b.e-forwarding_unit.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/a.a-CU_HW.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/a.b-DataPath.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/a.c-IRAM.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/a.d-DRAM.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/a-DLX.vhd
vcom Y:/Microelectronic_Systems/DLX-Project/src_pro/test_bench/TB_DLX.vhd

# Start simulation
vsim -t 10ps work.dlx_tb(testbench)

################################## ProgramCounter ##################################
add wave -group ProgramCounter sim:/dlx_tb/uut/pc/*

################################## IRAM ##################################
add wave -group InstructionMemory sim:/dlx_tb/iram/*

################################## InstructionRegister ##################################
add wave -group InstructionRegister sim:/dlx_tb/uut/ir/*

################################## ControlUnit ##################################
add wave -group ControlUnit sim:/dlx_tb/uut/cu/*

################################## DataPath ##################################
add wave -group DataPath sim:/dlx_tb/uut/dp/*
# Stage 1
add wave -group DataPath -group RegNPC1 sim:/dlx_tb/uut/dp/RegNPC1/*
# Stage 2
add wave -group DataPath -group MuxWR sim:/dlx_tb/uut/dp/MuxWR/*
add wave -group DataPath -group RegFILE sim:/dlx_tb/uut/dp/RegFILE/*
add wave -group DataPath -group RegA sim:/dlx_tb/uut/dp/RegA/*
add wave -group DataPath -group RegB sim:/dlx_tb/uut/dp/RegB/*
add wave -group DataPath -group SignImm16 sim:/dlx_tb/uut/dp/SignImm16/*
add wave -group DataPath -group SignImm26 sim:/dlx_tb/uut/dp/SignImm26/*
add wave -group DataPath -group MuxIMM sim:/dlx_tb/uut/dp/MuxIMM/*
add wave -group DataPath -group RegIMM sim:/dlx_tb/uut/dp/RegIMM/*
add wave -group DataPath -group RegRD2 sim:/dlx_tb/uut/dp/RegRD2/*
add wave -group DataPath -group RegNPC2 sim:/dlx_tb/uut/dp/RegNPC2/*
# Stage 3
add wave -group DataPath -group MuxA sim:/dlx_tb/uut/dp/MuxA/*
add wave -group DataPath -group MuxB sim:/dlx_tb/uut/dp/MuxB/*
add wave -group DataPath -group FwdA sim:/dlx_tb/uut/dp/FwdA/*
add wave -group DataPath -group FwdB sim:/dlx_tb/uut/dp/FwdB/*
add wave -group DataPath -group FwdC sim:/dlx_tb/uut/dp/FwdC/*
add wave -group DataPath -group ALU0 sim:/dlx_tb/uut/dp/ALU0/*
add wave -group DataPath -group RegALU3 sim:/dlx_tb/uut/dp/RegALU3/*
add wave -group DataPath -group ZERO sim:/dlx_tb/uut/dp/ZERO/*
add wave -group DataPath -group COND sim:/dlx_tb/uut/dp/COND/*
add wave -group DataPath -group RegME sim:/dlx_tb/uut/dp/RegME/*
add wave -group DataPath -group RegRD3 sim:/dlx_tb/uut/dp/RegRD3/*
add wave -group DataPath -group RegNPC3 sim:/dlx_tb/uut/dp/RegNPC3/*
# Stage 4
add wave -group DataPath -group MuxMEM sim:/dlx_tb/uut/dp/MuxMEM/*
add wave -group DataPath -group FwdD sim:/dlx_tb/uut/dp/FwdD/*
add wave -group DataPath -group RegLMD sim:/dlx_tb/uut/dp/RegLMD/*
add wave -group DataPath -group RegRD4 sim:/dlx_tb/uut/dp/RegRD4/*
add wave -group DataPath -group RegNPC4 sim:/dlx_tb/uut/dp/RegNPC4/*
add wave -group DataPath -group RegALU4 sim:/dlx_tb/uut/dp/RegALU4/*  
# Stage 5
add wave -group DataPath -group MuxWB sim:/dlx_tb/uut/dp/MuxWB/*
# Forwarding Unit
add wave -group DataPath -group FU sim:/dlx_tb/uut/dp/FU/*

################################## DRAM ##################################
add wave -group DataMemory sim:/dlx_tb/dram/*

# Set unsigned as DEFAULT radix
radix -hex
# Run simulation
run 250 ns
# Print postscript waveform
#write wave p4adder.ps -start 0 -end 230000 -perpage 230000
