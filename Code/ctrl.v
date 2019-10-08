// ECE:3350 SISC computer project
// finite state machine

`timescale 1ns/100ps

module ctrl (clk, rst_f, opcode, mm, stat, rf_we, alu_op, wb_sel, br_sel, pc_rst, pc_write, pc_sel, rb_sel, ir_load, mm_sel, dm_we,swp_we,data_select,swp_sel);


  /* TODO: Declare the ports listed above as inputs or outputs */

  input clk,rst_f;
  input [3:0] opcode,mm,stat;
  output reg[1:0] alu_op,data_select,mm_sel;
  output reg rf_we,wb_sel,br_sel, pc_rst, pc_write, pc_sel, ir_load, dm_we,swp_we,rb_sel,swp_sel;
  
  
  // states
  parameter start0 = 0, start1 = 1, fetch = 2, decode = 3, execute = 4, mem = 5, writeback = 6;
   
  // opcodes
  parameter NOOP = 0, LOD = 1, STR = 2, SWP = 3, BRA = 4, BRR = 5, BNE = 6, BNR = 7, ALU_OP = 8, HLT=15;
	
  // addressing modes
  parameter am_imm = 8;

  // state registers
  reg [2:0]  present_state, next_state;


  initial begin
    present_state = start0;
    next_state = start1;
    
  end
  

  /* TODO: Write a sequential procedure that progresses the fsm to the next state on the
       positive edge of the clock, OR resets the state to 'start1' on the negative edge
       of rst_f. Notice that the computer is reset when rst_f is low, not high. */
  

  always@(posedge clk or negedge rst_f)
  begin
	
	if(rst_f == 0)
		present_state <= start1;
	
		
	else
		present_state<= next_state;

  end


  
  /* TODO: Write a combination procedure that determines the next state of the fsm. */
always@(present_state) begin
  if(present_state == 6)
	 next_state = 2;
	 

  else
	next_state = present_state+1;

end



  /* TODO: Generate outputs based on the FSM states and inputs. For Parts 2, 3 and 4 you will
       add the new control signals here. */

  always@(opcode or present_state) begin
	case(present_state)
		start0:begin
			alu_op <= 0;
			wb_sel <= 1;
			rf_we <= 0;
			pc_rst <= 1;
			pc_sel <= 0;
			ir_load <= 0;
			pc_write <= 0;
			pc_sel <=0;
			br_sel<=1;
			rb_sel<=0;
			mm_sel<=0;
			dm_we<=1;
			swp_we<=0;
			data_select<=0;
			swp_sel<=0;
			end


		start1: begin
			alu_op <= 0;
			wb_sel <= 1;
			rf_we <= 0;
			pc_rst <= 1;
			pc_sel <= 0;
			ir_load <= 0;
			pc_write <= 0;
			pc_sel <=0;
			br_sel<=1;
			mm_sel<=0;
			dm_we<=1;
			swp_we<=0;
			data_select<=0;
			swp_sel<=0;
			end


		fetch: begin
			pc_rst <=0;
			alu_op <= 0;
			wb_sel <= 0;
			rf_we <= 0;
			ir_load <= 1;
			pc_write <= 1;
			pc_sel <= 0;
			rb_sel <=0;
			mm_sel<=0;
			dm_we<=1;
			swp_we<=0;
			data_select<=0;
			swp_sel<=0;
			end


		decode: begin
			ir_load<=0;
			case(opcode)
				ALU_OP:begin		
					wb_sel <=0;
					pc_write<=0;
					if (mm == 0)
						rb_sel <= 0;
					
				end

				BRA:begin
					if(mm& stat!=0)
						begin
						br_sel<=1;
						pc_sel<=1;	
						end
					else
						pc_write<=0;
				end

				BNE:begin
					if((mm& stat)==0)
						begin
						br_sel<=1;
						pc_sel<=1;	
						end
					else
						pc_write<=0;
				end
				
				BRR:begin
					if((mm& stat)!=0)
						begin
						br_sel<=0;
						pc_sel<=1;	
						end
					else
						pc_write<=0;
				end	

				BNR:begin
					if((mm& stat)==0)
						begin
						br_sel<=0;
						pc_sel<=1;	
						end
					else
						pc_write<=0;	
				end

				LOD:begin
					pc_write<=0;
					rb_sel <= 1;
				end


				STR:begin
					pc_write<=0;
					rb_sel <=1;

				end
				
				SWP:begin
					rb_sel<=1;
					pc_write<=0;

				end
			
				default:begin
					pc_write<=0;	
				end
			endcase	
			

		end		
			

		execute: begin
			pc_write<=0;
			if(opcode == ALU_OP)
				if(mm == 8)
					alu_op = 2'b01;
				else
					alu_op = 2'b00;

			if(opcode ==LOD)
				begin
				alu_op <= 2'b11;
				if (mm == 0)
					mm_sel <= 2'b01;
				if (mm == 1)
					mm_sel <= 2'b10; //Change
				if (mm == 8)
					mm_sel <= 2'b00;
				if (mm == 9)
					mm_sel <= 2'b00;
 
				end

			if(opcode == STR)
				begin
				alu_op <= 2'b11;
				if (mm == 0)
					mm_sel <= 2'b01;
				if (mm == 1)
					mm_sel <= 2'b10; //Change
				if (mm == 8)
					mm_sel <= 2'b00;
				if (mm == 9)
					mm_sel <= 2'b00;
				end
			
			if(opcode == SWP)
				begin
				alu_op<= 2'b10;
				swp_we<=1;
				data_select<=1;
				end
				
				
			end

			

		mem: begin
			if(opcode == LOD)
				begin
				dm_we <= 1;
				wb_sel <=1;
				rf_we <= 1; 
				swp_we <= 0;
				end

			if(opcode == STR)
				begin
				dm_we <= 0;
				wb_sel <=1;
				rf_we <= 0; 
				swp_we <= 0;
				end
			if(opcode == SWP)
				begin
				swp_we<=0;
				rf_we<=1;
				end
		end
			
					
		writeback: begin
			if(opcode == ALU_OP)
				rf_we <=1;

			if(opcode == LOD)
			begin
			rf_we <=1;
			if (mm == 9)
					begin
						wb_sel <= 0;
						data_select <= 0;
						swp_sel <= 1;
					end
			if (mm == 1)
					begin
						wb_sel <= 0;
						data_select <= 0;
						swp_sel <= 1;
					end
				
			end

			if(opcode == STR)
			begin
			//rf_we <=1;
			if (mm == 9)
					begin
						wb_sel <= 0;
						data_select <= 0;
						swp_sel <= 1;
					end
			if (mm == 1)
					begin
						wb_sel <= 0;
						data_select <= 0;
						swp_sel <= 1;
					end
				
			end

			if(opcode == SWP)
				begin
				rf_we<=1;		
				swp_sel<=1;
				data_select<=2;
				end
			end		
			
	endcase
  end	
		
		
	
// Halt on HLT instruction
  
  always @ (opcode)
  begin
    if (opcode == HLT)
    begin 
      #5 $display ("Halt."); //Delay 5 ns so $monitor will print the halt instruction
      $stop;
    end
  end
    
  
endmodule
