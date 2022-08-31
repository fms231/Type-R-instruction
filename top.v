`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:09:29 05/15/2022 
// Design Name: 
// Module Name:    top 
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
module top(clk,clk_s,rst,an,seg);
	input clk,rst;
	input clk_s;
	output[3:0] an;
	output[7:0] seg;
	wire zf,of;
	wire[31:0] F;
	top_R top_R0(rst,clk,zf,of,F);
	
	show show0(rst,clk_s,F,an,seg);
endmodule

module show(clr,clk,Data,an,seg);//数码管显示模块
	input clk,clr;
	input[31:0] Data;
	output reg[3:0] an;
	output reg[7:0] seg;

	reg[2:0] BitSel = 3'b0; //选择用哪一个数码管显示
	reg[3:0] data; //数码管所需要显示的数字
	//数码管显示数字模块
	always@(*)
	begin
		case(data)
			4'b0000: seg[7:0]<=8'b00000011;
			4'b0001: seg[7:0]<=8'b10011111;
			4'b0010: seg[7:0]<=8'b00100101;
			4'b0011: seg[7:0]<=8'b00001101;
			4'b0100: seg[7:0]<=8'b10011001;
			4'b0101: seg[7:0]<=8'b01001001;
			4'b0110: seg[7:0]<=8'b01000001;
			4'b0111: seg[7:0]<=8'b00011111;
			4'b1000: seg[7:0]<=8'b00000001;
			4'b1001: seg[7:0]<=8'b00001001;
			4'b1010: seg[7:0]<=8'b00010001;
			4'b1011: seg[7:0]<=8'b11000001;
			4'b1100: seg[7:0]<=8'b01100011;
			4'b1101: seg[7:0]<=8'b10000101;
			4'b1110: seg[7:0]<=8'b01100001;
			4'b1111: seg[7:0]<=8'b01110001;
		endcase
	end
	
	always@( posedge clk)
		begin
				begin
							BitSel <= BitSel + 1'b1;
							case(BitSel)
							3'b000: 
							begin 
								an<=4'b1111;
								if(clr) data <= 4'b1010;
								else data<=Data[3:0];
							end
							3'b001: 
							begin
								an<=4'b1110;							
								if(clr) data <= 4'b1010;
								else data<=Data[7:4];
							end
							3'b010: 
							begin
								an<=4'b1101;
								if(clr) data <= 4'b1010;
								else data<=Data[11:8];
							end
							3'b011: 
							begin
								an<=4'b1100;
								if(clr) data <= 4'b1010;
								else data<=Data[15:12];								
							end							
							3'b100:
							begin
								an<=4'b1011;
								if(clr) data <= 4'b1010;
								else data<=Data[19:16];
							end
							3'b101:
							begin
								an<=4'b1010;
								if(clr) data <= 4'b1010;
								else data<=Data[23:20];
							end
							3'b110:
							begin
								an<=4'b1001;
								if(clr) data <= 4'b1010;
								else data<=Data[27:24];
							end
							3'b111:
							begin
								an<=4'b1000;
								if(clr) data <= 4'b1010;
								else data<=Data[31:28];
							end
						endcase		
				end
		end
endmodule

module top_R(input rst,input clk,output zf,output of,output[31:0] F);
	wire[31:0] instcode;
	wire[31:0] R_Data_A;
	wire[31:0] R_Data_B;
	reg[2:0] ALU_OP;
	pc pc0(clk,rst,instcode);
	reg write_reg;	
	Register_file Register_file0(instcode[25:21],instcode[20:16],instcode[15:11],write_reg,F,~clk,rst,R_Data_A,R_Data_B);
	ALU ALU0(R_Data_A,R_Data_B,F,ALU_OP,zf,of);
	always@(*)
	begin
	 write_reg=0;
	 ALU_OP=0;
	 if(instcode[31:26]==0)
	 begin
		case(instcode[5:0])
		6'b100000:ALU_OP=3'b100;
		6'b100010:ALU_OP=3'b101;
		6'b100100:ALU_OP=3'b000;
		6'b100101:ALU_OP=3'b001;
		6'b100110:ALU_OP=3'b010;
		6'b100111:ALU_OP=3'b011;
		6'b101011:ALU_OP=3'b110;
		6'b000100:ALU_OP=3'b111;
		endcase
		write_reg=1;
	end
  end
endmodule

module pc(input clk,input rst,output[31:0] instcode);
	reg[31:0] pc;
	initial pc<=32'h00000000;
	wire[31:0] pc_new;
	Inst_ROM your_instance_name (
  .clka(clk), // input clka
  .addra(pc[7:2]), // input [5 : 0] addra
  .douta(instcode) // output [31 : 0] douta
);
	assign pc_new=pc+4;
	always@(negedge clk or posedge rst)
	begin
		if(rst)
			pc=32'h00000000;
		else
			pc={24'h000000,pc_new[7:0]};
	end
endmodule

module Register_file(R_Addr_A,R_Addr_B,W_Addr,Write_Reg,W_Data,clk,rst,R_Data_A,R_Data_B);
	input[4:0] R_Addr_A;
	input[4:0] R_Addr_B;
	input[4:0] W_Addr;
	input Write_Reg;
	input[31:0] W_Data;
	input clk;
	input rst;
	output[31:0] R_Data_A;
	output[31:0] R_Data_B;
	reg[31:0] REG_file[0:31];
	reg[5:0] i;
	initial
	begin
	for(i=0;i<=31;i=i+1)
		REG_file[i]=32'b0;
	end
	
	assign R_Data_A=REG_file[R_Addr_A];
	assign R_Data_B=REG_file[R_Addr_B];
	always@(posedge clk or posedge rst)
	begin
		if(rst)
		begin
			for(i=0;i<=31;i=i+1)
				REG_file[i]=32'b0;
		end
		else
			if(Write_Reg&&W_Addr!=0)
				REG_file[W_Addr]=W_Data;
	end
endmodule

module ALU(A,B,F,ALU_OP,zf,of);
	input[31:0] A;
	input[31:0] B;
	input[2:0] ALU_OP;
	output reg zf,of;
	output reg[31:0] F;
	reg C32;
	always@(*)
	begin
		of=1'b0;
		C32=1'b0;
		case(ALU_OP)
		3'b000:F=A&B;
		3'b001:F=A|B;
		3'b010:F=A^B;
		3'b011:F=~(A^B);
		3'b100:begin {C32,F}=A+B; of=A[31]^B[31]^F[31]^C32; end
		3'b101:begin {C32,F}=A-B; of=A[31]^B[31]^F[31]^C32; end
		3'b110:F=(A<B);
		3'b111:F=B<<A;
		endcase
		if(F==0)
			zf=1;
		else
			zf=0;
	end
endmodule

