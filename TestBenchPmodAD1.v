`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: ITCR
// Engineer: Diego Salazar y Edgar Solera
// 
// Module Name:    PmodAD1 
// Project Name:  Ecualizador
// Description: Este modulo se encarga de las señales del control del PmodAD1, la recepción del datos
//              y el ajuste del tamaño de palabra.
//
//////////////////////////////////////////////////////////////////////////////////

module TestBenchPmodAD1;

	// Inputs
	reg Reset;
	reg clk;
	reg sdatain;

	// Outputs
	wire rx_done;
	wire [28:0] dataout;
	wire SClk;
	wire CS;

	// Instantiate the Unit Under Test (UUT)
	PmodAD1 uut (
		.Reset(Reset), 
		.clk(clk), 
		.rx_done(rx_done), 
		.dataout(dataout), 
		.sdatain(sdatain), 
		.SClk(SClk), 
		.CS(CS)
	);

	initial begin
		// Initialize Inputs
		Reset = 0;
		clk = 0;
		sdatain = 0;
	end
	
	integer i;
	reg [15:0] data_txt;
	reg [15:0] Memoria [0:4];
initial begin
			// Initialize Inputs
			Reset=0;
			sdatain = 0;
			$readmemb("test1.txt",Memoria);
		end

initial begin
			@(negedge CS)
					data_txt=Memoria[0];
					for (i=0;i<16;i=i+1)
						begin
							@(negedge SClk)
								sdatain=data_txt[15-i];
						end
			@(negedge CS)
					data_txt=Memoria[1];
					for (i=0;i<16;i=i+1)
						begin
							@(negedge SClk)
								sdatain=data_txt[15-i];
						end
			@(negedge CS)
					data_txt=Memoria[2];
					for (i=0;i<16;i=i+1)
						begin
							@(negedge SClk)
								sdatain=data_txt[15-i];
						end
			@(negedge CS)
					data_txt=Memoria[3];
					for (i=0;i<16;i=i+1)
						begin
							@(negedge SClk)
								sdatain=data_txt[15-i];
						end	
		end



	
initial forever begin
	#1 clk= ~ clk;
end
      
endmodule
