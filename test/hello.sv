`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

class hello extends uvm_test;
	`uvm_component_utils(hello)

  	function new(string name, uvm_component parent);
    	super.new(name, parent);
    	`uvm_info("CREATE", "my_test component created", UVM_LOW)
  	endfunction

  	function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
    	`uvm_info("BUILD", "my_test build phase executed", UVM_LOW)
  	endfunction

	function void connect_phase(uvm_phase phase);
    	super.connect_phase(phase);
    	`uvm_info("CONNECT", "my_test connect_phase phase executed", UVM_LOW)
  	endfunction

	task run_phase(uvm_phase phase);
    	phase.raise_objection(this);
    	`uvm_info("RUN", "my_test run phase started", UVM_LOW)
    	#10ns; // Wait for 10 nanoseconds
    	`uvm_info("RUN", "my_test run phase finished", UVM_LOW)
    	phase.drop_objection(this);
  	endtask

 	//initial begin
	//`uvm_info("info","hello world,begin!!!",UVM_LOW)
	//#10
	//`uvm_info("info","hello world,end!!!",UVM_LOW)
	//end
endclass