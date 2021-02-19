`include "async_fifo.v"
module tb;
parameter WIDTH=8;
parameter DEPTH=16;
parameter PTR_WIDTH=4;

reg wr_clk_i,rd_clk_i,rst_i,wr_en_i,rd_en_i;
reg [WIDTH-1:0]wdata_i;
wire [WIDTH-1:0] rdata_o;
wire empty_o,full_o,error_o;
integer i;
reg [30*8:0]testname;
integer wr_delay,rd_delay;

async_fifo #(.WIDTH(WIDTH),.DEPTH(DEPTH),.PTR_WIDTH(PTR_WIDTH)) dut(wr_clk_i,rd_clk_i,rst_i,wr_en_i,wdata_i,full_o,rd_en_i,rdata_o,empty_o,error_o);

initial begin
	wr_clk_i=0;
	forever #8 wr_clk_i=~wr_clk_i;
end

initial begin
	rd_clk_i=0;
	forever #7 rd_clk_i=~rd_clk_i;
end

initial begin
	$value$plusargs("testname=%s",testname);
	rst_i=1;
	repeat(2) @(posedge wr_clk_i);
	rst_i=0;
	//apply the stimulus(i.e write into fifo and reding from fifo)
	case(testname)
	//performs concurrent(i.e parallely) writes and read to fifo
	"test_fifo_concurrent_wr_rd":begin
	fork
		begin
			for(i=0;i<500;i=i+1)begin
				@(posedge wr_clk_i);
				wr_en_i=1;
				wdata_i=$random;
				wr_delay=$urandom_range(1,10);
				//less delay range for write
				//to make write operation faster than read
				@(posedge wr_clk_i);
				wr_en_i=0;
				wdata_i=0;
				repeat(wr_delay-1) @(posedge wr_clk_i);
			end
		end
		begin
			//Read from FIFO
			for(i=0;i<500;i=i+1)begin
				@(posedge rd_clk_i);
				rd_en_i=1;
				rd_delay=$urandom_range(1,10);//******
				@(posedge rd_clk_i);
				rd_en_i=0;
				repeat(rd_delay-1) @(posedge rd_clk_i);
			 end
		end
	join
	end
	"test_fifo_empty_error":begin
		       	//make the fifo full
			for(i=0;i<DEPTH;i=i+1)begin
				@(posedge wr_clk_i);
				wr_en_i=1;
				wdata_i=$random;
			end
			@(posedge wr_clk_i);
			wr_en_i=0;
			wdata_i=0;
			//Read from FIFO
			for(i=0;i<DEPTH+1;i=i+1)begin
				@(posedge rd_clk_i);
				rd_en_i=1;
			 end
			@(posedge rd_clk_i);
			rd_en_i=0;
		 end
		
	//error generation on fifo fulll
	"test_fifo_full_error":begin
			for(i=0;i<DEPTH+1;i=i+1)begin
				@(posedge wr_clk_i);
				wr_en_i=1;
				wdata_i=$random;
			end
			@(posedge wr_clk_i);
			wr_en_i=0;
			wdata_i=0;
	end
	"test_fifo_wr_rd":begin
		       	//make the fifo full
			for(i=0;i<DEPTH;i=i+1)begin
				@(posedge wr_clk_i);
				wr_en_i=1;
				wdata_i=$random;
			end
			@(posedge wr_clk_i);
			wr_en_i=0;
			wdata_i=0;
			//Read from FIFO
			for(i=0;i<DEPTH;i=i+1)begin
				@(posedge rd_clk_i);
				rd_en_i=1;
			 end
			@(posedge rd_clk_i);
			rd_en_i=0;
		 end
	 endcase
	 #100;
	 $finish;
end
endmodule
