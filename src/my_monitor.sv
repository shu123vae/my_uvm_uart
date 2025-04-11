`ifndef MY_MONITOR
`define MY_MONITOR

`include "uvm_macros.svh"
`include "my_transaction.sv"
`include "rtl_if.sv"
import uvm_pkg::*;

class my_monitor extends uvm_monitor;
	`uvm_component_utils(my_monitor)
	virtual rtl_if vif;
	uvm_analysis_port #(my_transaction) ap_mdl;
	uvm_analysis_port #(my_transaction) ap_scb;
	
	function new(string name="",uvm_component parent);
		super.new(name,parent);
		ap_mdl=new("ap_mdl",this);
		ap_scb=new("ap_scb",this);
		`uvm_info("my_monitor","the my_monitor new is called!",UVM_LOW)
	endfunction
	
	function void build_phase(uvm_phase phase);
		`uvm_info("my_monitor","the my_monitor build_phase is called!",UVM_LOW)
		if(!uvm_config_db#(virtual rtl_if)::get(this,"","rtl_if",vif))	
			`uvm_info("my_monitor", "Virtual interface not set",UVM_LOW)
	endfunction

	function void connect_phase(uvm_phase phase);
		`uvm_info("my_monitor","the my_monitor connect_phase is called!",UVM_LOW)
	endfunction

	task run_phase(uvm_phase phase);
		`uvm_info("my_monitor","the my_monitor run_phase is called!",UVM_LOW)
		$display("[MONITOR] current time:[%0t ns]",$time);
`ifndef FUN_SEND
		`uvm_info("my_monitor","the my_monitor monitor_recv is called!",UVM_LOW)
		monitor_recv();
`else
		`uvm_info("my_monitor","the my_monitor monitor_send is called!",UVM_LOW)
		monitor_send();
`endif
	endtask

	task monitor_recv();
		fork
      		monitor_recv_serial();
      		monitor_recv_parallel();
    		join
	endtask


	task monitor_send();
		fork
      		monitor_send_serial();
      		monitor_send_parallel();
    		join
		wait fork;
	endtask

  	task monitor_recv_serial();
    		`uvm_info("my_monitor RECV","the my_monitor monitor_recv_serial is called!",UVM_LOW)
		forever begin
			my_transaction tr = my_transaction::type_id::create("tr");

			wait(vif.SerDataIn==1);
			@(negedge vif.SerDataIn);
			vif.wait_baud_half_period();	
	
			for(int i=0;i<8;i++)begin
				vif.wait_baud_period();
				tr.SerDataIn[i]=vif.SerDataIn;
			end
			
			vif.wait_baud_period();
			tr.SerInParity=vif.SerDataIn;	//check
	
			vif.wait_baud_period();		//stop
			
			if(vif.SerDataIn==1)begin
				ap_mdl.write(tr);
				`uvm_info("my_monitor",$sformatf("SerDataIn:%h Parity:%h",tr.SerDataIn,tr.SerInParity),UVM_LOW)
				
				$display("[MONITOR] [%0t ns] tr.SerDataIn:%x ",$time,tr.SerDataIn[7:0]);
			end
			else begin
				`uvm_error("my_monitor",$sformatf("ERROR,SerDataIn:%h Parity:%h",tr.SerDataIn,tr.SerInParity))
			end
			
		end
  	endtask


	task monitor_recv_parallel();
		`uvm_info("my_monitor RECV","the my_monitor monitor_recv_parallel is called!",UVM_LOW)
    		
		forever begin
		my_transaction tr = my_transaction::type_id::create("tr");

		`uvm_info("my_monitor",$sformatf("monitor-begin:parallel_out:%h_%h_%h / parallel_in:%h_%h_%h",
			vif.PalDataOut[7:0],vif.PalDataOut[8],vif.PalDataOutValid,
			vif.PalDataIn,vif.PalDataInEn,vif.SerDataOut),UVM_LOW)

      		@(posedge vif.PalDataOutValid);
	
		`uvm_info("my_monitor",$sformatf("monitor-end:parallel_out:%h_%h_%h / parallel_in:%h_%h_%h",
			vif.PalDataOut[7:0],vif.PalDataOut[8],vif.PalDataOutValid,
			vif.PalDataIn,vif.PalDataInEn,vif.SerDataOut),UVM_LOW)
			
      		tr.PalDataOut       = vif.PalDataOut[8:0];
	
		`uvm_info("my_monitor",$sformatf("mon-PalDataOut:%h",tr.PalDataOut),UVM_LOW)
		ap_scb.write(tr);

		$display("[MONITOR] [%0t ns] tr.PalDataOut:%x ",$time,tr.PalDataOut[8:0]);
    		end
  	endtask


	task monitor_send_serial();
		`uvm_info("my_monitor SEND","the my_monitor monitor_send_serial is called!",UVM_LOW)
		forever begin
			my_transaction tr = my_transaction::type_id::create("tr");
			wait(vif.SerDataOut==1);
			@(negedge vif.SerDataOut);
			vif.wait_baud_half_period();
		
			for(int i=0;i<8;i++)begin
				vif.wait_baud_period();
				tr.SerDataOut[i]=vif.SerDataOut;
			end
			
			vif.wait_baud_period();		//check
			tr.SerDataOut[8]=vif.SerDataOut;	

			vif.wait_baud_period();		//stop

			if(vif.SerDataOut==1)begin
				ap_scb.write(tr);
				`uvm_info("my_monitor",$sformatf("SerDataOut:%h Parity:%h",tr.SerDataOut[7:0],tr.SerDataOut[8]),UVM_LOW)
			
				$display("[MONITOR] [%0t ns] tr.SerDataOut:%x ",$time,tr.SerDataOut[8:0]);
			end
			else begin
				`uvm_error("my_monitor",$sformatf("ERROR,SerDataOut:%h Parity:%h",tr.SerDataOut[7:0],tr.SerDataOut[8]))
			end
		end
	endtask

	task monitor_send_parallel();	
		`uvm_info("my_monitor SEND","the my_monitor monitor_send_parallel is called!",UVM_LOW)
		forever begin
		my_transaction tr = my_transaction::type_id::create("tr");

		@(posedge vif.PalDataInEn);
	
		tr.PalDataIn=vif.PalDataIn;

		ap_mdl.write(tr);
		`uvm_info("my_monitor",$sformatf("PalDataIn:%h ",tr.PalDataIn),UVM_LOW)

		$display("[MONITOR] [%0t ns] tr.PalDataIn:%x ",$time,tr.PalDataIn[7:0]);
		end
	endtask

   	function void write_input(my_transaction tr);
        	`uvm_info("my_monitor","the my_monitor write_input is called!",UVM_LOW)
    	endfunction

   	function void write_output(my_transaction tr);
        	`uvm_info("my_monitor","the my_monitor write_output is called!",UVM_LOW)
    	endfunction
endclass


`endif