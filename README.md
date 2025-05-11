# [moku-examples-fipy](https://github.com/sealablab/moku-examples-fipy)
Sealablab's fork() of [upstream moku-examples](https://github.com/liquidinstruments/moku-examples/tree/main/mcc)

You can find the VHDL and Verilog files you are look for..
This fork exists so that [Moku-Fi-Py](https://github.com/sealablab/Moku-FI-Py

### SystemVerilog Coding Guidelines for Synthesis (Vivado 2022.2)

When writing Verilog HDL intended for synthesis on Moku Cloud Compile (Vivado backend):

✅ DO:
- Use `logic` for all internal and port signals
- Use `typedef enum logic [...]` for FSMs and control states
- Use `always_ff` and `always_comb` instead of `always @(posedge ...)`
- Use packed `struct` and `typedef` for better clarity (if needed)
- Use `generate` blocks and parameters as usual

❌ AVOID:
- `initial` blocks (Vivado will ignore or warn)
- `assert`, `covergroup`, or any verification-only constructs
- `class`, `new`, `virtual`, or object-oriented features
-  `dynamic types`
- Dynamic arrays, queues, or associative arrays
- Fork/join, threads, or event semaphores

