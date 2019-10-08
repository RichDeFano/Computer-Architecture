// ECE:3350 SISC processor project
// 32-bit mux with storage for swap command

`timescale 1ns/100ps

module swp32 (in_a, in_b, we, outa, outb);


  input  [31:0] in_a;
  input  [31:0] in_b;
  input         we;
  output [31:0] outa,outb;

  reg   [31:0] outrega, outregb;
  
  always @ (posedge we)
  begin
      outrega <= in_a;
      outregb <= in_b;
  end

 

  assign outa = outrega;
  assign outb = outregb;

endmodule