vlog tb_async_fifo.v
vsim -novopt tb +testname=test_fifo_concurrent_wr_rd
add log -r sim:/tb/dut/*
add wave sim:/tb/dut/*
run -all
