
`ifndef MY_DRIVER
`define MY_DRIVER

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "my_transaction.sv"
`include "rtl_if.sv"


class my_driver extends uvm_driver#(my_transaction);
	`uvm_component_utils(my_driver)
	virtual rtl_if vif;
	//my_transaction req;
	int count=0;

	function new(string name="my_driver",uvm_component parent);
		super.new(name,parent);
		`uvm_info("my_driver","the my_driver new is called!",UVM_LOW)
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual rtl_if)::get(this, "", "rtl_if", vif))
    			`uvm_info("my_driver", "Virtual interface not set",UVM_LOW)
		`uvm_info("my_driver","the my_driver build_phase is called!",UVM_LOW)
	endfunction

	virtual function void connect_phase(uvm_phase phase);
		`uvm_info("my_driver","the my_driver connect_phase is called!",UVM_LOW)
	endfunction

	virtual task run_phase(uvm_phase phase);
		`uvm_info("my_driver","the my_driver run_phase is called!",UVM_LOW)

		forever begin

    		seq_item_port.get_next_item(req);
		drive_packet(req);
    		seq_item_port.item_done();

		count++;
		`uvm_info("my_driver", $sformatf("the count = %0d",count),UVM_LOW)
  		end
	endtask

	task wait_for_rstn();
		//@(posedge vif.rst_n);
		@(posedge vif.clk);
	endtask

	task drive_packet(my_transaction req);
		wait_for_rstn();
		$display("[DIRVER] current time:[%0t ns],req.SerDataIn:%x,req.PalDataIn:%x",$time,req.SerDataIn,req.PalDataIn);
		fork
		send_serial(req);
		send_parallel(req);	
		join
	endtask
	

	task send_serial(my_transaction req);
		`uvm_info("my_driver","the send_serial is called!",UVM_LOW)
		$display("[DIRVER] [%0t ns] req.SerDataIn:%x",$time,req.SerDataIn);

		@(posedge vif.clk);
    		vif.SerDataIn = 0;
    		vif.wait_baud_period();

    		for (int i=0; i<8; i++) begin
      			vif.SerDataIn = req.SerDataIn[i];
      			vif.wait_baud_period();
    		end

    		vif.SerDataIn = req.SerInParity;
    		vif.wait_baud_period();

    		vif.SerDataIn = 1;
    		vif.wait_baud_period();

		`uvm_info("my_driver",$sformatf("send-SerDataIn:%h send-Parity:%h",req.SerDataIn,req.SerInParity),UVM_LOW)
  	endtask


	task send_parallel(my_transaction req);
		`uvm_info("my_driver","the send_parallel is called!",UVM_LOW)
		$display("[DIRVER] [%0t ns] req.PalDataIn:%x",$time,req.PalDataIn);

		vif.wait_baud_period();
		`uvm_info("my_driver",$sformatf("drive_packet, PalDataInPermit=%d",vif.PalDataInPermit),UVM_LOW)
		wait(vif.PalDataInPermit==1);
		`uvm_info("my_driver",$sformatf("drive_packet, PalDataInPermit=%d",vif.PalDataInPermit),UVM_LOW)

		`uvm_info("my_driver",$sformatf("drive_packet vif: %d_%d | %d_%d | %d_%d",
			vif.PalDataOut[7:0],vif.PalDataOutValid,vif.PalDataIn,vif.PalDataInEn,vif.SerDataIn,vif.SerDataOut),UVM_LOW)
	
		
		@(posedge vif.clk);
    		vif.PalDataIn <= req.PalDataIn;
    		vif.PalDataInEn <= 1;

		vif.wait_baud_period();
		vif.PalDataIn <= 0;
    		vif.PalDataInEn <= 0;
		vif.wait_baud_period();

		`uvm_info("my_driver",$sformatf("send-PalDataIn:%h ",req.PalDataIn),UVM_LOW)
	endtask
	
endclass

`endif