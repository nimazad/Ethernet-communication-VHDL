`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:00:12 04/06/2010 
// Design Name: 
// Module Name:    CRC32 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies:  
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps 
module crc32_block(clk,rst,enable_s,newframe_s,data_crc_s,crc_s);
   parameter BITS_IN = 8;

   input wire clk;
   input wire rst;
   input wire enable_s;
   input wire newframe_s;
   input wire [BITS_IN-1:0] data_crc_s;
   output reg [31:0] crc_s;

   reg [31:0] crc_aux;
   reg [31:0] crc_int_s;
   reg        crc_feedback;
   integer i;

   always @ (*)
   begin : combinational
      crc_aux = ~ crc_int_s;
      if (enable_s)
      begin
         for (i = 0; i < BITS_IN; i = i + 1)
         begin
            
            crc_feedback = crc_aux[0] ^ data_crc_s[i]; //se o mais significativo for igual a 1 então deverá ocorrer um XOR com o polinômio.

            crc_aux[0]       = crc_aux[1];
            crc_aux[1]       = crc_aux[2];
            crc_aux[2]       = crc_aux[3];
            crc_aux[3]       = crc_aux[4];
            crc_aux[4]       = crc_aux[5];
            crc_aux[5]       = crc_aux[6]  ^ crc_feedback; //pos 26
            crc_aux[6]       = crc_aux[7];
            crc_aux[7]       = crc_aux[8];
            crc_aux[8]       = crc_aux[9]  ^ crc_feedback; //pos 23
            crc_aux[9]       = crc_aux[10] ^ crc_feedback; //pos 22
            crc_aux[10]      = crc_aux[11];
            crc_aux[11]      = crc_aux[12];
            crc_aux[12]      = crc_aux[13];
            crc_aux[13]      = crc_aux[14];
            crc_aux[14]      = crc_aux[15];
            crc_aux[15]      = crc_aux[16] ^ crc_feedback; //pos 16
            crc_aux[16]      = crc_aux[17];
            crc_aux[17]      = crc_aux[18];
            crc_aux[18]      = crc_aux[19];
            crc_aux[19]      = crc_aux[20] ^ crc_feedback; //pos 12
            crc_aux[20]      = crc_aux[21] ^ crc_feedback; //pos 11
            crc_aux[21]      = crc_aux[22] ^ crc_feedback; //pos 10
            crc_aux[22]      = crc_aux[23];
            crc_aux[23]      = crc_aux[24] ^ crc_feedback; //pos 8
            crc_aux[24]      = crc_aux[25] ^ crc_feedback; //pos 7
            crc_aux[25]      = crc_aux[26];
            crc_aux[26]      = crc_aux[27] ^ crc_feedback; //pos 5
            crc_aux[27]      = crc_aux[28] ^ crc_feedback; //pos 4
            crc_aux[28]      = crc_aux[29];
            crc_aux[29]      = crc_aux[30] ^ crc_feedback; //pos 2
            crc_aux[30]      = crc_aux[31] ^ crc_feedback; //pos 1
            crc_aux[31]      =               crc_feedback; //o bit shiftando
         end
      end
   end
   always @(posedge clk)
   begin : sequencialdata_crc_s
      if (rst | newframe_s)
      begin
         crc_s <= 32'h00000000;
	      crc_int_s <= 32'h00000000;
      end
      else
      begin
         crc_int_s <= ~ crc_aux;
         crc_s <= ~ crc_aux;
      end
   end
endmodule