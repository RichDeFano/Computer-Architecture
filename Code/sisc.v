// ECE:3350 SISC processor project
// main SISC module, part 1

`timescale 1ns/100ps  


module sisc (clk, rst_f);

  input clk, rst_f;
  wire [1:0] alu_op, data_select,mm_sel;
  wire wb_sel,stat_en,rf_we,pc_write,pc_sel,ir_load,pc_rst,br_sel, dm_we,swp_we,swp_sel,rb_sel;
  wire [31:0]alu_result,mux_32,rsa,rsb,read_data,ir,dm_to_mux32,swp_outa,swp_outb,mux32_to_data;
  wire [15:0] pc_out,br_addr,mux16_to_dm;
  wire[3:0] cc,stat_to_ctl,mux4_to_rf,write_reg;
  

// declare all internal wires here
  ctrl ctl1(clk,rst_f,ir[31:28],ir[27:24],stat_to_ctl,rf_we,alu_op,wb_sel,br_sel, pc_rst, pc_write, pc_sel, rb_sel, ir_load, mm_sel, dm_we,swp_we,data_select,swp_sel);
  alu alu1(clk,rsa,rsb,ir[15:0],alu_op,alu_result,cc,stat_en);
  rf rf1(clk,ir[19:16],mux4_to_rf,write_reg,mux32_to_data,rf_we,rsa,rsb);
  statreg stat(clk,cc,stat_en,stat_to_ctl);
  mux4 mux41(ir[15:12],ir[23:20],rb_sel,mux4_to_rf);
  mux32 mux321(alu_result,dm_to_mux32,wb_sel,mux_32);
  pc pc1(clk,br_addr,pc_sel,pc_write,pc_rst,pc_out);
  br br1(pc_out,ir[15:0],br_sel,br_addr);
  im im1(pc_out,read_data);
  ir ir1(clk,ir_load,read_data,ir);

  mux16 mux161(alu_result[15:0],ir[15:0],rsa[15:0],mm_sel,mux16_to_dm[15:0]);
  dm dm1(mux16_to_dm[15:0],mux16_to_dm[15:0],rsb[31:0], dm_we, dm_to_mux32);

  mux32_3 mux323(mux_32,swp_outa,swp_outb,data_select,mux32_to_data);
  swp32 swpmux(rsa,rsb,swp_we, swp_outa, swp_outb);
  mux4 mux42(ir[23:20],ir[19:16], swp_sel,write_reg);

// component instantiation goes here


  initial
  begin
  
// put a $monitor statement here.  
  $monitor("IR=%8h PC=%8h R1=%8h R2=%8h R3=%8h R4=%8h R5=%8h R6=%8h RB_SEL=%b SWP_WE=%b RF_WE=%b D_SL=%b SWP_A=%8h SWP_B=%8h MUX32 = %8h SWP_SEL =%b M[0]=%8h M[1]=%8h M[2]=%8h M[3]=%8h",ir,pc_out,rf1.ram_array[1],rf1.ram_array[2],rf1.ram_array[3],rf1.ram_array[4],rf1.ram_array[5],rf1.ram_array[6],rb_sel,swp_we,rf_we,data_select,swp_outa,swp_outb,mux32_to_data,swp_sel,dm1.ram_array[0],dm1.ram_array[1],dm1.ram_array[2],dm1.ram_array[3]);
  //$monitor("IR=%8h PC=%8h R1=%8h R2=%8h R3=%8h R4=%8h R5=%8h R6=%8h ALU_OP=%2b BR_SEL=%b RB_SEL=%b MM_SEL=%b DM_WE=%b M[8]=%8h M[9]=%8h",ir,pc_out,rf1.ram_array[1],rf1.ram_array[2],rf1.ram_array[3],rf1.ram_array[4],rf1.ram_array[5],rf1.ram_array[6],alu_op,br_sel,rb_sel,mm_sel,dm_we,dm1.ram_array[8],dm1.ram_array[9]);

  end


endmodule


