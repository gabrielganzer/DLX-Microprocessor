###################################################################

# Created by write_sdc on Wed Sep 16 19:06:14 2020

###################################################################
set sdc_version 1.9

set_units -time ns -resistance MOhm -capacitance fF -voltage V -current mA
set_wire_load_model -name 5K_hvratio_1_4 -library NangateOpenCellLibrary
create_clock [get_ports CLK]  -period 1.5  -waveform {0 0.75}
set_max_delay 1.5  -from [list [get_ports CLK] [get_ports RST] [get_ports {IRAM_DATA[31]}]       \
[get_ports {IRAM_DATA[30]}] [get_ports {IRAM_DATA[29]}] [get_ports             \
{IRAM_DATA[28]}] [get_ports {IRAM_DATA[27]}] [get_ports {IRAM_DATA[26]}]       \
[get_ports {IRAM_DATA[25]}] [get_ports {IRAM_DATA[24]}] [get_ports             \
{IRAM_DATA[23]}] [get_ports {IRAM_DATA[22]}] [get_ports {IRAM_DATA[21]}]       \
[get_ports {IRAM_DATA[20]}] [get_ports {IRAM_DATA[19]}] [get_ports             \
{IRAM_DATA[18]}] [get_ports {IRAM_DATA[17]}] [get_ports {IRAM_DATA[16]}]       \
[get_ports {IRAM_DATA[15]}] [get_ports {IRAM_DATA[14]}] [get_ports             \
{IRAM_DATA[13]}] [get_ports {IRAM_DATA[12]}] [get_ports {IRAM_DATA[11]}]       \
[get_ports {IRAM_DATA[10]}] [get_ports {IRAM_DATA[9]}] [get_ports              \
{IRAM_DATA[8]}] [get_ports {IRAM_DATA[7]}] [get_ports {IRAM_DATA[6]}]          \
[get_ports {IRAM_DATA[5]}] [get_ports {IRAM_DATA[4]}] [get_ports               \
{IRAM_DATA[3]}] [get_ports {IRAM_DATA[2]}] [get_ports {IRAM_DATA[1]}]          \
[get_ports {IRAM_DATA[0]}] [get_ports {DRAM_DATA_IN[31]}] [get_ports           \
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
[get_ports {DRAM_DATA_IN[0]}]]  -to [list [get_ports IRAM_EN] [get_ports {IRAM_ADDR[5]}] [get_ports           \
{IRAM_ADDR[4]}] [get_ports {IRAM_ADDR[3]}] [get_ports {IRAM_ADDR[2]}]          \
[get_ports {IRAM_ADDR[1]}] [get_ports {IRAM_ADDR[0]}] [get_ports DRAM_EN]      \
[get_ports DRAM_RW] [get_ports {DRAM_ADDR[5]}] [get_ports {DRAM_ADDR[4]}]      \
[get_ports {DRAM_ADDR[3]}] [get_ports {DRAM_ADDR[2]}] [get_ports               \
{DRAM_ADDR[1]}] [get_ports {DRAM_ADDR[0]}] [get_ports {DRAM_DATA_OUT[31]}]     \
[get_ports {DRAM_DATA_OUT[30]}] [get_ports {DRAM_DATA_OUT[29]}] [get_ports     \
{DRAM_DATA_OUT[28]}] [get_ports {DRAM_DATA_OUT[27]}] [get_ports                \
{DRAM_DATA_OUT[26]}] [get_ports {DRAM_DATA_OUT[25]}] [get_ports                \
{DRAM_DATA_OUT[24]}] [get_ports {DRAM_DATA_OUT[23]}] [get_ports                \
{DRAM_DATA_OUT[22]}] [get_ports {DRAM_DATA_OUT[21]}] [get_ports                \
{DRAM_DATA_OUT[20]}] [get_ports {DRAM_DATA_OUT[19]}] [get_ports                \
{DRAM_DATA_OUT[18]}] [get_ports {DRAM_DATA_OUT[17]}] [get_ports                \
{DRAM_DATA_OUT[16]}] [get_ports {DRAM_DATA_OUT[15]}] [get_ports                \
{DRAM_DATA_OUT[14]}] [get_ports {DRAM_DATA_OUT[13]}] [get_ports                \
{DRAM_DATA_OUT[12]}] [get_ports {DRAM_DATA_OUT[11]}] [get_ports                \
{DRAM_DATA_OUT[10]}] [get_ports {DRAM_DATA_OUT[9]}] [get_ports                 \
{DRAM_DATA_OUT[8]}] [get_ports {DRAM_DATA_OUT[7]}] [get_ports                  \
{DRAM_DATA_OUT[6]}] [get_ports {DRAM_DATA_OUT[5]}] [get_ports                  \
{DRAM_DATA_OUT[4]}] [get_ports {DRAM_DATA_OUT[3]}] [get_ports                  \
{DRAM_DATA_OUT[2]}] [get_ports {DRAM_DATA_OUT[1]}] [get_ports                  \
{DRAM_DATA_OUT[0]}]]
