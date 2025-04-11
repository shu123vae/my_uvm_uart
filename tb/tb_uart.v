`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/21 12:54:51
// Design Name: 
// Module Name: tb_uart
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


//~ `New testbench   
`timescale  1ns / 1ps

module tb_Uart;      

// Uart Parameters

//  256000*1*2=0.512MHz=1953.125ns;
//  1/256000=3.90625us=3906.25ns

parameter  CLK_PERIOD=82;	//82,1953
parameter  BIT_PERIOD=3906;
// Uart Inputs
reg   clk                                  = 0 ;
reg   rst_n                                 = 0 ;
reg   SerDataIn                            = 0 ;
reg   [7:0]  PalDataIn                     = 0 ;
reg   PalDataInEn                          = 0 ;

// Uart Outputs
wire  [8:0]  PalDataOut                    ;
wire  PalDataOutValid                      ;
wire  PalDataInPermit                      ;
wire  SerDataOut                           ;



initial
begin
    clk=0;
    forever #(CLK_PERIOD/2)  clk=~clk;
end

initial
begin
    rst_n=0;
    #(CLK_PERIOD*2) rst_n  =  1;
end

Uart  u_Uart (
    .Clk                     ( clk                    ),
    .Rstn                    ( rst_n                   ),
    .SerDataIn               ( SerDataIn              ),
    .PalDataIn               ( PalDataIn        [7:0] ),
    .PalDataInEn             ( PalDataInEn            ),

    .PalDataOut              ( PalDataOut       [8:0] ),
    .PalDataOutValid         ( PalDataOutValid        ),
    .PalDataInPermit         ( PalDataInPermit        ),
    .SerDataOut              ( SerDataOut             )
);


//serial data input
initial
begin
    #10
    repeat(1) begin 
    //3,1
    SerDataIn=0;
    #BIT_PERIOD;

    SerDataIn=1;
    #BIT_PERIOD;
    SerDataIn=1;
    #BIT_PERIOD;
    SerDataIn=0;
    #BIT_PERIOD;
    SerDataIn=0;
    #BIT_PERIOD;

    SerDataIn=1;
    #BIT_PERIOD;
    SerDataIn=0;
    #BIT_PERIOD;
    SerDataIn=0;
    #BIT_PERIOD;
    SerDataIn=0;
    #BIT_PERIOD;

    SerDataIn=0;
    #BIT_PERIOD;
    SerDataIn=1;
    #BIT_PERIOD;

    #39060      //需要足够的间隔

    //5,a
    SerDataIn=0;
    #BIT_PERIOD;

    SerDataIn=1;
    #BIT_PERIOD;
    SerDataIn=0;
    #BIT_PERIOD;
    SerDataIn=1;
    #BIT_PERIOD;
    SerDataIn=0;
    #BIT_PERIOD;

    SerDataIn=0;
    #BIT_PERIOD;
    SerDataIn=0;
    #BIT_PERIOD;
    SerDataIn=1;
    #BIT_PERIOD;
    SerDataIn=1;
    #BIT_PERIOD;

    SerDataIn=1;
    #BIT_PERIOD;
    SerDataIn=1;
    #BIT_PERIOD;
    end

    //$finish;
end


//paraller data input
initial
    begin
        #10
        repeat(1)begin
            wait(PalDataInPermit==1);
            PalDataInEn=1;
            PalDataIn=8'hc1;  
            #BIT_PERIOD;
            PalDataInEn=0;
            #BIT_PERIOD;
        end

        repeat(1)begin
        wait(PalDataInPermit==1);
            PalDataInEn=1;
            PalDataIn=8'ha3;  
            #BIT_PERIOD;
            PalDataInEn=0;
            #BIT_PERIOD;
        end
    end

endmodule