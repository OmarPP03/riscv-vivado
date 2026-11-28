#!/usr/bin/env bash
set -e
mkdir -p build
FLAGS="--std=08"
ghdl -a $FLAGS src/rv_pkg.vhd src/alu.vhd src/reg_file.vhd src/imm_gen.vhd src/control_unit.vhd \
               src/comparator.vhd src/i_mem.vhd src/d_mem.vhd src/state_machine.vhd \
               src/cpu.vhd tb/tb_cpu.vhd
ghdl -e $FLAGS tb_cpu
ghdl -r $FLAGS tb_cpu --wave=build/tb_cpu.ghw