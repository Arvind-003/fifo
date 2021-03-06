module async_fifo(wr_clk_i,rd_clk_i,rst_i,wr_en_i,wdata_i,full_o,rd_en_i,rdata_o,empty_o,error_o);
parameter WIDTH=8;
parameter DEPTH=16;
parameter PTR_WIDTH=4;

input wr_clk_i,rd_clk_i,rst_i,wr_en_i,rd_en_i;
input [WIDTH-1:0]wdata_i;
output reg [WIDTH-1:0] rdata_o;
output reg empty_o,full_o,error_o;

reg [WIDTH-1:0] mem [DEPTH-1:0];

reg [PTR_WIDTH-1:0] wr_ptr,rd_ptr;
reg [PTR_WIDTH-1:0] wr_ptr_rd_clk,rd_ptr_wr_clk;
reg wr_toggle_f,rd_toggle_f;//write and read toggle flag
reg wr_toggle_f_rd_clk,rd_toggle_f_wr_clk;//write and read toggle flag
integer i;
//right now i am assuming reset will happen with respect to wr_clk_i
//READ
always @(posedge rd_clk_i)begin
	if(rst_i==0)begin
		error_o=0;
		if(rd_en_i==1)begin
			if(empty_o==1)begin
				$display("ERROR:reading from empty FIFO");
				error_o=1;
			end
			else begin
				rdata_o=mem[rd_ptr];
				if(rd_ptr==DEPTH-1)begin
					rd_toggle_f=~rd_toggle_f;
					rd_ptr=0;
				end
				else begin
					rd_ptr=rd_ptr+1;
				end
			end
		end
	end
end
//WRITE
always @(posedge wr_clk_i)begin
	//all reg variables should be reset to reset value( neeed not be 0)
	if(rst_i==1)begin
		empty_o=1;
		full_o=0;
		error_o=0;
		rdata_o=0;
		wr_ptr=0;
		rd_ptr=0;
		wr_toggle_f=0;
		rd_toggle_f=0;
		wr_ptr_rd_clk=0;
		rd_ptr_wr_clk=0;
		wr_toggle_f_rd_clk=0;
		rd_toggle_f_wr_clk=0;
		for(i=0;i<DEPTH;i=i+1)begin
			mem[i]=0;
		end
	end
	else begin
		error_o=0;
		if(wr_en_i==1)begin
			if(full_o==1)begin
				$display("ERROR:writing to full FIFO");
				error_o=1;
			end
			else begin
				mem[wr_ptr]=wdata_i;
				if(wr_ptr==DEPTH-1)begin
					wr_toggle_f=~wr_toggle_f;
					wr_ptr=0;
				end
				else begin
					wr_ptr=wr_ptr+1;
				end
			end
		end
	end
end

//SYNCHRONIZATION
always @(posedge wr_clk_i)begin
	rd_ptr_wr_clk<=rd_ptr;
	rd_toggle_f_wr_clk<=rd_toggle_f;
end
always @(posedge rd_clk_i)begin
	wr_ptr_rd_clk<=wr_ptr;
	wr_toggle_f_rd_clk<=wr_toggle_f;
end

//Generate Full Condition=>use the signals synchronised to wr_clk domain
always @(wr_ptr or rd_ptr_wr_clk)begin
	if(wr_ptr==rd_ptr_wr_clk && wr_toggle_f!=rd_toggle_f_wr_clk)begin
		full_o=1;
	end
	else begin
		full_o=0;
	end
end

//Empty Condition=> synchronised to rd_clk domain
always @(rd_ptr or wr_ptr_rd_clk)begin
	if(wr_ptr_rd_clk==rd_ptr && wr_toggle_f_rd_clk==rd_toggle_f)begin
		empty_o=1;
	end
	else begin
		empty_o=0;
	end
end



endmodule
