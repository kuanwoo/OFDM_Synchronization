`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/14 22:58:08
// Design Name: 
// Module Name: test_coarse_sync
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


module test_coarse_sync;

	// Inputs
	reg axis_aclk;
	reg axis_areset;
	reg s_axis_ctrl_tvalid;
	reg s_axis_ctrl_tlast;
	reg [31:0] s_axis_ctrl_tdata;
	reg s_axis_data_tvalid;
	reg s_axis_data_tlast;
	reg [95:0] s_axis_data_tdata;
	reg [15:0] s_axis_data_taddr;
	reg m_axis_ctrl_trdy;
	reg m_axis_data_trdy;

	// Outputs
	wire s_axis_ctrl_trdy;
	wire s_axis_data_trdy;
	wire m_axis_ctrl_tvalid;
	wire m_axis_ctrl_tlast;
	wire [31:0] m_axis_ctrl_tdata;
	wire m_axis_data_tvalid;
	wire m_axis_data_tlast;
	wire [119:0] m_axis_data_tdata;
	wire [15:0] m_axis_data_taddr;
	
	reg [31:0] data_in[0:20000];
	integer clk_cnt;
	integer data_cnt;

	// Instantiate the Unit Under Test (UUT)
	coarse_sync #(
		.SYNC_DATA_WIDTH(16),
		.RAM_ADDR_WIDTH(10)
	) uut (
		.axis_aclk(axis_aclk), 
		.axis_areset(axis_areset), 
		.s_axis_ctrl_tvalid(s_axis_ctrl_tvalid), 
		.s_axis_ctrl_tlast(s_axis_ctrl_tlast), 
		.s_axis_ctrl_tdata(s_axis_ctrl_tdata), 
		.s_axis_ctrl_trdy(s_axis_ctrl_trdy), 
		.s_axis_data_tvalid(s_axis_data_tvalid), 
		.s_axis_data_tlast(s_axis_data_tlast), 
		.s_axis_data_tdata(s_axis_data_tdata), 
		.s_axis_data_taddr(s_axis_data_taddr), 
		.s_axis_data_trdy(s_axis_data_trdy), 
		.m_axis_ctrl_tvalid(m_axis_ctrl_tvalid), 
		.m_axis_ctrl_tlast(m_axis_ctrl_tlast), 
		.m_axis_ctrl_tdata(m_axis_ctrl_tdata), 
		.m_axis_ctrl_trdy(m_axis_ctrl_trdy), 
		.m_axis_data_tvalid(m_axis_data_tvalid), 
		.m_axis_data_tlast(m_axis_data_tlast), 
		.m_axis_data_tdata(m_axis_data_tdata), 
		.m_axis_data_taddr(m_axis_data_taddr), 
		.m_axis_data_trdy(m_axis_data_trdy)
	);

	initial begin
		// Initialize Inputs
		$readmemh("ofdm_source.txt",data_in);
		axis_aclk = 0;
		axis_areset = 0;
		s_axis_ctrl_tvalid = 0;
		s_axis_ctrl_tlast = 0;
		s_axis_ctrl_tdata = 0;
		s_axis_data_tvalid = 0;
		s_axis_data_tlast = 0;
		s_axis_data_tdata = 0;
		s_axis_data_taddr = 0;
		m_axis_ctrl_trdy = 0;
		m_axis_data_trdy = 0;

		// Wait 100 ns for global reset to finish
		#10;
		axis_areset = 1;
		#10;
		axis_areset = 0;
		#10;
		
        
		// Add stimulus here

	end
	
	always
		#5 axis_aclk = ~axis_aclk;
	
	always @(posedge axis_aclk or posedge axis_areset) begin
		if(axis_areset == 1'b1) begin
			clk_cnt <= 4;
		end
		else begin
			clk_cnt <= clk_cnt + 1;
		end
	end
	
	always @(posedge axis_aclk or posedge axis_areset) begin
		if(axis_areset == 1'b1) begin
			s_axis_ctrl_tvalid	<= 1'b0;
			s_axis_ctrl_tdata	<= 32'd0;
		end
		else if(clk_cnt == 6) begin
			s_axis_ctrl_tvalid	<= 1'b1;
			s_axis_ctrl_tdata	<= {8'd1,24'd1};
		end
		else begin
			s_axis_ctrl_tvalid	<= 1'b0;
			s_axis_ctrl_tdata	<= 32'd0;
		end
	end
	
	always @(posedge axis_aclk or posedge axis_areset) begin
		if(axis_areset == 1'b1) begin
			s_axis_data_tvalid	<= 1'b0;
			s_axis_data_tdata	<= 96'd0;
			s_axis_data_taddr	<= 16'd0;
			data_cnt			<= 0;
		end
		else begin
			if(clk_cnt[2:0] == 3'd3) begin
				if(data_cnt > 3200) begin
					s_axis_data_tvalid	<= 1'b1;
					s_axis_data_tdata	<= 96'd0;
					s_axis_data_taddr	<= data_cnt + 1;
					data_cnt			<= data_cnt + 1;
				end
				else begin
					s_axis_data_tvalid	<= 1'b1;
					s_axis_data_tdata	<= {8'd0,data_in[data_cnt][15:0],
											8'd0,data_in[data_cnt][31:16],
											8'd0,data_in[data_cnt+32][15:0],
											8'd0,data_in[data_cnt+32][31:16]};
					s_axis_data_taddr	<= data_cnt + 1;
					data_cnt			<= data_cnt + 1;
				end
			end
			else begin
				s_axis_data_tvalid	<= 1'b0;
				s_axis_data_tdata	<= s_axis_data_tdata;
				s_axis_data_taddr	<= s_axis_data_taddr;
				data_cnt			<= data_cnt;
			end
		end
	end
	
	always @(posedge axis_aclk) begin
		if(clk_cnt == 30000) begin
			$stop;
		end
	end
	
//================================================================================
// 时序计数器
//================================================================================
	// 与valid信号对齐
	integer u1_u2_o_data_cnt; // 期望运算中最后一个数的号码
	integer u3_o_tar_data_cnt; // 第四个32数据窗口中最后一个数的号码
	integer u3_o_tar_data_cnt_first; // 第一个32数据窗口中第一个数的号码
	
	always @(posedge axis_aclk or posedge axis_areset) begin
		if(axis_areset == 1'b1) begin
			u1_u2_o_data_cnt		<= 0;
			u3_o_tar_data_cnt		<= 0;
			u3_o_tar_data_cnt_first	<= 0;
		end
		else begin
			u1_u2_o_data_cnt		<= data_cnt - 1;
			u3_o_tar_data_cnt		<= data_cnt - 2;
			u3_o_tar_data_cnt_first	<= data_cnt - 2 - 223;
		end
	end
	
	
      
endmodule
