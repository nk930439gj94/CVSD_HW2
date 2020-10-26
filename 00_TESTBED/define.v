//Global definition
`define CYCLE       10.0
`define HCYCLE      (`CYCLE/2)
`define MAX_CYCLE   300
`define Inst "../00_TESTBED/PATTERN/inst.dat"
`define Status "../00_TESTBED/PATTERN/status.dat"

// opcode definition
`define OP_LW 1
`define OP_SW 2
`define OP_ADD 3
`define OP_SUB 4
`define OP_ADDI 5
`define OP_OR 6
`define OP_XOR 7
`define OP_BEQ 8
`define OP_BNE 9
`define OP_EOF 10

// MIPS status definition
`define R_TYPE_SUCCESS 0
`define I_TYPE_SUCCESS 1
`define MIPS_OVERFLOW 2
`define MIPS_END 3
