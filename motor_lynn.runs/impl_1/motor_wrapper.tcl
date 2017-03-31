proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
set_msg_config -id {HDL-1065} -limit 10000

start_step init_design
set rc [catch {
  create_msg_db init_design.pb
  create_project -in_memory -part xc7z020clg484-1
  set_property board_part em.avnet.com:zed:part0:1.3 [current_project]
  set_property design_mode GateLvl [current_fileset]
  set_param project.singleFileAddWarning.threshold 0
  set_property webtalk.parent_dir E:/Lin/vivado_learing/motor_lynn/motor_lynn.cache/wt [current_project]
  set_property parent.project_path E:/Lin/vivado_learing/motor_lynn/motor_lynn.xpr [current_project]
  set_property ip_repo_paths {
  e:/Lin/vivado_learing/motor_lynn/motor_lynn.cache/ip
  E:/Lin/vivado_learing/motor_lynn/ip_repo/motor_2.0
  E:/Lin/vivado_learing/motor_lynn/ip_repo/motor2_1.0
  e:/Lin/vivado_learing/motor_lynn/ip_repo/motor_1.0
  e:/Lin/vivado_learing/motor_lynn/iprepo/myip_1.0
} [current_project]
  set_property ip_output_repo e:/Lin/vivado_learing/motor_lynn/motor_lynn.cache/ip [current_project]
  add_files -quiet E:/Lin/vivado_learing/motor_lynn/motor_lynn.runs/synth_1/motor_wrapper.dcp
  read_xdc -ref motor_processing_system7_0_0 -cells inst e:/Lin/vivado_learing/motor_lynn/motor_lynn.srcs/sources_1/bd/motor/ip/motor_processing_system7_0_0/motor_processing_system7_0_0.xdc
  set_property processing_order EARLY [get_files e:/Lin/vivado_learing/motor_lynn/motor_lynn.srcs/sources_1/bd/motor/ip/motor_processing_system7_0_0/motor_processing_system7_0_0.xdc]
  read_xdc -prop_thru_buffers -ref motor_rst_processing_system7_0_100M_0 -cells U0 e:/Lin/vivado_learing/motor_lynn/motor_lynn.srcs/sources_1/bd/motor/ip/motor_rst_processing_system7_0_100M_0/motor_rst_processing_system7_0_100M_0_board.xdc
  set_property processing_order EARLY [get_files e:/Lin/vivado_learing/motor_lynn/motor_lynn.srcs/sources_1/bd/motor/ip/motor_rst_processing_system7_0_100M_0/motor_rst_processing_system7_0_100M_0_board.xdc]
  read_xdc -ref motor_rst_processing_system7_0_100M_0 -cells U0 e:/Lin/vivado_learing/motor_lynn/motor_lynn.srcs/sources_1/bd/motor/ip/motor_rst_processing_system7_0_100M_0/motor_rst_processing_system7_0_100M_0.xdc
  set_property processing_order EARLY [get_files e:/Lin/vivado_learing/motor_lynn/motor_lynn.srcs/sources_1/bd/motor/ip/motor_rst_processing_system7_0_100M_0/motor_rst_processing_system7_0_100M_0.xdc]
  read_xdc E:/Lin/vivado_learing/motor_lynn/motor_lynn.srcs/constrs_1/new/motor.xdc
  link_design -top motor_wrapper -part xc7z020clg484-1
  write_hwdef -file motor_wrapper.hwdef
  close_msg_db -file init_design.pb
} RESULT]
if {$rc} {
  step_failed init_design
  return -code error $RESULT
} else {
  end_step init_design
}

start_step opt_design
set rc [catch {
  create_msg_db opt_design.pb
  opt_design 
  write_checkpoint -force motor_wrapper_opt.dcp
  report_drc -file motor_wrapper_drc_opted.rpt
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
}

start_step place_design
set rc [catch {
  create_msg_db place_design.pb
  implement_debug_core 
  place_design 
  write_checkpoint -force motor_wrapper_placed.dcp
  report_io -file motor_wrapper_io_placed.rpt
  report_utilization -file motor_wrapper_utilization_placed.rpt -pb motor_wrapper_utilization_placed.pb
  report_control_sets -verbose -file motor_wrapper_control_sets_placed.rpt
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
}

start_step route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design 
  write_checkpoint -force motor_wrapper_routed.dcp
  report_drc -file motor_wrapper_drc_routed.rpt -pb motor_wrapper_drc_routed.pb
  report_timing_summary -warn_on_violation -max_paths 10 -file motor_wrapper_timing_summary_routed.rpt -rpx motor_wrapper_timing_summary_routed.rpx
  report_power -file motor_wrapper_power_routed.rpt -pb motor_wrapper_power_summary_routed.pb -rpx motor_wrapper_power_routed.rpx
  report_route_status -file motor_wrapper_route_status.rpt -pb motor_wrapper_route_status.pb
  report_clock_utilization -file motor_wrapper_clock_utilization_routed.rpt
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
}

start_step write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
  catch { write_mem_info -force motor_wrapper.mmi }
  write_bitstream -force motor_wrapper.bit 
  catch { write_sysdef -hwdef motor_wrapper.hwdef -bitfile motor_wrapper.bit -meminfo motor_wrapper.mmi -file motor_wrapper.sysdef }
  catch {write_debug_probes -quiet -force debug_nets}
  close_msg_db -file write_bitstream.pb
} RESULT]
if {$rc} {
  step_failed write_bitstream
  return -code error $RESULT
} else {
  end_step write_bitstream
}

