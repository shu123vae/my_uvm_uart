`ifndef MY_TRANSACTION
`define MY_TRANSACTION

`define FUN_SEND

`include "uvm_macros.svh"
import uvm_pkg::*;

class my_transaction extends uvm_sequence_item;
	

	rand bit [7:0] SerDataIn;	//in
	rand bit SerInParity;		//in
	rand bit inject_error;	//in
	bit [8:0] PalDataOut;	//out
	bit PalDataOutValid;	//out


	rand bit [7:0] PalDataIn;//in
	bit PalDataInEn;	//in
	bit PalDataInPermit;	//out
	bit [8:0] SerDataOut;	//out


constraint c_parity{
	
    SerDataIn dist {90:=1,195:=1};		//0xc3=195,0x5a=90
    PalDataIn dist {60:=1,165:=1};		//0x3c=60,0xa5=165

    
    if (inject_error) 
	SerInParity != ~^SerDataIn;
    else
	SerInParity == ~^SerDataIn;
}

`uvm_object_utils_begin(my_transaction)
	`uvm_field_int(SerDataIn,UVM_ALL_ON)
	`uvm_field_int(PalDataOut,UVM_ALL_ON)
	`uvm_field_int(PalDataOutValid,UVM_ALL_ON)
	`uvm_field_int(PalDataIn, UVM_ALL_ON)
	`uvm_field_int(PalDataInEn, UVM_ALL_ON)	
	`uvm_field_int(PalDataInPermit, UVM_ALL_ON)
	`uvm_field_int(SerDataOut, UVM_ALL_ON)
`uvm_object_utils_end

function new(string name="my_transaction");
	super.new(name);
	`uvm_info("my_transaction","the my_transaction new is called!",UVM_LOW)
endfunction

endclass

`endif