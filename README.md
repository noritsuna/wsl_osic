# wsl_osic

SKY130 or GF180MCU development tools for Ubuntu 22 (WSL2)

  1. Run `tool-install.sh`
```
git clone https://github.com/3zki/wsl_osic
cd wsl_osic
./tool-install.sh
```

  2. Restart your environment
  3. Choose the PDK you want to use...

## SKY130
  4. Run `sky130-setup.sh`
  5. Enjoy!
#### Uninstall or change the PDK
  6. If you want to change the PDK, run `uninstall.sh`
  7. Delete pip packages: `sky130` and `flayout`.
     pip-autoremove might be useful:
```
pip-autoremove sky130 flayout
```
  8. Now you can change the PDK

#### Differences between Standard PDK

Under construction...
* Fixed xschemrc
* Fixed Pcells to support the latest GDSFactory
* Added GDSFactory PCell Library
* Fixed DRC/LVS/PEX menu

## GF180MCU
  4. Run `gf180mcu-setup.sh`
  5. Enjoy!
#### Uninstall or change the PDK
  6. If you want to change the PDK, run `uninstall.sh`
  7. Delete pip packages: `gf180`.
     pip-autoremove might be useful:
```
pip-autoremove gf180
```
  8. Now you can change the PDK

#### Differences between Standard PDK

Under construction...

* Fixed xschemrc
* Changed color scheme table in GF180MCU technology files
* Added undefined but used layers such as Nwell_Label in mcu7t5v0 standard cells
  * Changed LVS rules to recognize Nwell_Label, LVPwell_Label and Pad_Label

* Fixed Pcells to support the latest GDSFactory

* Add DRC/LVS/PEX menu
  * Magic LVS cannot recognize V5_XTOR therefore menu replaces "05v0" with "06v0" in source netlist
