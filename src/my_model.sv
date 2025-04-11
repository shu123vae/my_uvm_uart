 `timescale 1ns/1ps

`ifndef MY_MODEL
`define MY_MODEL


 
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "my_transaction.sv"

class my_model extends uvm_component;
  uvm_analysis_imp #(my_transaction, my_model) imp;
  uvm_analysis_port #(my_transaction) ap;

  `uvm_component_utils(my_model)

function new(string name, uvm_component parent);
	super.new(name, parent);
	imp = new("imp", this);
	ap  = new("ap", this);
	`uvm_info("my_model","the my_model new is called!",UVM_LOW)
endfunction


function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	`uvm_info("my_model","the my_model build_phase is called!",UVM_LOW)
endfunction

function void write(my_transaction tr);
    	my_transaction exp_tr;
	`uvm_info("my_model","the my_model write is called!",UVM_LOW)
    	exp_tr = my_transaction::type_id::create("exp_tr");

`ifndef FUN_SEND
	`uvm_info("my_model","the my_model FUN_RECV is called!",UVM_LOW)
    	exp_tr.PalDataOut[7:0]   = tr.SerDataIn;
    	exp_tr.PalDataOut[8] = ~^tr.SerDataIn;
    	exp_tr.PalDataOutValid=1;
`else
	`uvm_info("my_model","the my_model FUN_SEND is called!",UVM_LOW)
	exp_tr.SerDataOut[7:0]=tr.PalDataIn;
	exp_tr.SerDataOut[8]=~^tr.PalDataIn;
	
	assert(~^tr.PalDataIn==0)
		else `uvm_error("my_model",$sformatf("tr.PalDataIn_^tr.PalDataIn:0x%h_%h",tr.PalDataIn,^tr.PalDataIn))
`endif

	ap.write(exp_tr);
endfunction
endclass

`endif