#!/bin/sh
# ========================================================================
# IIC Open-Source EDA Environment for Ubuntu WSL2
# This script will delete some stuffs in your home directory
# to change the PDK. 
# ========================================================================
rm -f $HOME/.magicrc
rm -f $HOME/.spiceinit
rm -rf $HOME/.klayout
rm -rf $HOME/.xschem
rm -rf $HOME/.gaw
rm $HOME/bin/openvaf
sed -i -e '/export PDK_ROOT=/d' $HOME/.bashrc
sed -i -e '/export PDK=/d' $HOME/.bashrc
sed -i -e '/export STD_CELL_LIBRARY=/d' $HOME/.bashrc
sed -i -e '/export PYTHONPYCACHEPREFIX=/d' $HOME/.bashrc
sed -i -e '/export PATH=/d' $HOME/.bashrc
echo ">> All done. Now you can re-install or change the PDK."
echo ">>"
echo ">> You have to remove local pip packages by yourself."
echo ">> If you installed GF180MCU: pip-autoremove gf180"
echo ">> If you installed SKY130  : pip-autoremove sky130 flayout"
echo ">> If you installed ihp-sg13g2  : pip-autoremove gdsfactory"
echo ">>"
echo ">> Please check the dependencies if you are using this"
echo ">> environment with other than Open-Source EDA tools."