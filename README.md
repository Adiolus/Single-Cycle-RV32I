# RV32I Datapath: IF, ID and EX Stages

A SystemVerilog implementation limited to the first three datapath stages of an RV32I processor: Instruction Fetch (IF), Instruction Decode (ID) and Execute (EX).

## Scope

1. IF: program counter, sequential PC update and external instruction input.
2. ID: instruction field decoding, immediate generation, control decoding and register operand reads.
3. EX: ALU operations, branch comparisons, jump target generation and effective-address calculation.

The implementation intentionally stops after EX. It does not include a MEM stage, data-memory interface, WB stage, load-result selection or architectural register write-back path. Load/store instructions only calculate their effective address in EX.

The register file exposes an external write port so a test environment can preload operands. This is not a processor write-back stage.

## Files

```text
rtl/
  rv32i_if_stage.sv
  rv32i_id_stage.sv
  rv32i_ex_stage.sv
  rv32i_if_id_ex.sv
  rv32i_program_counter.sv
  rv32i_decoder.sv
  rv32i_immediate_unit.sv
  rv32i_control_unit.sv
  rv32i_register_bank.sv
  rv32i_alu_control.sv
  rv32i_alu.sv
```

## Top Module

`rv32i_if_id_ex`

The instruction is supplied through `instruction_in` by an external instruction memory. The top module exposes the current PC, decoded instruction fields, register operands, immediate, ALU result and redirect information.

## Language

SystemVerilog

## Important

This is a three-stage scope-limited datapath, not a complete single-cycle RV32I processor or a pipelined processor. There are no pipeline registers between IF, ID and EX.
