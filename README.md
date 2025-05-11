# [moku-examples-fipy](https://github.com/sealablab/moku-examples-fipy)
Sealablab's fork() of [upstream moku-examples](https://github.com/liquidinstruments/moku-examples/tree/main/mcc)

You can find the VHDL and Verilog files you are look for..
This fork exists so that [Moku-Fi-Py](https://github.com/sealablab/Moku-FI-Py


All synthesizable HDL must follow the SystemVerilog 2012 synthesizable subset as supported by Vivado 2022.2
**specifically, you should use** 
*  `logic`
*  `always_ff`
*  `enum,`
*  `typedef`

## Verilog to **avoid**
* but avoiding any behavioral-only features like:
* `assert`
* `initial`
*  `class`
*  `dynamic types`
