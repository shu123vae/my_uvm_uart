`include "uvm_macros.svh"
`include "hello.sv"
import uvm_pkg::*;

class my_rand extends uvm_sequence_item;

    // UVM ??????
    `uvm_object_utils(my_rand)

    rand bit [7:0] data;
    rand bit [3:0] addr;
    rand bit parity;
    rand bit inject_err;

    // ??????
    constraint c_data { data > 10; data < 100; }
    constraint c_addr { addr inside { [10:20], [30:40] }; }
    constraint c_parity {
    	parity == ~^data;
	if(inject_err==1) 
		parity != ~^data;
	} 

endclass


module test;
	my_rand req; 

    	initial begin
	req=new();
	if (req.randomize()) begin
            $display("Randomized data = %d, addr = %h", req.data, req.addr,req.parity);
        end else begin
            $display("Randomization failed");
        end

	`uvm_info("info","hello world,begin",UVM_LOW)
        run_test("hello");
	`uvm_info("info","hello world,end",UVM_LOW)
    	end


	initial begin
	fork  
	pthread1();
	pthread2();
	join_any
	$display("[main][%0t ns]",$time);
	end

	task pthread1();
	#10
	$display("[pthread1] [%0t ns]",$time);
	endtask;

	task pthread2();
	#10
	$display("[pthread2] [%0t ns]",$time);
	endtask;


reg [7:0] mem[0:15];

initial begin
	// ?? $readmemh ???????
        $readmemh("F:/CodePlatform/UVMProject/MyUVM_uart/md.txt", mem);

        // ????????
        $display("Loaded data:");
        foreach (mem[i]) begin
            $display("mem[%0d] = %02h", i, mem[i]);
        end
end
	
endmodule

