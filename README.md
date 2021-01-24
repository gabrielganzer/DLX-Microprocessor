# DLX-Processor
[![SHIELDS](https://img.shields.io/badge/development-completed-green)](https://shields.io/)

## PROJECT DESCRIPTION

This project consisted of developing a small DLX(DELUXE) processor from RTL design using ModelSim, synthesis&optimization with Synopsys Design Vision, down to the physical design using Cadence. The DLX is a fully pipelined RISC processor based on the Harvard Architecture, i.e., it
relies on two different memories for instructions and data, allowing simultaneous instruction-fetching and data transactions.

The features implemented are listed bellow:

* **Extended Instruction Set**: addu, addui, jalr, jr, lb, lbu, lhi, lhu, sb, seq, seqi, sgeu, sgeui,
sgt, sgti, sgtu, sgtui, slt, slti, sltu, sltui, sra, srai, subu, subui, mult;
* **Optimized ALU**: Pentium4 adder/subtractor, UltraSPARC T2 3-level Shifter, UltraSPARC
T2 Logic Unit using 2-level NAND gates, Multi-purpose Comparator, Zero Detector, and a
multiplier that combines both Wallace Tree and Booth approaches. Power optimization was
achieved by reducing switching activity through state assignment of all blocks;
* **Forwarding Unit**: data hazard control;
* **Clock-Gating**: Register File and Generic Registers gated for power optimization;

## DOCUMENTATION

The folders are organized according to the design flow:

* **DLX_simulation**: the VHDL files were organized hierarchically, refer to the *test_bech* for compiling scripts, testing, and behavioral results.
* **DLX_synthesis**: the folder *report* provides the results obtained with the *DLX.src* script.
* **DLX_physical_layout**: this folder contains the source files for the physical design, refer to the folder *timingReports* for results.

Further information about the project can be found at *Report.pdf*.
