`ifndef MY_SCOREBOARD
`define MY_SCOREBOARD

`include "uvm_macros.svh"
`include "my_transaction.sv"
import uvm_pkg::*;


`uvm_analysis_imp_decl(_exp)
`uvm_analysis_imp_decl(_act)
class my_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(my_scoreboard)

  	uvm_analysis_imp_exp #(my_transaction, my_scoreboard) imp_exp;
  	uvm_analysis_imp_act #(my_transaction, my_scoreboard) imp_act;

	my_transaction que_exp[$];
	
	int cnt_err = 0;
  	int cnt_sum = 0;

	function new(string name="",uvm_component parent);
		super.new(name,parent);
	    	imp_exp = new("imp_exp", this);
    		imp_act = new("imp_act", this);

		`uvm_info("my_scoreboard","the my_scoreboard new is called!",UVM_LOW)
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info("my_scoreboard","the my_scoreboard build_phase is called!",UVM_LOW)
	endfunction
	

	function void connect_phase(uvm_phase phase);
		`uvm_info("my_scoreboard","the my_scoreboard connect_phase is called!",UVM_LOW)
	endfunction


	task run_phase(uvm_phase phase);
		`uvm_info("my_scoreboard","the my_scoreboard run_phase is called!",UVM_LOW)
	endtask

`ifndef FUN_SEND
	//go through reference model
  	function void write_exp(my_transaction exp_tr);
		`uvm_info("my_scoreboard-RECV","the my_scoreboard write_exp is called!",UVM_LOW)
    		que_exp.push_back(exp_tr);
  	endfunction

	//go through DUT model
	function void write_act(my_transaction act_tr);
		my_transaction exp_tr;
		`uvm_info("my_scoreboard-RECV","the my_scoreboard write_act is called!",UVM_LOW)
    		
    		if (que_exp.size() == 0) begin
      			`uvm_error("my_scoreboard", "No expected transaction for comparison!")
      			return;
    		end
		else begin
			`uvm_info("my_scoreboard",$sformatf("the size of queue is %d",que_exp.size()),UVM_LOW)
		end

    		exp_tr = que_exp.pop_front();
		cnt_sum++;
    		if (act_tr.inject_error) begin
			`uvm_info("my_scoreboard","inject_error",UVM_LOW)
   		end
		else begin
			`uvm_info("my_scoreboard","not inject_error",UVM_LOW)
      			if (act_tr.PalDataOut[7:0] != exp_tr.PalDataOut[7:0] || act_tr.PalDataOut[8] != exp_tr.PalDataOut[8]) begin
        			`uvm_error("CHECK", $sformatf("Mismatch! Exp: 0x%h_%h, Act: 0x%h_%h",
					exp_tr.PalDataOut, exp_tr.PalDataOut[8], act_tr.PalDataOut, act_tr.PalDataOut[8]))
      				cnt_err++;
				$display("[%0t ns] act_tr.PalDataOut:%x exp_tr.PalDataOut:%x",$time,act_tr.PalDataOut[8:0],exp_tr.PalDataOut[8:0]);
			end
			else begin
				`uvm_info("CHECK","Match",UVM_LOW)
				$display("[%0t ns] act_tr.PalDataOut:%x exp_tr.PalDataOut:%x",$time,act_tr.PalDataOut[8:0],exp_tr.PalDataOut[8:0]);
			end
    		end
  	endfunction
`else
	
	//go through reference model
  	function void write_exp(my_transaction exp_tr);
		`uvm_info("my_scoreboard-SEND","the my_scoreboard write_exp is called!",UVM_LOW)
    		que_exp.push_back(exp_tr);
  	endfunction
	
	//go through DUT model
	function void write_act(my_transaction act_tr);
		my_transaction exp_tr;
		`uvm_info("my_scoreboard-SEND","the my_scoreboard write_act is called!",UVM_LOW)
    		
    		if (que_exp.size() == 0) begin
      			`uvm_error("my_scoreboard", "No expected transaction for comparison!")
      			return;
    		end
		else begin
			`uvm_info("my_scoreboard",$sformatf("the size of queue is %d",que_exp.size()),UVM_LOW)
		end

    		exp_tr = que_exp.pop_front();
		cnt_sum++;
    		if (act_tr.inject_error) begin
			`uvm_info("my_scoreboard","inject_error",UVM_LOW)
   		end
		else begin
			`uvm_info("my_scoreboard","not inject_error",UVM_LOW)
      			if (act_tr.SerDataOut[7:0] != exp_tr.SerDataOut[7:0] || act_tr.SerDataOut[8] != exp_tr.SerDataOut[8]) begin
        			`uvm_error("CHECK", $sformatf("Mismatch! Exp: 0x%h_%h, Act: 0x%h_%h",
					exp_tr.SerDataOut, exp_tr.SerDataOut[8], act_tr.SerDataOut, act_tr.SerDataOut[8]))
      				cnt_err++;

				$display("[%0t ns] act_tr.PalDataOut:%x exp_tr.PalDataOut:%x",$time,act_tr.PalDataOut[8:0],exp_tr.PalDataOut[8:0]);
			end
			else begin
				`uvm_info("CHECK",$sformatf("Match! Exp: 0x%h_%h, Act: 0x%h_%h",
					exp_tr.SerDataOut, exp_tr.SerDataOut[8], act_tr.SerDataOut, act_tr.SerDataOut[8]),UVM_LOW)

				$display("[%0t ns] act_tr.PalDataOut:%x exp_tr.PalDataOut:%x",$time,act_tr.PalDataOut[8:0],exp_tr.PalDataOut[8:0]);
			end
    		end
  	endfunction

`endif
	function void compare(my_transaction tr);
		`uvm_info("my_scoreboard","the my_scoreboard compare is called!",UVM_LOW)
	endfunction

	function void report_phase(uvm_phase phase);
		`uvm_info("SUMMARY", $sformatf("Test cases: %0d, Errors: %0d",cnt_sum, cnt_err), UVM_LOW)
	endfunction

endclass

`endif