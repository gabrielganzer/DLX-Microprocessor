#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Wed Sep 16 06:13:07 2020                
#                                                     
#######################################################

#@(#)CDS: Innovus v17.11-s080_1 (64bit) 08/04/2017 11:13 (Linux 2.6.18-194.el5)
#@(#)CDS: NanoRoute 17.11-s080_1 NR170721-2155/17_11-UB (database version 2.30, 390.7.1) {superthreading v1.44}
#@(#)CDS: AAE 17.11-s034 (64bit) 08/04/2017 (Linux 2.6.18-194.el5)
#@(#)CDS: CTE 17.11-s053_1 () Aug  1 2017 23:31:41 ( )
#@(#)CDS: SYNTECH 17.11-s012_1 () Jul 21 2017 02:29:12 ( )
#@(#)CDS: CPE v17.11-s095
#@(#)CDS: IQRC/TQRC 16.1.1-s215 (64bit) Thu Jul  6 20:18:10 PDT 2017 (Linux 2.6.18-194.el5)

set_global _enable_mmmc_by_default_flow      $CTE::mmmc_default
suppressMessage ENCEXT-2799
getDrawView
loadWorkspace -name Physical
win
set defHierChar /
set delaycal_input_transition_delay 0.1ps
set fpIsMaxIoHeight 0
set init_gnd_net gnd
set init_mmmc_file Default.view
set init_oa_search_lib {}
set init_pwr_net vdd
set init_verilog dlx.v
set init_lef_file /software/dk/nangate45/lef/NangateOpenCellLibrary.lef
init_design
init_design
init_design
init_design
set defHierChar /
set delaycal_input_transition_delay 0.1ps
set fpIsMaxIoHeight 0
set init_gnd_net gnd
set init_mmmc_file Default.view
set init_oa_search_lib {}
set init_pwr_net vdd
set init_verilog dlx.v
set init_lef_file /software/dk/nangate45/lef/NangateOpenCellLibrary.lef
init_design
init_design
set defHierChar /
set delaycal_input_transition_delay 0.1ps
set fpIsMaxIoHeight 0
set init_gnd_net gnd
set init_mmmc_file Default.view
set init_oa_search_lib {}
set init_pwr_net vdd
set init_verilog dlx_gated.v
set init_lef_file /software/dk/nangate45/lef/NangateOpenCellLibrary.lef
init_design
getIoFlowFlag
setIoFlowFlag 0
floorPlan -coreMarginsBy die -site FreePDK45_38x28_10R_NP_162NW_34O -r 1 0.6 5 5 5 5
uiSetTool select
getIoFlowFlag
fit
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
setAddRingMode -ring_target default -extend_over_row 0 -ignore_rows 0 -avoid_short 0 -skip_crossing_trunks none -stacked_via_top_layer metal10 -stacked_via_bottom_layer metal1 -via_using_exact_crossover_size 1 -orthogonal_only true -skip_via_on_pin {  standardcell } -skip_via_on_wire_shape {  noshape }
addRing -nets {gnd vdd} -type core_rings -follow core -layer {top metal9 bottom metal9 left metal10 right metal10} -width {top 0.8 bottom 0.8 left 0.8 right 0.8} -spacing {top 0.8 bottom 0.8 left 0.8 right 0.8} -offset {top 1.8 bottom 1.8 left 1.8 right 1.8} -center 1 -extend_corner {} -threshold 0 -jog_distance 0 -snap_wire_center_to_grid None
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
setAddStripeMode -ignore_block_check false -break_at none -route_over_rows_only false -rows_without_stripes_only false -extend_to_closest_target none -stop_at_last_wire_for_area false -partial_set_thru_domain false -ignore_nondefault_domains false -trim_antenna_back_to_shape none -spacing_type edge_to_edge -spacing_from_block 0 -stripe_min_length 0 -stacked_via_top_layer metal10 -stacked_via_bottom_layer metal1 -via_using_exact_crossover_size false -split_vias false -orthogonal_only true -allow_jog { padcore_ring  block_ring }
addStripe -nets {gnd vdd} -layer metal10 -direction vertical -width 0.8 -spacing 0.8 -set_to_set_distance 20 -start_from left -start_offset 15 -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit metal10 -padcore_ring_bottom_layer_limit metal1 -block_ring_top_layer_limit metal10 -block_ring_bottom_layer_limit metal1 -use_wire_group 0 -snap_wire_center_to_grid None -skip_via_on_pin {  standardcell } -skip_via_on_wire_shape {  noshape }
setSrouteMode -viaConnectToShape { noshape }
sroute -connect { blockPin padPin padRing corePin floatingStripe } -layerChangeRange { metal1(1) metal10(10) } -blockPinTarget { nearestTarget } -padPinPortConnect { allPort oneGeom } -padPinTarget { nearestTarget } -corePinTarget { firstAfterRowEnd } -floatingStripeTarget { blockring padring ring stripe ringpin blockpin followpin } -allowJogging 1 -crossoverViaLayerRange { metal1(1) metal10(10) } -nets { gnd vdd } -allowLayerChange 1 -blockPin useLef -targetViaLayerRange { metal1(1) metal10(10) }
setPlaceMode -prerouteAsObs {1 2 3 4 5 6 7 8}
setPlaceMode -prerouteAsObs {1 2 3 4 5 6 7 8}
setPlaceMode -fp false
placeDesign
getPinAssignMode -pinEditInBatch -quiet
setPinAssignMode -pinEditInBatch true
editPin -fixOverlap 1 -unit MICRON -spreadDirection clockwise -side Bottom -layer 1 -spreadType center -spacing 0.14 -pin RST
setPinAssignMode -pinEditInBatch true
editPin -fixOverlap 1 -unit MICRON -spreadDirection clockwise -side Bottom -layer 1 -spreadType center -spacing 0.14 -pin IRAM_EN
setPinAssignMode -pinEditInBatch true
editPin -fixOverlap 1 -unit MICRON -spreadDirection clockwise -side Bottom -layer 1 -spreadType center -spacing 0.14 -pin DRAM_RW
setPinAssignMode -pinEditInBatch true
editPin -fixOverlap 1 -unit MICRON -spreadDirection clockwise -side Bottom -layer 1 -spreadType center -spacing 0.14 -pin DRAM_EN
setPinAssignMode -pinEditInBatch true
editPin -fixOverlap 1 -unit MICRON -spreadDirection clockwise -side Bottom -layer 1 -spreadType center -spacing 0.14 -pin CLK
setPinAssignMode -pinEditInBatch true
editPin -fixOverlap 1 -unit MICRON -spreadDirection clockwise -side Right -layer 1 -spreadType center -spacing 0.14 -pin {{DRAM_ADDR[0]} {DRAM_ADDR[1]} {DRAM_ADDR[2]} {DRAM_ADDR[3]} {DRAM_ADDR[4]} {DRAM_ADDR[5]}}
setPinAssignMode -pinEditInBatch true
editPin -pinWidth 0.07 -pinDepth 0.07 -fixOverlap 1 -spreadDirection clockwise -side Right -layer 1 -spreadType side -pin {{DRAM_ADDR[0]} {DRAM_ADDR[1]} {DRAM_ADDR[2]} {DRAM_ADDR[3]} {DRAM_ADDR[4]} {DRAM_ADDR[5]}}
setPinAssignMode -pinEditInBatch true
editPin -fixOverlap 1 -spreadDirection clockwise -side Right -layer 1 -spreadType side -pin {{DRAM_DATA_OUT[0]} {DRAM_DATA_OUT[1]} {DRAM_DATA_OUT[2]} {DRAM_DATA_OUT[3]} {DRAM_DATA_OUT[4]} {DRAM_DATA_OUT[5]} {DRAM_DATA_OUT[6]} {DRAM_DATA_OUT[7]} {DRAM_DATA_OUT[8]} {DRAM_DATA_OUT[9]} {DRAM_DATA_OUT[10]} {DRAM_DATA_OUT[11]} {DRAM_DATA_OUT[12]} {DRAM_DATA_OUT[13]} {DRAM_DATA_OUT[14]} {DRAM_DATA_OUT[15]} {DRAM_DATA_OUT[16]} {DRAM_DATA_OUT[17]} {DRAM_DATA_OUT[18]} {DRAM_DATA_OUT[19]} {DRAM_DATA_OUT[20]} {DRAM_DATA_OUT[21]} {DRAM_DATA_OUT[22]} {DRAM_DATA_OUT[23]} {DRAM_DATA_OUT[24]} {DRAM_DATA_OUT[25]} {DRAM_DATA_OUT[26]} {DRAM_DATA_OUT[27]} {DRAM_DATA_OUT[28]} {DRAM_DATA_OUT[29]} {DRAM_DATA_OUT[30]} {DRAM_DATA_OUT[31]}}
setPinAssignMode -pinEditInBatch true
editPin -fixOverlap 1 -spreadDirection clockwise -side Top -layer 1 -spreadType side -pin {{DRAM_DATA_IN[0]} {DRAM_DATA_IN[1]} {DRAM_DATA_IN[2]} {DRAM_DATA_IN[3]} {DRAM_DATA_IN[4]} {DRAM_DATA_IN[5]} {DRAM_DATA_IN[6]} {DRAM_DATA_IN[7]} {DRAM_DATA_IN[8]} {DRAM_DATA_IN[9]} {DRAM_DATA_IN[10]} {DRAM_DATA_IN[11]} {DRAM_DATA_IN[12]} {DRAM_DATA_IN[13]} {DRAM_DATA_IN[14]} {DRAM_DATA_IN[15]} {DRAM_DATA_IN[16]} {DRAM_DATA_IN[17]} {DRAM_DATA_IN[18]} {DRAM_DATA_IN[19]} {DRAM_DATA_IN[20]} {DRAM_DATA_IN[21]} {DRAM_DATA_IN[22]} {DRAM_DATA_IN[23]} {DRAM_DATA_IN[24]} {DRAM_DATA_IN[25]} {DRAM_DATA_IN[26]} {DRAM_DATA_IN[27]} {DRAM_DATA_IN[28]} {DRAM_DATA_IN[29]} {DRAM_DATA_IN[30]} {DRAM_DATA_IN[31]}}
setPinAssignMode -pinEditInBatch true
editPin -fixOverlap 1 -spreadDirection clockwise -side Top -layer 1 -spreadType side -pin {{IRAM_ADDR[0]} {IRAM_ADDR[1]} {IRAM_ADDR[2]} {IRAM_ADDR[3]} {IRAM_ADDR[4]} {IRAM_ADDR[5]}}
setPinAssignMode -pinEditInBatch true
editPin -fixOverlap 1 -spreadDirection clockwise -side Left -layer 1 -spreadType side -pin {{IRAM_DATA[0]} {IRAM_DATA[1]} {IRAM_DATA[2]} {IRAM_DATA[3]} {IRAM_DATA[4]} {IRAM_DATA[5]} {IRAM_DATA[6]} {IRAM_DATA[7]} {IRAM_DATA[8]} {IRAM_DATA[9]} {IRAM_DATA[10]} {IRAM_DATA[11]} {IRAM_DATA[12]} {IRAM_DATA[13]} {IRAM_DATA[14]} {IRAM_DATA[15]} {IRAM_DATA[16]} {IRAM_DATA[17]} {IRAM_DATA[18]} {IRAM_DATA[19]} {IRAM_DATA[20]} {IRAM_DATA[21]} {IRAM_DATA[22]} {IRAM_DATA[23]} {IRAM_DATA[24]} {IRAM_DATA[25]} {IRAM_DATA[26]} {IRAM_DATA[27]} {IRAM_DATA[28]} {IRAM_DATA[29]} {IRAM_DATA[30]} {IRAM_DATA[31]}}
setPinAssignMode -pinEditInBatch true
editPin -pinWidth 0.07 -pinDepth 0.07 -fixOverlap 1 -spreadDirection clockwise -side Left -layer 1 -spreadType side -pin {{IRAM_DATA[0]} {IRAM_DATA[1]} {IRAM_DATA[2]} {IRAM_DATA[3]} {IRAM_DATA[4]} {IRAM_DATA[5]} {IRAM_DATA[6]} {IRAM_DATA[7]} {IRAM_DATA[8]} {IRAM_DATA[9]} {IRAM_DATA[10]} {IRAM_DATA[11]} {IRAM_DATA[12]} {IRAM_DATA[13]} {IRAM_DATA[14]} {IRAM_DATA[15]} {IRAM_DATA[16]} {IRAM_DATA[17]} {IRAM_DATA[18]} {IRAM_DATA[19]} {IRAM_DATA[20]} {IRAM_DATA[21]} {IRAM_DATA[22]} {IRAM_DATA[23]} {IRAM_DATA[24]} {IRAM_DATA[25]} {IRAM_DATA[26]} {IRAM_DATA[27]} {IRAM_DATA[28]} {IRAM_DATA[29]} {IRAM_DATA[30]} {IRAM_DATA[31]}}
setPinAssignMode -pinEditInBatch false
setOptMode -fixCap true -fixTran true -fixFanoutLoad false
optDesign -postCTS
optDesign -postCTS -hold
getFillerMode -quiet
addFiller -cell FILLCELL_X8 FILLCELL_X4 FILLCELL_X32 FILLCELL_X2 FILLCELL_X16 FILLCELL_X1 -prefix FILLER
setNanoRouteMode -quiet -timingEngine {}
setNanoRouteMode -quiet -routeWithSiPostRouteFix 0
setNanoRouteMode -quiet -drouteStartIteration default
setNanoRouteMode -quiet -routeTopRoutingLayer default
setNanoRouteMode -quiet -routeBottomRoutingLayer default
setNanoRouteMode -quiet -drouteEndIteration default
setNanoRouteMode -quiet -routeWithTimingDriven false
setNanoRouteMode -quiet -routeWithSiDriven false
routeDesign -globalDetail
setAnalysisMode -analysisType onChipVariation
selectInst {DP/RegFILE/REGISTERS_reg[22][13]}
deselectAll
setOptMode -fixCap true -fixTran true -fixFanoutLoad false
optDesign -postRoute
optDesign -postRoute -hold
saveDesign DLX_GATED
win
reset_parasitics
extractRC
rcOut -setload DLX_WIDTH32.setload -rc_corner standard
rcOut -setres DLX_WIDTH32.setres -rc_corner standard
rcOut -spf DLX_WIDTH32.spf -rc_corner standard
rcOut -spef DLX_WIDTH32.spef -rc_corner standard
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postRoute -pathReports -drvReports -slackReports -numPaths 10 -prefix DLX_GATEDsetup_postRoute -outDir timingReports
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postRoute -hold -pathReports -slackReports -numPaths 10 -prefix DLX_GATEDhold_postRoute -outDir timingReports
get_time_unit
report_timing -machine_readable -max_paths 10000 -max_slack 0.75 -path_exceptions all > top.mtarpt
load_timing_debug_report -name default_report top.mtarpt
get_time_unit
report_timing -machine_readable -max_paths 10000 -max_slack 0.75 -path_exceptions all -early > top.mtarpt
load_timing_debug_report -name default_report top.mtarpt
verifyConnectivity -type all -report DLX_GATED.conn.rpt -error 1000 -warning 50
setVerifyGeometryMode -area { 0 0 0 0 } -minWidth true -minSpacing true -minArea true -sameNet true -short true -overlap true -offRGrid false -offMGrid true -mergedMGridCheck true -minHole true -implantCheck true -minimumCut true -minStep true -viaEnclosure true -antenna false -insuffMetalOverlap true -pinInBlkg false -diffCellViol true -sameCellViol false -padFillerCellsOverlap true -routingBlkgPinOverlap true -routingCellBlkgOverlap true -regRoutingOnly false -stackedViasOnRegNet false -wireExt true -useNonDefaultSpacing false -maxWidth true -maxNonPrefLength -1 -error 1000
verifyGeometry
setVerifyGeometryMode -area { 0 0 0 0 }
reportGateCount -level 5 -limit 100 -outfile DLX_GATED.gateCount
saveNetlist DLX_gated.v
all_hold_analysis_views 
all_setup_analysis_views 
write_sdf  -ideal_clock_network DLX_GATED.sdf
