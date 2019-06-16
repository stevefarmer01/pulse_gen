//Reset has to wait for current wait active_time or non_active_time to finish before zero times are enforced
`timescale 1ns / 1ps

module pulse_gen_bfm
  #(
    parameter time active_time_p = 100ns,
    parameter time non_active_time_p = 100ns
    )
    (
    input bit reset = 0,
    input bit enable,
    output bit pulse_gen_output
    );

    bit pulse = 0;
    //time active_time, non_active_time;

//always_comb begin
//  active_time = (~reset) ? active_time_p : 0ns;
//  non_active_time = (~reset) ? non_active_time_p : 0ns;
//end

always begin
  @(posedge reset);
  disable pulse_block;
end

always begin : pulse_block
  pulse = 0;
  wait(~reset);
  pulse = 1;
  #active_time_p;
  pulse = 0;
  #non_active_time_p;
end

always_comb begin
pulse_gen_output = (enable) ? pulse : 0;
//  pulse_gen_output = (enable) ? pulse : pulse;
end

//assert final (^s1 !== '0);
//assert final (pulse_gen_output != pulse_gen_output);
assert final (!(!enable && pulse_gen_output))
      else $fatal("enable functionality not working correctly") ;
//always  a: assert (pulse_gen_output == pulse_gen_output) ;
//always  a: assert (!(~pulse_gen_output && pulse_gen_output));
//assert (pulse_gen_output == pulse_gen_output) ;
//assert (pulse_gen_output == pulse_gen_output) $display ("OK. A equals B");

//event active_end; //declaring event ev_1
//event non_active_end; //declaring event ev_1
//event reset_active;
//event reset_deactive;
//
//bit non_active_triggered = 0;
//bit active_triggered = 0;
//
//initial begin
//  fork
//
//  begin
//  forever begin
//    @(posedge reset);
//    ->active_end;
//    end
//  end
//
//  begin
//  forever begin
//    @(posedge reset);
//    ->reset_active;
//    end
//  end
//
//  begin
//  forever begin
//    @(posedge reset);
//    ->non_active_end;
//    end
//  end
//
//  begin
//  forever begin
//    @(negedge reset);
//    ->reset_deactive;
//    end
//  end
//
//  begin
//  forever begin
//  @(active_end)
//  active_triggered = 1;
//  #1ns;
//  active_triggered = 0;
//  end
//  end
//
//  begin
//  forever begin
//  @(active_end)
//  non_active_triggered = 1;
//  #1ns;
//  non_active_triggered = 0;
//  end
//  end
//
//  begin
//  forever begin
//    wait(reset == 0);
//    #active_time_p;
//    //$display($time,"\tTriggering active_end ################################");
//    ->active_end;
//    @(non_active_end);
//  end
//  end
//
//  begin
//  forever begin
//  wait(reset == 0);
//    @(active_end);
//    #non_active_time_p;
//    //$display($time,"\tTriggering non_active_end ################################");
//    ->non_active_end;
//  end
//  end
//
//  begin
//    forever begin
////      fork begin
////      fork
//      begin
//        wait(reset == 0);
//        pulse = 1;
//        @(active_end or reset_active);
//        pulse = 0;
//        @(non_active_end or reset_deactive);
//      end
//      begin
//        @(reset_active);
//      end
//      join_any
//      disable fork; // vivado 2016.4 XSIM - The "System Verilog disable fork" is not supported yet for simulation.
//      end join //; might or might not need semi-colon
//    end
//  end
//
//  join
//end


endmodule
