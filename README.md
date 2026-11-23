# Single-Cycle RV32I Datapath

**Aditya Chinchore · Electronics and Communication Engineering · PES University**  
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

For example, `mul x3, x1, x2` reads two registers and selects the low 32 bits of their product in EX. With `x1 = 7` and `x2 = 6`, the result is 42. The execution-stage testbench drives these operand values directly and checks that result.

### Connecting a system-level testbench

Supply the instruction at `pc` through `instruction_in`. Drive `rf_external_we`, `rf_external_waddr` and `memtoreg` for register writeback. For loads and stores, connect `alu_result` as the memory-stage address and `rs2_data` as the store value. Feed the formatted `load_data` back through `mem_out`. The [data-memory model](rtl/rv32i_data_memory.sv) provides byte write enables and a little-endian word read interface.

## Run the tests

From the repository root, use Icarus Verilog with SystemVerilog enabled and the `vvp` runtime. Select one testbench per simulation with `-s`.

```sh
mkdir -p build
for tb in tb_rv32i_mem_stage tb_rv32m_compliance tb_rv32m_integration; do
    iverilog -g2012 -s "$tb" -o "build/$tb.vvp" rtl/*.sv "verification/$tb.sv" &&
        vvp "build/$tb.vvp" || exit 1
done
```

| Testbench | Directed checks | Coverage |
| --- | ---: | --- |
| [Memory stage](verification/tb_rv32i_mem_stage.sv) | 9 | Load sign/zero extension and byte, halfword and word store masks |
| [RV32M ALU](verification/tb_rv32m_compliance.sv) | 14 | All eight M operations, division by zero and signed division overflow |
| [Execution-stage integration](verification/tb_rv32m_integration.sv) | 5 | Selection between RV32I addition and RV32M multiplication, division and remainder |

Each bench reports its pass/fail counts and calls `$fatal` on a mismatch. These are directed module tests. The file named `tb_rv32m_compliance.sv` checks arithmetic vectors against expected values; full-system ISA certification would require a separate verification flow.
