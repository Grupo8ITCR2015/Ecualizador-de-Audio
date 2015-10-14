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
module PmodAD1(
 //Entradas
input Reset,
input clk,
//Salidas
output reg rx_done,
output wire [28:0] dataout,
//Control PmodAD
input sdatain,
output wire SClk, 
output reg CS
	);

//---------------
// Divisor de frecuencia SClk
//---------------
reg SClk_prov=1'b1;
parameter numberclk = 15'd2084; //CORREGIR VALOR
reg [14:0] counterclk = 15'b0000000000;
always @(posedge clk) begin
			if(Reset) begin
					SClk_prov <= 1'b0;
					counterclk <= 15'b0000000000;
			end
			// Count/toggle normally
			else begin

					if(counterclk == numberclk) begin
							SClk_prov <= ~SClk_prov;
							counterclk <= 15'b0000000000;
					end
					else begin
							counterclk <= counterclk + 15'd1;
					end
			end
	end
	
assign SClk=SClk_prov;

//---------------
// Bandera CS
//---------------
// Output register
reg flag = 1'b0;
parameter numberflag = 13'd2; ///CORREGIR VALOR
reg [12:0] counterflag = 13'b0000000000;
always @(negedge SClk) 
	begin 
		if(Reset) begin
				flag <= 1'b0;
				counterflag <= 13'b0000000000;
			end
		else begin
			if(counterflag == numberflag)
   			begin
				flag <= 1'b1;
				counterflag <= 13'b0000000000;
				end
			else begin
							counterflag <= counterflag + 13'd1;
							flag <= 1'b0;
			end

			end

	end

//---------------
// Parametros
//---------------
localparam [1:0] ADC_IDLE_STATE      = 2'b00,
					  ADC_START_STATE     = 2'b01,
					  ADC_READ_STATE      = 2'b10,
					  ADC_DONE_STATE      = 2'b11;


//---------------
//Señales internas
//---------------

reg [1:0] state, next_state;
reg [11:0] dataint, dataint_next;
reg [4:0] counter, counter_next;

//---------------
//Estados secuenciales
//---------------
always @(negedge SClk)
	if(Reset)
		begin
		state<= 2'd0;
		dataint <= 12'd0;
		counter <= 5'd0;
		end
	else
		begin
		state<= next_state;
		dataint <= dataint_next;
		counter <= counter_next;
		end

//---------------
//Maquina de Estados 
//---------------

always @*
    begin
        next_state <= state;
		  dataint_next <= dataint;
		  counter_next <= counter;
        case(state)
            ADC_IDLE_STATE:
                begin
                    rx_done <= 1'b0;  
                    CS <= 1'b1;
						  if(counter==5'd0) begin next_state<=ADC_START_STATE; end
                end
            ADC_START_STATE:
                begin
                    rx_done  <= 1'b0;
                    CS <= 1'b1;
						  //counter_next <= counter + 5'd1;
						  if (flag) begin next_state<=ADC_READ_STATE; end
                end
            ADC_READ_STATE:
                begin
                    rx_done <= 1'b0;
                    CS <= 1'b0;
						  counter_next <= counter + 5'b00001;
						  dataint_next <= {dataint[10:0], sdatain};
						  if (counter == 5'd15) begin next_state<=ADC_DONE_STATE; end else begin next_state<=ADC_READ_STATE; end //VALOR ES 15
                end
            ADC_DONE_STATE:
                begin
                    rx_done <= 1'b1;
                    CS  <= 1'b0;
						  counter_next <= 5'd0;
						  next_state<=ADC_IDLE_STATE;
                end
            default:
                begin
                    rx_done <= 1'b0;
                    CS <= 1'b1;
						  counter_next <= 5'd0;
						  next_state<=ADC_IDLE_STATE;
						  dataint_next<=16'd0;
                end
        endcase
    end
	 
//---------------
//FF Salida 
//---------------	 
reg [11:0] datatrunk;

always @(negedge SClk or posedge Reset)
      if (Reset) begin
         datatrunk <= 16'd0;
      end else if (rx_done) begin
         datatrunk <= dataint;
      end


assign dataout = {{15{~datatrunk[11]}},datatrunk[10:0],3'b000};

endmodule 
