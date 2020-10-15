###################################################################

# Created by write_sdc on Thu Oct 15 17:52:54 2020

###################################################################
set sdc_version 1.9

set_units -time ns -resistance MOhm -capacitance fF -voltage V -current mA
create_clock [get_ports CLK]  -period 0.714  -waveform {0 0.357}
set_max_delay 0.714  -from [list [get_ports CLK] [get_ports RST] [get_ports {IROM_DATA[31]}]       \
[get_ports {IROM_DATA[30]}] [get_ports {IROM_DATA[29]}] [get_ports             \
{IROM_DATA[28]}] [get_ports {IROM_DATA[27]}] [get_ports {IROM_DATA[26]}]       \
[get_ports {IROM_DATA[25]}] [get_ports {IROM_DATA[24]}] [get_ports             \
{IROM_DATA[23]}] [get_ports {IROM_DATA[22]}] [get_ports {IROM_DATA[21]}]       \
[get_ports {IROM_DATA[20]}] [get_ports {IROM_DATA[19]}] [get_ports             \
{IROM_DATA[18]}] [get_ports {IROM_DATA[17]}] [get_ports {IROM_DATA[16]}]       \
[get_ports {IROM_DATA[15]}] [get_ports {IROM_DATA[14]}] [get_ports             \
{IROM_DATA[13]}] [get_ports {IROM_DATA[12]}] [get_ports {IROM_DATA[11]}]       \
[get_ports {IROM_DATA[10]}] [get_ports {IROM_DATA[9]}] [get_ports              \
{IROM_DATA[8]}] [get_ports {IROM_DATA[7]}] [get_ports {IROM_DATA[6]}]          \
[get_ports {IROM_DATA[5]}] [get_ports {IROM_DATA[4]}] [get_ports               \
{IROM_DATA[3]}] [get_ports {IROM_DATA[2]}] [get_ports {IROM_DATA[1]}]          \
[get_ports {IROM_DATA[0]}] [get_ports {DRAM_DATA_IN[31]}] [get_ports           \
{DRAM_DATA_IN[30]}] [get_ports {DRAM_DATA_IN[29]}] [get_ports                  \
{DRAM_DATA_IN[28]}] [get_ports {DRAM_DATA_IN[27]}] [get_ports                  \
{DRAM_DATA_IN[26]}] [get_ports {DRAM_DATA_IN[25]}] [get_ports                  \
{DRAM_DATA_IN[24]}] [get_ports {DRAM_DATA_IN[23]}] [get_ports                  \
{DRAM_DATA_IN[22]}] [get_ports {DRAM_DATA_IN[21]}] [get_ports                  \
{DRAM_DATA_IN[20]}] [get_ports {DRAM_DATA_IN[19]}] [get_ports                  \
{DRAM_DATA_IN[18]}] [get_ports {DRAM_DATA_IN[17]}] [get_ports                  \
{DRAM_DATA_IN[16]}] [get_ports {DRAM_DATA_IN[15]}] [get_ports                  \
{DRAM_DATA_IN[14]}] [get_ports {DRAM_DATA_IN[13]}] [get_ports                  \
{DRAM_DATA_IN[12]}] [get_ports {DRAM_DATA_IN[11]}] [get_ports                  \
{DRAM_DATA_IN[10]}] [get_ports {DRAM_DATA_IN[9]}] [get_ports                   \
{DRAM_DATA_IN[8]}] [get_ports {DRAM_DATA_IN[7]}] [get_ports {DRAM_DATA_IN[6]}] \
[get_ports {DRAM_DATA_IN[5]}] [get_ports {DRAM_DATA_IN[4]}] [get_ports         \
{DRAM_DATA_IN[3]}] [get_ports {DRAM_DATA_IN[2]}] [get_ports {DRAM_DATA_IN[1]}] \
[get_ports {DRAM_DATA_IN[0]}]]  -to [list [get_ports {IROM_ADDR[11]}] [get_ports {IROM_ADDR[10]}] [get_ports  \
{IROM_ADDR[9]}] [get_ports {IROM_ADDR[8]}] [get_ports {IROM_ADDR[7]}]          \
[get_ports {IROM_ADDR[6]}] [get_ports {IROM_ADDR[5]}] [get_ports               \
{IROM_ADDR[4]}] [get_ports {IROM_ADDR[3]}] [get_ports {IROM_ADDR[2]}]          \
[get_ports {IROM_ADDR[1]}] [get_ports {IROM_ADDR[0]}] [get_ports DRAM_EN]      \
[get_ports DRAM_RW] [get_ports {DRAM_ADDR[11]}] [get_ports {DRAM_ADDR[10]}]    \
[get_ports {DRAM_ADDR[9]}] [get_ports {DRAM_ADDR[8]}] [get_ports               \
{DRAM_ADDR[7]}] [get_ports {DRAM_ADDR[6]}] [get_ports {DRAM_ADDR[5]}]          \
[get_ports {DRAM_ADDR[4]}] [get_ports {DRAM_ADDR[3]}] [get_ports               \
{DRAM_ADDR[2]}] [get_ports {DRAM_ADDR[1]}] [get_ports {DRAM_ADDR[0]}]          \
[get_ports {DRAM_DATA_OUT[31]}] [get_ports {DRAM_DATA_OUT[30]}] [get_ports     \
{DRAM_DATA_OUT[29]}] [get_ports {DRAM_DATA_OUT[28]}] [get_ports                \
{DRAM_DATA_OUT[27]}] [get_ports {DRAM_DATA_OUT[26]}] [get_ports                \
{DRAM_DATA_OUT[25]}] [get_ports {DRAM_DATA_OUT[24]}] [get_ports                \
{DRAM_DATA_OUT[23]}] [get_ports {DRAM_DATA_OUT[22]}] [get_ports                \
{DRAM_DATA_OUT[21]}] [get_ports {DRAM_DATA_OUT[20]}] [get_ports                \
{DRAM_DATA_OUT[19]}] [get_ports {DRAM_DATA_OUT[18]}] [get_ports                \
{DRAM_DATA_OUT[17]}] [get_ports {DRAM_DATA_OUT[16]}] [get_ports                \
{DRAM_DATA_OUT[15]}] [get_ports {DRAM_DATA_OUT[14]}] [get_ports                \
{DRAM_DATA_OUT[13]}] [get_ports {DRAM_DATA_OUT[12]}] [get_ports                \
{DRAM_DATA_OUT[11]}] [get_ports {DRAM_DATA_OUT[10]}] [get_ports                \
{DRAM_DATA_OUT[9]}] [get_ports {DRAM_DATA_OUT[8]}] [get_ports                  \
{DRAM_DATA_OUT[7]}] [get_ports {DRAM_DATA_OUT[6]}] [get_ports                  \
{DRAM_DATA_OUT[5]}] [get_ports {DRAM_DATA_OUT[4]}] [get_ports                  \
{DRAM_DATA_OUT[3]}] [get_ports {DRAM_DATA_OUT[2]}] [get_ports                  \
{DRAM_DATA_OUT[1]}] [get_ports {DRAM_DATA_OUT[0]}]]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
DP/RegNPC3/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
DP/RegNPC3/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
DP/RegNPC3/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
DP/RegNPC3/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
DP/FFDJL2/clk_gate_Q_reg@main_gate]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
DP/FFDJL2/clk_gate_Q_reg@main_gate]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
DP/FFDJL2/clk_gate_Q_reg@main_gate]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
DP/FFDJL2/clk_gate_Q_reg@main_gate]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
DP/RegLMD/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
DP/RegLMD/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
DP/RegLMD/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
DP/RegLMD/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
DP/RegALU1/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
DP/RegALU1/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
DP/RegALU1/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
DP/RegALU1/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
DP/RegNPC2/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
DP/RegNPC2/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
DP/RegNPC2/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
DP/RegNPC2/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
DP/RegA1/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
DP/RegA1/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
DP/RegA1/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
DP/RegA1/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
DP/RegB/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
DP/RegB/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
DP/RegB/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
DP/RegB/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
DP/RegA/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
DP/RegA/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
DP/RegA/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
DP/RegA/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
DP/RegNPC1/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
DP/RegNPC1/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
DP/RegNPC1/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
DP/RegNPC1/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
DP/RegNPC/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
DP/RegNPC/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
DP/RegNPC/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
DP/RegNPC/clk_gate_DOUT_reg@main_gate]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
DP/FFDBRANCH/clk_gate_Q_reg@main_gate]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
DP/FFDBRANCH/clk_gate_Q_reg@main_gate]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
DP/FFDBRANCH/clk_gate_Q_reg@main_gate]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
DP/FFDBRANCH/clk_gate_Q_reg@main_gate]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[31]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[31]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[31]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[31]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[30]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[30]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[30]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[30]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[29]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[29]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[29]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[29]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[28]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[28]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[28]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[28]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[27]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[27]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[27]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[27]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[26]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[26]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[26]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[26]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[25]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[25]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[25]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[25]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[24]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[24]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[24]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[24]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[23]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[23]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[23]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[23]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[22]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[22]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[22]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[22]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[21]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[21]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[21]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[21]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[20]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[20]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[20]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[20]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[19]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[19]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[19]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[19]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[18]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[18]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[18]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[18]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[17]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[17]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[17]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[17]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[16]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[16]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[16]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[16]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[15]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[15]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[15]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[15]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[14]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[14]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[14]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[14]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[13]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[13]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[13]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[13]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[12]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[12]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[12]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[12]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[11]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[11]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[11]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[11]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[10]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[10]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[10]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[10]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[9]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[9]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[9]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[9]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[8]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[8]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[8]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[8]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[7]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[7]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[7]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[7]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[6]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[6]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[6]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[6]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[5]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[5]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[5]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[5]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[4]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[4]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[4]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[4]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[3]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[3]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[3]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[3]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[2]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[2]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[2]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[2]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[1]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[1]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[1]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[1]@main_gate}]
set_clock_gating_check -rise -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[0]@main_gate}]
set_clock_gating_check -fall -setup 0 [get_cells -hsc @                        \
{DP/RF0@clk_gate_REGISTERS_reg[0]@main_gate}]
set_clock_gating_check -rise -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[0]@main_gate}]
set_clock_gating_check -fall -hold 0 [get_cells -hsc @                         \
{DP/RF0@clk_gate_REGISTERS_reg[0]@main_gate}]
