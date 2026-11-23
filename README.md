# Single-Cycle RV32I Datapath

**Aditya Chinchore · Electronics and Communication Engineering · PES University**  
SRN : PES2UG24EC006  
Section : 5A

Computer Organization and Design

A modular, 32-bit RISC-V datapath written in SystemVerilog. The design combines RV32I integer and control-flow logic with an RV32M multiply/divide unit. The repository includes separate load/store and data-memory modules, plus three self-checking testbenches.

## Start with the datapath

The integration module is [`rv32i_if_id_ex`](rtl/rv32i_if_id_ex.sv). It connects fetch, decode, execute and writeback. The stage names describe how one instruction moves through the single-cycle datapath.

| Block | Role |
| --- | --- |
| [Fetch](rtl/rv32i_if_stage.sv) | Exposes the current PC, calculates PC + 4 and selects the next address on a branch or jump. The default reset PC is `0x80000000`. |
| [Decode](rtl/rv32i_id_stage.sv) | Extracts instruction fields, reads the integer register bank and generates the immediate and control signals. |
| [Execute](rtl/rv32i_ex_stage.sv) | Selects ALU operands, computes arithmetic results, evaluates branches and generates jump targets. For RV32M encodings it selects the [multiply/divide unit](rtl/rv32m_alu.sv). |
| [Writeback](rtl/rv32i_wb_stage.sv) | Selects the value sent back to the register bank, including ALU results, loaded data and jump return addresses. |
| [Memory stage](rtl/rv32i_mem_stage.sv) | Selects byte lanes, extends signed or unsigned loads and generates store write enables. Misaligned halfword and word accesses clear `access_valid`. |

