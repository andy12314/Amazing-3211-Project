
## 1. create the library
vlib work

## 2. compile the dut
vcom "adder_8b.vhd"
vcom "add_sum_unit.vhd"
vcom "alu.vhd"


## 2. compile the tb
vcom "alu_testbench.vhd"
#vcom *.vhw

## 3. load the design
vsim -novopt ALUTestBench
#vsim -novopt single_cycle_core_testbench

## ModelSim6.2+ : vsim -novopt TestBench

## 4. add wave 
do alu_wave.do

## 4. run simulation
run 50us