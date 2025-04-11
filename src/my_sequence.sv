`ifndef MY_SEQUENCE
`define MY_SEQUENCE

`include "uvm_macros.svh"
`include "my_transaction.sv"
import uvm_pkg::*;

class my_sequence extends uvm_sequence#(my_transaction);
	`uvm_object_utils(my_sequence)
	int count=0;
	
	function new(string name="my_sequence");
		super.new(name);
		`uvm_info("my_sequence","the my_sequence new is called!",UVM_LOW)
	endfunction

	task body();

		my_transaction tx;
		tx = my_transaction::type_id::create("tx");
		
		repeat(1) begin
		`uvm_info("my_sequence","the my_sequence body is called!",UVM_LOW)

      		//`uvm_do_with(tx, { tx.inject_error == 0; })
		#100
      		`uvm_do_with(tx, { tx.inject_error == 1; }) 

		/*
		start_item(tx);
		if (!tx.randomize() with { tx.inject_error == 0; }) begin
    		$display("Randomization failed for tx");
		end
		finish_item(tx);

		#100

		start_item(tx);
		if (!tx.randomize() with { tx.inject_error == 1; }) begin
    		$display("Randomization failed for tx");
		end
		$display("tx:",tx.SerDataIn,tx.PalDataIn,tx.inject_error);
		finish_item(tx);
		*/
    		end

	endtask

endclass



`endif