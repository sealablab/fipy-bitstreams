# 2D scan

```
⟶ & ⟵: Fast axis
↓ :      Slow axis

Start⟶ ------------- ↓
 ↓---------------- ⟵
 ⟶ -------------- ↓
 ↓---------------- ⟵
         ...
 ⟶--------------- end
```

The 2D scan module receives trigger signals as step inputs rather than the internal clock. Each trigger signal increments the fast axis by one step while keeping the slow axis unchanged. Once the fast axis reaches its limit, the slow axis increments by one step, and the fast axis reverses direction for the next pass.

When both the fast and slow axes reach their respective step limits, the module stops scanning and enters an inactive state, ignoring any further trigger signals.

## VHDL Files

[`Top.vhd`](vhdl/Top.vhd): Connects the 2D scan module with the MCC input/output wrapper.
[`ScanGen.vhd`](vhdl/ScanGen.vhd): Implements the state machine that controls the ROM readout counter and manages the 2D scan module's state.
[`ROM_Fast.vhd`](vhdl/ROM_Fast.vhd): Defines the scan pattern for the fast axis.
[`ROM_Slow.vhd`](vhdl/ROM_Slow.vhd): Defines the scan pattern for the slow axis.

The two ROM files currently contain placeholder ramp scan patterns and will need to be updated with the final scan data.

Information on the voltage-to-digital bit (LSB) resolution can be found [here](https://apis.liquidinstruments.com/mcc/io.html#analog-i-o-scaling).

## Control registers

`Control0 0th bit`: Reset. Set this bit HIGH, then LOW to reset the 2D scan module.
`Control1 (15 downto 0)`: Trigger Level. Specifies the trigger threshold. Refer to [this resource](https://apis.liquidinstruments.com/mcc/io.html#analog-i-o-scaling) for the voltage-to-digital bit (LSB) resolution.
`Control2 (15 downto 0)`: Fast Axis Step Count. Defines the number of steps for the fast axis with a maximum of 65,535 steps.
`Control3 (15 downto 0)`: Slow Axis Step Count. Defines the number of steps for the slow axis with a maximum of 65,535 steps.

## Input and outputs

`InputA`: Trigger input.
`OutputA`: Fast scan signal.
`OutputB`: Slow scan signal.
