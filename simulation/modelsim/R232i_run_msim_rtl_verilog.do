transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/verilog_code {C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/verilog_code/main_memory.v}
vlog -vlog01compat -work work +incdir+C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/verilog_code {C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/verilog_code/MEM_WB.v}
vlog -vlog01compat -work work +incdir+C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/verilog_code {C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/verilog_code/instruction_memory.v}
vlog -vlog01compat -work work +incdir+C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/verilog_code {C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/verilog_code/hazard_detection_unit.v}
vlog -vlog01compat -work work +incdir+C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/verilog_code {C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/verilog_code/EX_MEM.v}
vlog -vlog01compat -work work +incdir+C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/verilog_code {C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/verilog_code/ULA.v}
vlog -vlog01compat -work work +incdir+C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/verilog_code {C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/verilog_code/forward_unit.v}
vlog -vlog01compat -work work +incdir+C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/verilog_code {C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/verilog_code/register_bank.v}
vlog -vlog01compat -work work +incdir+C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/verilog_code {C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/verilog_code/Branch Decider.v}
vlog -vlog01compat -work work +incdir+C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/verilog_code {C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/verilog_code/ID_EX.v}
vlog -vlog01compat -work work +incdir+C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/verilog_code {C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/verilog_code/RV32i.v}
vlog -vlog01compat -work work +incdir+C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/verilog_code {C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/verilog_code/IF_ID.v}
vlog -vlog01compat -work work +incdir+C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/verilog_code {C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/verilog_code/control.v}
vlog -vlog01compat -work work +incdir+C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/verilog_code {C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/verilog_code/PC.v}

vlog -vlog01compat -work work +incdir+C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/simulation/modelsim {C:/Users/davi5/UFPI/4_periodo/Topicos/Risc-v-R232I-pipeline-/simulation/modelsim/tb_RV32i.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  tb_RV32i

add wave *
view structure
view signals
run -all
