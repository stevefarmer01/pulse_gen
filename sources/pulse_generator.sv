`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 01/03/2018 11:04:12 PM
// Design Name:
// Module Name: pulse_generator
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

//To do..
//Input times/clks - signals
//delay/counters - widths and checks that input time not too long - parameters to set widths

`include "pulse_generator_pkg.sv"
import pulse_generator_pkg::*;


module pulse_generator
//    #(
//      parameter reset_delay_c = 3,
//      parameter start_delay_c = 3,
//      parameter pulse_width_c = 3
//    )
    (
    input logic clk,
    input logic reset,
    input logic start,
    output logic pulse_out_s = 0,
    output logic pulse_out_duplicate = 0,
    output logic pulse_out = 0,
    output logic pulse_generator_ready_after_reset
    );


logic [7:0] counter;

always_comb pulse_out_duplicate = pulse_out;

always_comb pulse_out = pulse_out_s;

bit assert_has_failed;
always @(posedge clk) begin
//  if (~assert_has_failed) begin
    assert ((pulse_out_s == pulse_out_duplicate))
        else begin $fatal("outputs 'pulse_out_s' and 'pulse_out_duplicate' functionality not working correctly"); assert_has_failed=1; end
//  end
end
always @(posedge clk) begin
    assert ((pulse_out_s == pulse_out))
        else begin $fatal("outputs 'pulse_out_s' and 'pulse_out' functionality not working correctly"); assert_has_failed=1; end
end

//enum {init_state, start_state, go_state, stop_state} state;
enum {reset_delay_state, init_state, start_state, go_state} state;

// always_ff @(posedge clk) begin
 always_ff @(posedge clk)
    if (reset) begin
//       pulse_out_s <= 0;
       pulse_generator_ready_after_reset = 0;
       counter <= reset_delay_c-1;
       state <= reset_delay_state;
    end else //begin
       case (state)
          reset_delay_state : begin
            if (counter == 0) begin
              pulse_generator_ready_after_reset = 1;
              state <= init_state;
            end
            else counter <= counter-1;
          end
          init_state : begin
            if (start == 1) begin
              if (start_delay_c-1 == 0) begin
                pulse_out_s <= 1;
                counter <= pulse_width_c-1;
                state <= go_state;
              end
              else begin
                counter <= start_delay_c-2;
                state <= start_state;
              end
            end
          end
          start_state : begin
             if (counter == 0) begin
                pulse_out_s <= 1;
                counter <= pulse_width_c-1;
                state <= go_state;
              end
              else counter <= counter-1;
          end
          go_state : begin
             if (counter == 0) begin
                pulse_out_s <= 0;
                state <= init_state;
              end
              else counter <= counter-1;
          end
       endcase
//    end
//end

endmodule
