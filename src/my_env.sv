`ifndef MY_ENV
`define MY_ENV

`include "uvm_macros.svh"
`include "my_agent.sv"
`include "my_scoreboard.sv"
`include "my_model.sv"
import uvm_pkg::*;

class my_env extends uvm_env;
	`uvm_component_utils(my_env)
  	my_agent	agent;
	my_scoreboard	scoreboard;
	my_model	model;
  	extern function new(string name, uvm_component parent);
  	extern function void build_phase(uvm_phase phase);
  	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

function my_env::new(string name, uvm_component parent);
  	super.new(name, parent);
	`uvm_info("my_env","the my_env new is called!",UVM_LOW)
endfunction

function void my_env::build_phase(uvm_phase phase);
	super.build_phase(phase);
	agent = my_agent::type_id::create("agent", this);
	scoreboard = my_scoreboard::type_id::create("scoreboard", this);
	model = my_model::type_id::create("model", this);
	`uvm_info("my_env","the my_env build_phase is called!",UVM_LOW)
endfunction

function void my_env::connect_phase(uvm_phase phase);
	agent.monitor.ap_mdl.connect(model.imp);
	agent.monitor.ap_scb.connect(scoreboard.imp_act);
	model.ap.connect(scoreboard.imp_exp);
	`uvm_info("my_env","the my_env connect_phase is called!",UVM_LOW)
endfunction

task my_env::run_phase(uvm_phase phase);
	`uvm_info("my_env","the my_env run_phase is called!",UVM_LOW)
endtask

`endif