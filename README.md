# Sequence Detector #
This is a Sequence Detector device modelled in VHDL with a locking mechanism which unlocks when the sequence `1-4-2-3-3` is inputted. The device has 1 initialization button and 4 input buttons (`1, 2, 3, 4`). The initialization button can also be used to relock the device after unlocking with the sequence. The correct sequence must be inputted within 12 inputs after initialization, otherwise the device will stop accepting inputs until initialized again!

## Entities ##
* Sequence Detection Entity to detect the sequence from the stream of inputs and change the lock state accordingly. Three sequence detection architectures were implemented: Register-based, Moore, Mealy. Register-based is the default, recommended and best performing architecture. You can switch to the Moore or Mealy architecture by specifying them in line 42 of `main.vhd`.
* Buttons Entity to handle the raw button inputs and process them to remove signal bounce or stutter. The processed result is then outputted as a button state.
* Lock Entity to maintain the lock state and control the LED outputs based on that lock state.

## FPGA ##
Made for a NEXYS A7 FPGA