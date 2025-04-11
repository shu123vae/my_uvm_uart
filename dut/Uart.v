`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/12 13:02:54
// Design Name: 
// Module Name: Uart
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


module Uart(
	input Clk,
	input Rstn,

	input SerDataIn,

	output reg [8:0] PalDataOut,
	output PalDataOutValid,


	input [7:0] PalDataIn,
	input PalDataInEn,
	output PalDataInPermit,

	output reg SerDataOut

	// output	[1:0]	Monitor_GateClkCnt,
	// output	Monitor_GateClk,
	// output	[3:0]	Monitor_RxBitCnt,
	// output	[2:0] 	Monitor_RxState,
	// output	[2:0] 	Monitor_nRxState,
	// output  [3:0] 	Monitor_RxSampleCnt,
	// output  [3:0] 	Monitor_nRxSampleCnt
	);
	


	reg SerDataInSync1,SerDataInSync2,SerDataInSync3;
	reg Parity;
	reg [2:0] RxState;
	reg [1:0] GateClkCnt;
	reg GateClk;
	reg [3:0] RxSampleCnt;
	reg [3:0] RxBitCnt;
	reg [3:0] TxState;
	reg [3:0] TxBitExtCnt;
	reg [7:0] PalDataTemp;
	reg [2:0] TxBitCnt;
	reg TxBusy;
	reg PalDataOutValidReg;

	localparam StRxIdle=3'd0;
	localparam StRxStartCheck=3'd1;
	localparam StRxBit=3'd2;
	localparam StRxGap=3'd3;
	localparam StRxStp=3'd4;
	
	localparam StTxIdle=3'd0;
	localparam StTxStartBit=3'd1;
	localparam StTxBit=3'd2;
	localparam StTxParity=3'd3;
	localparam StTxStpBit=3'd4;
	localparam StTxIntervl=3'd5;
	
	// assign	Monitor_GateClkCnt=GateClkCnt;
	// assign	Monitor_GateClk=GateClk;
	// assign	Monitor_RxBitCnt=RxBitCnt;
	// assign	Monitor_RxState=RxState;
	// assign	Monitor_nRxState=nRxState;
	// assign	Monitor_RxSampleCnt=RxSampleCnt;
	// assign	Monitor_nRxSampleCnt=nRxSampleCnt;
//==================================================

	reg	[1:0] nGateClkCnt;
	reg nGateClk;
	always@(posedge Clk or negedge Rstn)begin
		if(!Rstn)begin
			GateClkCnt<=2'd0;
			GateClk<=1'd0;
		end
		else begin
			GateClkCnt<=nGateClkCnt;
			GateClk<=nGateClk;
		end
	end
		
	always@(*)begin
		if(GateClkCnt>=2'd2)begin
			nGateClkCnt=2'd0;
			nGateClk=1'd1;
		end
		else begin
			nGateClkCnt=GateClkCnt+1'd1;
			nGateClk=1'd0;
		end
	end

//-----------------------

	// always@(posedge Clk or negedge Rstn)begin
	// 	if(!Rstn)begin
	// 		GateClkCnt<=2'd0;
	// 		GateClk<=1'd0;
	// 		end
	// 	else begin
	// 		if(GateClkCnt>=2'd2)begin		
	// 			GateClkCnt<=2'd0;
	// 			GateClk<=1'b1;
	// 			end
	// 		else begin
	// 			GateClkCnt<=GateClkCnt+2'd1;
	// 			GateClk<=1'b0;
	// 			end			
	// 		end
	// 	end
	
//==================================================

	reg nSerDataInSync1;
	reg nSerDataInSync2;
	reg nSerDataInSync3;

	always@(posedge Clk or negedge Rstn)begin
		if(!Rstn)begin
			SerDataInSync1<=1'b1;
			SerDataInSync2<=1'b1;
			SerDataInSync3<=1'b1;
		end
		else begin
			SerDataInSync1<=nSerDataInSync1;
			SerDataInSync2<=nSerDataInSync2;
			SerDataInSync3<=nSerDataInSync3;
		end
	end

	always@(*)begin
		nSerDataInSync1=SerDataIn;
		nSerDataInSync2=SerDataInSync1;
		nSerDataInSync3=SerDataInSync2;
	end

//------------------------------

	// always@(posedge Clk or negedge Rstn)begin
	// 	if(!Rstn)begin
	// 		SerDataInSync1<=1'b1;
	// 		SerDataInSync2<=1'b1;
	// 		SerDataInSync3<=1'b1;
	// 		end
	// 	else begin
	// 		SerDataInSync1<=SerDataIn;
	// 		SerDataInSync2<=SerDataInSync1;
	// 		SerDataInSync3<=SerDataInSync2;						
	// 		end
	// 	end

// ==================================================

	reg [2:0] nRxState;
	reg [3:0] nRxSampleCnt;
	reg [3:0] nRxBitCnt;
	reg [8:0] nPalDataOut;
	reg nPalDataOutValidReg;


	always@(posedge Clk or negedge Rstn)begin
		if(!Rstn)begin
			RxState<=3'd0;
			RxSampleCnt<=4'd0;
			RxBitCnt<=4'd0;
			PalDataOut<=9'd0;
			PalDataOutValidReg<=1'b0;					
		end
		else begin
			RxState<=nRxState;
			RxSampleCnt<=nRxSampleCnt;
			RxBitCnt<=nRxBitCnt;
			PalDataOut<=nPalDataOut;
			PalDataOutValidReg<=nPalDataOutValidReg;	
		end
	end


	task task_default_rx;
		begin
			nRxState=RxState;
			nRxSampleCnt=RxSampleCnt;
			nRxBitCnt=RxBitCnt;
			nPalDataOut=PalDataOut;
			nPalDataOutValidReg=PalDataOutValidReg;	
		end
	endtask


	always@(*)begin
		task_default_rx;
		if(GateClk)begin
			case(RxState)
				StRxIdle:begin
					if(SerDataInSync3==1'b0)begin
						nRxState=StRxStartCheck;
						nRxSampleCnt=4'd0;
					end
					else begin
						nRxState=StRxIdle;
						nRxSampleCnt=4'd0;
					end
					nPalDataOutValidReg=1'b0;
					nRxBitCnt=4'd0;
					nPalDataOut=9'd0;
					end					
				StRxStartCheck:begin
					if(RxSampleCnt==4'd7)begin
						if(SerDataInSync3==1'b1)begin
							nRxState=StRxIdle;
							end
						else begin
							nRxState=StRxBit;
							end
						nRxSampleCnt=4'd0;
						end	
					else begin						
						nRxSampleCnt=RxSampleCnt+4'd1;
						nRxState=StRxStartCheck;		//
					end		
					nRxBitCnt=4'd0;
					nPalDataOut=9'd0;
					nPalDataOutValidReg=1'b0;
					end	

				StRxBit:begin
					if(RxSampleCnt==4'd15)begin
						if(RxBitCnt<=4'd7)begin
							nPalDataOut={SerDataInSync3,PalDataOut[8:1]};
							nRxBitCnt=RxBitCnt+4'd1;
							nRxState=StRxBit;
						end
						else begin 
							nPalDataOut={SerDataInSync3,PalDataOut[8:1]};
							nRxBitCnt=4'd0;
							nRxState=StRxGap;							
							end
						end
					nRxSampleCnt=RxSampleCnt+4'd1;
					nPalDataOutValidReg=1'b0;

					end		
															
				StRxGap:begin
					if(RxSampleCnt>=4'd0)begin
						nRxState=StRxStp;
						nRxSampleCnt=4'd0;
						end
					else begin
						nRxState=StRxGap;		//
						nRxSampleCnt=RxSampleCnt+4'd1;
					end
					nRxBitCnt=4'd0;
					nPalDataOutValidReg=1'b0;

					end	

				StRxStp:begin
					if(RxSampleCnt>=4'd15)begin	
						nRxState=StRxIdle;
						nPalDataOutValidReg=1'b1;
					end
					else begin				//
						nRxState=StRxStp;
						nPalDataOutValidReg=1'b0;
					end
					nRxSampleCnt=RxSampleCnt+4'd1;
					nRxBitCnt=9'd0;

					end
																
				default:begin
					nRxState=StRxIdle;
					nRxSampleCnt=4'd0;
					nRxBitCnt=4'd0;
					nPalDataOut=9'd0;
					nPalDataOutValidReg=1'b0;					
					end
				endcase
		end
	end

//-----------------------------------------

	// always@(posedge Clk or negedge Rstn)begin
	// 	if(!Rstn)begin
	// 		RxState<=StRxIdle;
	// 		RxSampleCnt<=4'd0;
	// 		RxBitCnt<=4'd0;
	// 		PalDataOut<=9'd0;
	// 		PalDataOutValidReg<=1'b0;					
	// 		end			
	// 	else if(GateClk) begin
	// 	// else begin		
	// 		case(RxState)
	// 			StRxIdle:begin
	// 				if(SerDataInSync3==1'b0)begin
	// 					RxState<=StRxStartCheck;
	// 					RxSampleCnt<=4'd0;
	// 					end
	// 				PalDataOutValidReg<=1'b0;
	// 				end					
	// 			StRxStartCheck:begin
	// 				if(RxSampleCnt==4'd7)begin
	// 					if(SerDataInSync3==1'b1)begin
	// 						RxState<=StRxIdle;
	// 						end
	// 					else begin
	// 						RxState<=StRxBit;
	// 						end
	// 					RxSampleCnt<=4'd0;
	// 					end	
	// 				else begin						
	// 					RxSampleCnt<=RxSampleCnt+4'd1;
	// 					end						
	// 				end																										
	// 			StRxBit:begin
	// 				if(RxSampleCnt==4'd15)begin
	// 					if(RxBitCnt<=4'd7)begin
	// 						PalDataOut<={SerDataInSync3,PalDataOut[8:1]};
	// 						RxBitCnt<=RxBitCnt+4'd1;
	// 						end
	// 					else begin 
	// 						PalDataOut<={SerDataInSync3,PalDataOut[8:1]};
	// 						RxBitCnt<=4'd0;
	// 						RxState<=StRxGap;							
	// 						end
	// 					end
	// 				RxSampleCnt<=RxSampleCnt+4'd1;
	// 				end		
															
	// 			StRxGap:begin
	// 				if(RxSampleCnt>=4'd0)begin
	// 					RxState<= StRxStp;
	// 					RxSampleCnt<=4'd0;
	// 					end
	// 				else begin
	// 					RxSampleCnt<=RxSampleCnt+4'd1;
	// 					end
	// 				end	

	// 			StRxStp:begin
	// 				if(RxSampleCnt>=4'd15)begin	
	// 					RxState<=StRxIdle;
	// 					PalDataOutValidReg<=1'b1;
	// 					end
	// 				RxSampleCnt<=RxSampleCnt+4'd1;				
	// 				end
																
	// 			default:begin
	// 				RxState<=StRxIdle;
	// 				RxSampleCnt<=4'd0;
	// 				RxBitCnt<=4'd0;
	// 				PalDataOut<=9'd0;
	// 				PalDataOutValidReg<=1'b0;					
	// 				end
	// 			endcase
	// 		end
	// 	end


//==================================================

	reg [3:0]	nTxState;
	reg [3:0]	nTxBitExtCnt;
	reg [2:0]	nTxBitCnt;
	reg nSerDataOut;
	reg [7:0]	nPalDataTemp;
	reg nTxBusy;
	reg nParity;

	always@(posedge Clk or negedge Rstn)begin
		if(!Rstn)begin
				TxState<=4'd0;
				TxBitExtCnt<=4'd0;
				TxBitCnt<=3'd0;
				SerDataOut<=1'b1;
				PalDataTemp<=8'd0;
				TxBusy<=1'b0;
				Parity<=1'b0;
		end
		else begin
				TxState<=nTxState;
				TxBitExtCnt<=nTxBitExtCnt;
				TxBitCnt<=nTxBitCnt;
				SerDataOut<=nSerDataOut;
				PalDataTemp<=nPalDataTemp;
				TxBusy<=nTxBusy;
				Parity<=nParity;
		end
	end


	task task_default_tx;
	begin
		nTxState=TxState;
		nTxBitExtCnt=TxBitExtCnt;
		nTxBitCnt=TxBitCnt;
		nSerDataOut=SerDataOut;
		nPalDataTemp=PalDataTemp;
		nTxBusy=TxBusy;
		nParity=Parity;
	end
	endtask

		always@(*)begin
			task_default_tx;
			if(GateClk) begin
			// else begin
				case(TxState)
					StTxIdle:begin
						if(PalDataInEn==1'b1)begin
							nTxState=StTxStartBit;
							nTxBusy=1'b1;
							nParity=~^PalDataIn;
							nPalDataTemp=PalDataIn;
							nSerDataOut=1'b0;	
						end
						end	

					StTxStartBit:begin
						if(TxBitExtCnt==4'd15)begin
							{nPalDataTemp[6:0],nSerDataOut}=PalDataTemp[7:0];
							nTxState=StTxBit;
							end
						nTxBitExtCnt=TxBitExtCnt+4'd1;																
						end							
					StTxBit:begin
						if(TxBitExtCnt==4'd15)begin
							if(TxBitCnt<=3'd6)begin
								{nPalDataTemp[6:0],nSerDataOut}=PalDataTemp[7:0];
								nTxBitCnt=TxBitCnt+3'd1;
								end
							else begin
								nTxBitCnt=3'd0;
								nSerDataOut=Parity;
								nTxState=StTxParity;//;
								end										
							end
						nTxBitExtCnt=TxBitExtCnt+4'd1;								
						end

					StTxParity:begin
						if(TxBitExtCnt==4'd15)begin
							nSerDataOut=1'b1;
							nTxState=StTxStpBit;										
							end
						nTxBitExtCnt=TxBitExtCnt+4'd1;								
						end
					StTxStpBit:begin
						if(TxBitExtCnt==4'd15)begin
							nTxState=StTxIntervl;										
							end
						nTxBitExtCnt=TxBitExtCnt+4'd1;	
						end
					
					StTxIntervl:begin
						if(TxBitExtCnt==4'd15)begin
							if(TxBitCnt<=3'd4)begin
								nTxBitCnt=TxBitCnt+3'd1;
								end
							else begin
								nTxBitCnt=3'd0;
								nTxBusy=1'b0;
								nTxState=StTxIdle;
								end										
							end
						nTxBitExtCnt=TxBitExtCnt+4'd1;
						end
					default:begin
						nTxState=4'd0;
						nTxBitExtCnt=4'd0;
						nTxBitCnt=3'd0;
						nSerDataOut=1'b1;
						nPalDataTemp=8'd0;
						nTxBusy=1'b0;
						nParity=1'b0;
						end
					endcase
				end				
			end


//------------------------------------

		// always@(posedge Clk or negedge Rstn)begin
		// 	if(!Rstn)begin
		// 		TxState<=4'd0;
		// 		TxBitExtCnt<=4'd0;
		// 		TxBitCnt<=3'd0;
		// 		SerDataOut<=1'b1;
		// 		PalDataTemp<=8'd0;
		// 		TxBusy<=1'b0;
		// 		Parity<=1'b0;
		// 		end
		// 	else if(GateClk) begin
		// 	// else begin
		// 		case(TxState)
		// 			StTxIdle:begin
		// 				if(PalDataInEn==1'b1)begin
		// 					TxState<=StTxStartBit;
		// 					TxBusy<=1'b1;
		// 					Parity<=~^PalDataIn;
		// 					PalDataTemp<=PalDataIn;
		// 					SerDataOut<=1'b0;	
		// 					end
		// 				end	

		// 			StTxStartBit:begin
		// 				if(TxBitExtCnt==4'd15)begin
		// 					{PalDataTemp[6:0],SerDataOut}<=PalDataTemp[7:0];
		// 					TxState<=StTxBit;
		// 					end
		// 				TxBitExtCnt<=TxBitExtCnt+4'd1;																
		// 				end							
		// 			StTxBit:begin
		// 				if(TxBitExtCnt==4'd15)begin
		// 					if(TxBitCnt<=3'd6)begin
		// 						{PalDataTemp[6:0],SerDataOut}<=PalDataTemp[7:0];
		// 						TxBitCnt<=TxBitCnt+3'd1;
		// 						end
		// 					else begin
		// 						TxBitCnt<=3'd0;
		// 						SerDataOut<=Parity;
		// 						TxState<=StTxParity;//;
		// 						end										
		// 					end
		// 				TxBitExtCnt<=TxBitExtCnt+4'd1;								
		// 				end

		// 			StTxParity:begin
		// 				if(TxBitExtCnt==4'd15)begin
		// 					SerDataOut<=1'b1;
		// 					TxState<=StTxStpBit;										
		// 					end
		// 				TxBitExtCnt<=TxBitExtCnt+4'd1;								
		// 				end
		// 			StTxStpBit:begin
		// 				if(TxBitExtCnt==4'd15)begin
		// 					TxState<=StTxIntervl;										
		// 					end
		// 				TxBitExtCnt<=TxBitExtCnt+4'd1;	
		// 				end
					
		// 			StTxIntervl:begin
		// 				if(TxBitExtCnt==4'd15)begin
		// 					if(TxBitCnt<=3'd4)begin
		// 						TxBitCnt<=TxBitCnt+3'd1;
		// 						end
		// 					else begin
		// 						TxBitCnt<=3'd0;
		// 						TxBusy<=1'b0;
		// 						TxState<=StTxIdle;
		// 						end										
		// 					end
		// 				TxBitExtCnt<=TxBitExtCnt+4'd1;
		// 				end
		// 			default:begin
		// 				TxState<=4'd0;
		// 				TxBitExtCnt<=4'd0;
		// 				TxBitCnt<=3'd0;
		// 				SerDataOut<=1'b1;
		// 				PalDataTemp<=8'd0;
		// 				end
		// 			endcase
		// 		end				
		// 	end

		//=====================================

		// reg nPalDataOutValid;
		// reg nPalDataInReady;
		// reg PalDataOutValid;
		// reg PalDataInPermit;
		// always@(posedge Clk or negedge Rstn)begin
		// 	if(!Rstn)begin
		// 		PalDataOutValid<=1'b0;
		// 		PalDataInPermit<=1'b0;
		// 	end
		// 	else begin
		// 		PalDataOutValid<=nPalDataOutValid;
		// 		PalDataInPermit<=nPalDataInReady;
		// 	end
		// end

		// always@(*)begin
		// 	nPalDataOutValid=GateClk&PalDataOutValidReg;
		// 	nPalDataInReady=GateClk&(~TxBusy);
		// end



		assign PalDataOutValid=GateClk&PalDataOutValidReg;
		assign PalDataInPermit=GateClk&(~TxBusy);



endmodule		


