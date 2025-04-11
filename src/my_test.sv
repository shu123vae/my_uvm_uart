`ifndef MY_TEST
`define MY_TEST
`timescale 1ns/1ps

`include "uvm_macros.svh"
`include "my_sequence.sv"
`include "my_env.sv"
import uvm_pkg::*;

class my_test extends uvm_test;
	`uvm_component_utils(my_test)
	my_env env;	

  	extern function new(string name="my_test", uvm_component parent);
  	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
  	extern task run_phase(uvm_phase phase);
	extern function void report_phase(uvm_phase phase);
endclass

function my_test::new(string name="my_test", uvm_component parent);
	super.new(name, parent);
	`uvm_info("my_test","the my_test new is called!",UVM_LOW)
endfunction

function void my_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	env = my_env::type_id::create("env", this);
	`uvm_info("my_test","the my_test build_phase is called!",UVM_LOW)
endfunction

function void my_test::connect_phase(uvm_phase phase);
	`uvm_info("my_test","the my_test connect_phase is called!",UVM_LOW)
endfunction

task my_test::run_phase(uvm_phase phase);
  	my_sequence seq;
	`uvm_info("my_test","the my_test run_phase is called, begin!",UVM_LOW)
  	phase.raise_objection(this);
  	seq = my_sequence::type_id::create("seq");
	wait(env.agent.driver.vif.rst_n == 1);
  	
	seq.start(env.agent.sequencer);
	#100000
  	phase.drop_objection(this);
	`uvm_info("my_test","the my_test run_phase is called, end!",UVM_LOW)
endtask


function void my_test::report_phase(uvm_phase phase);
   uvm_report_server server;
   int err_num;

   super.report_phase(phase);

   server = get_report_server();
   err_num = server.get_severity_count(UVM_ERROR);

   if (err_num != 0) begin
      $display("TEST CASE FAILED");
   end
   else begin
      $display("TEST CASE PASSED");
   end

endfunction


`endif