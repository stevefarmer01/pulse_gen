////-------------------------------------------------------------------------
////				www.verificationguide.com   testbench.sv
////-------------------------------------------------------------------------
////tbench_top or testbench top, this is the top most file, in which DUT(Design Under Test) and Verification environment are connected.
////-------------------------------------------------------------------------
//
////including interfcae and testcase files
//`include "interface.sv"
//
////-------------------------[NOTE]---------------------------------
////Particular testcase can be run by uncommenting, and commenting the rest
//`include "random_test.sv"
////`include "directed_test.sv"
////----------------------------------------------------------------

`timescale 1ns / 1ps

`include "pulse_generator_pkg.sv"
import pulse_generator_pkg::*;

module tbench_top
//  #(  
//  )
  ();

  localparam clk_period_lp = 10ns;
  //clock and reset signal declaration
  bit clk = 1;
  bit reset;
  bit start;
  bit pulse_out;
  bit pulse_generator_ready_after_reset;
  bit start_asyn;
  bit reset_asyn;
  bit pulse_out_asyn;
  bit pulse_generator_ready_after_reset_asyn;
//  localparam  clk_period_lp = 10ns;
//  const time clk_period_lp = 10ns;
//  parameter time clk_period_lp = 10ns;

  initial
  //shall print %t with scaled in ns (-9), with 2 precision digits, and would print the " ns" string
    $timeformat(-9, 2, " ns", 20);
  //clock generation
  always begin
    time half_clk_period = clk_period_lp/2;
    #half_clk_period clk = ~clk;
  end
  //forever #5 clk = !clk;

  //reset Generation
  initial begin
    reset_asyn = 1;
    #100;
    @(posedge clk); //Syncronise reset to clk
    reset_asyn =0;
    #100;
    @(posedge clk); //Syncronise start pulse to clk
    start_asyn =1;
    #20 start_asyn =0;
  end

bit enable;
bit reset_pulse_gen_bfm = 1;
  //pulse_gen_bfm_inst test
  initial begin
    reset_pulse_gen_bfm = 1;
    #45;
    reset_pulse_gen_bfm = 0;
    enable = 1;
    #40;
    enable = 0;
    #10;
    enable = 1;
    #40;
    reset_pulse_gen_bfm = 1;
    #17
    reset_pulse_gen_bfm = 0;
    #4;
    reset_pulse_gen_bfm = 1;
    #4
    reset_pulse_gen_bfm = 0;
    enable = 1;
  end

  pulse_gen_bfm
    #(
      .active_time_p(20ns),
      .non_active_time_p(5ns)
      )
      pulse_gen_bfm_inst (
      .reset(reset_pulse_gen_bfm),
      .enable(enable),
      .pulse_gen_output(pulse_gen_output)
      );

  pulse_gen_bfm
    #(
      .active_time_p(20ns),
      .non_active_time_p(5ns)
      )
      pulse_gen_bfm_inst_1 (
      .reset(reset_pulse_gen_bfm),
      .enable(1'b1),
      .pulse_gen_output(pulse_gen_output_1)
      );

//Need a delay so that behav and func/synth simulations agree on times from reset and activate (pulse widths always the same)
  always_comb begin  //  always_ff @(posedge clk) begin
    start <= start_asyn;
    reset <= reset_asyn;
    pulse_out <= pulse_out_asyn;
    pulse_generator_ready_after_reset <= pulse_generator_ready_after_reset_asyn;
  end

// Next tasks....
// Asserts to check for 0 values
// Check times divided by clk_period_lp
// Repeat pulses

  pulse_generator //#()
    dut(
      .clk(clk),
      .reset(reset),
      .start(start),
      .pulse_out(pulse_out_asyn),
      .pulse_out_s(open),
      .pulse_out_duplicate(open),
      .pulse_generator_ready_after_reset(pulse_generator_ready_after_reset_asyn)
      );

time reset_release_time, pulse_generator_ready_time_after_reset, pulse_active_time_after_reset, pulse_deactivates_time_after_reset, pulse_activate, pulse_active, pulse_generator_ready_after_reset_time, start_pulse_active_time_after_reset;
bit start_timing_checks = 0;
bit tests_pass = 1;

  initial begin
//post and impl timing fails might need to scronise below to clk
    @(negedge reset);
    $display("Reset deactives at %t", $time);
    reset_release_time = $time;
    @(posedge pulse_generator_ready_after_reset);
    pulse_generator_ready_time_after_reset = $time-reset_release_time;
    @(posedge start)
    $display("start pulse active at %t", $time);
    start_pulse_active_time_after_reset = $time-reset_release_time;
    @(posedge pulse_out);
    $display("pulse_out goes high at %t", $time);
    pulse_active_time_after_reset = $time-reset_release_time;
    @(negedge pulse_out);
    $display("pulse_out goes low at %t", $time);
    pulse_deactivates_time_after_reset = $time-reset_release_time;
//Calculate times
    pulse_activate = pulse_active_time_after_reset-start_pulse_active_time_after_reset;
    pulse_active = pulse_deactivates_time_after_reset-pulse_active_time_after_reset;
    $display("Time from reset that pulse_generator ready %t", pulse_generator_ready_time_after_reset);
    $display("Time to pulse activate %t", pulse_activate);
    $display("Period pulse active for %t", pulse_active);
    #20;
//Check times
    start_timing_checks = 1;
  end

  initial begin
    @(posedge start_timing_checks)
    if (pulse_generator_ready_time_after_reset != (reset_delay_c*clk_period_lp)) tests_pass = 0;
    if (pulse_activate != (start_delay_c*clk_period_lp)) tests_pass = 0;
    if (pulse_active != (pulse_width_c*clk_period_lp)) tests_pass = 0;
    #20;
    if (tests_pass) $display("#### ALL TESTS PASS ####"); else $display("#### TESTS FAIL ####");
    $finish;
  end

  initial begin
    #1000;
    $display("FAIL - testbench.sv timed out");
    $finish;
  end

//  //creatinng instance of interface, inorder to connect DUT and testcase
//  intf i_intf(clk,reset);
//
//  //Testcase instance, interface handle is passed to test as an argument
//  test t1(i_intf);
//
//  //DUT instance, interface signals are connected to the DUT ports
//  adder DUT (
//    .clk(i_intf.clk),
//    .reset(i_intf.reset),
//    .a(i_intf.a),
//    .b(i_intf.b),
//    .valid(i_intf.valid),
//    .c(i_intf.c)
//   );
//
//  //enabling the wave dump
//  initial begin
//    $dumpfile("dump.vcd"); $dumpvars;
//  end
endmodule
