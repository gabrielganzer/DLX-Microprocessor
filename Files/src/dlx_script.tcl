# Compile VHDL netlists
vcom constants.vhd
vcom functions.vhd
vcom blockG.vhd
vcom blockPG.vhd
vcom PGnetwork.vhd
vcom sparsetree.vhd
vcom mux21.vhd
vcom fa.vhd
vcom rca.vhd
vcom csb.vhd
vcom sumgen.vhd
vcom P4adder.vhd
vcom tbP4adder.vhd
# Start simulation
vsim -t 10ps work.tbp4(test)
# Add waves setting their format, label, and radix
add wave -format logic -label A -radix signed sim:/tbp4/s_A
add wave -format logic -label B -radix signed sim:/tbp4/s_B
add wave -format logic -label Ci -radix binary sim:/tbp4/s_Ci
add wave -format logic -label S -radix signed sim:/tbp4/s_S
add wave -format logic -label Co -radix binary sim:/tbp4/s_Co
# Set unsigned as DEFAULT radix
radix -unsigned
# Run simulation
run 230 ns
# Print postscript waveform
write wave p4adder.ps -start 0 -end 230000 -perpage 230000
