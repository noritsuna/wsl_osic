#!/bin/sh
# ========================================================================
# Initialization of IIC Open-Source EDA Environment
#
# SPDX-FileCopyrightText: 2021-2022 Harald Pretl, Johannes Kepler 
# University, Institute for Integrated Circuits
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0
#
# This script installs OpenLane, xschem, ngspice, magic, netgen,
# and a few other tools for use with SkyWater Technology SKY130.
# ========================================================================

# Define setup environment
# ------------------------
export PDK_ROOT="$HOME/pdk"
export MY_STDCELL=sky130_fd_sc_hd
export SRC_DIR="$HOME/src"
my_path=$(realpath "$0")
my_dir=$(dirname "$my_path")
export SCRIPT_DIR="$my_dir"
export KLAYOUT_VERSION=0.28.17
# This selects which sky130 PDK flavor (A=sky130A, B=sky130B, all=both)  is installed
export OPEN_PDK_ARGS="--with-sky130-variants=A"
export PDK=sky130A
# export VOLARE_H=bdc9412b3e468c102d01b7cf6337be06ec6e9c9a

# ---------------
# Now go to work!
# ---------------

# Update Ubuntu/Xubuntu installation
# ----------------------------------
# the sed is needed for xschem build
echo ">>>> Update packages"
sudo sed -i 's/# deb-src/deb-src/g' /etc/apt/sources.list
sudo apt -qq update -y
sudo apt -qq upgrade -y

# Optional removal of unneeded packages to free up space, important for VirtualBox
# --------------------------------------------------------------------------------
#echo ">>>> Removing packages to free up space"
# FIXME could improve this list
#sudo apt -qq remove -y libreoffice-* pidgin* thunderbird* transmission* xfburn* \
#	gnome-mines gnome-sudoku sgt-puzzles parole gimp*
#sudo apt -qq autoremove -y

# Copy KLayout Configurations
# ----------------------------------
if [ ! -d "$HOME/.klayout" ]; then
	# cp -rf klayout $HOME/.klayout
	mkdir $HOME/.klayout
	cp -f klayoutrc $HOME/.klayout
	cp -rf macros $HOME/.klayout/macros
	cp -rf drc $HOME/.klayout/drc
	cp -rf pymacros $HOME/.klayout/pymacros
	mkdir $HOME/.klayout/libraries
fi

# Install basic tools via apt
# ------------------------------------------
echo ">>>> Installing required packages via APT"
# sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt -qq install -y build-essential python3-pip

# unnecessary packages iic-osic will install:
# octave octave-signal octave-communications octave-control
# htop mc gedit vim vim-gtk3 kdiff3

# Create PDK directory if it does not yet exist
# ---------------------------------------------
if [ -d "$PDK_ROOT" ]; then
	echo ">>>> Delete previous PDK"
	sudo rm -rf $PDK_ROOT
fi

# Install PDK
# ---------------------------------------------
echo ">>>> Installing PDK"
sudo mkdir "$PDK_ROOT"
sudo chown "$USER:staff" "$PDK_ROOT"
cd "$PDK_ROOT" || exit
if [ ! -d "$SRC_DIR/volare" ]; then
	git clone https://github.com/efabless/volare.git "$SRC_DIR/volare"
	cd "$SRC_DIR/volare" || exit
else
	echo ">>>> Updating xschem"
	cd "$SRC_DIR/volare" || exit
	git pull
fi
python3 -m pip install --upgrade --no-cache-dir volare
# python3 -m volare enable --pdk sky130 $VOLARE_H
# python3 -m volare enable --pdk gf180mcu $VOLARE_H

# Install/update xschem
# ---------------------
if [ ! -d "$SRC_DIR/xschem" ]; then
	echo ">>>> Installing xschem"
	sudo apt -qq install -y xterm graphicsmagick ghostscript \
	libx11-6 libx11-dev libxrender1 libxrender-dev \
	libxcb1 libx11-xcb-dev libcairo2 libcairo2-dev  \
	tcl8.6 tcl8.6-dev tk8.6 tk8.6-dev \
	flex bison libxpm4 libxpm-dev gawk tcl-tclreadline
	git clone https://github.com/StefanSchippers/xschem.git "$SRC_DIR/xschem"
	cd "$SRC_DIR/xschem" || exit
	./configure
else
	echo ">>>> Updating xschem"
	cd "$SRC_DIR/xschem" || exit
	git pull
fi
make clean
make -j"$(nproc)" && sudo make install
make clean

# Install/update xschem-gaw
# -------------------------
if [ ! -d "$SRC_DIR/xschem-gaw" ]; then
	echo ">>>> Installing gaw"
	sudo apt -qq install -y libgtk-3-dev alsa libasound2-dev gettext libtool
	git clone https://github.com/StefanSchippers/xschem-gaw.git "$SRC_DIR/xschem-gaw"
	cd "$SRC_DIR/xschem-gaw" || exit
	aclocal && automake --add-missing && autoconf
	#  FIXME this is just a WA for 22.04 LTS
	sed -i 's/GETTEXT_MACRO_VERSION = 0.18/GETTEXT_MACRO_VERSION = 0.20/g' po/Makefile.in.in
	./configure
else
	echo ">>>> Updating gaw"
        cd "$SRC_DIR/xschem-gaw" || exit
        git pull
fi
make clean
make -j"$(nproc)" && sudo make install
make clean

# Install/Update KLayout
# ---------------------
echo ">>>> Installing KLayout-$KLAYOUT_VERSION"
wget https://www.klayout.org/downloads/Ubuntu-22/klayout_$KLAYOUT_VERSION-1_amd64.deb
sudo apt -qq install -y ./klayout_$KLAYOUT_VERSION-1_amd64.deb
rm klayout_$KLAYOUT_VERSION-1_amd64.deb
pip install docopt pandas pip-autoremove

# Install/update magic
# --------------------
if [ ! -d "$SRC_DIR/magic" ]; then
	echo ">>>> Installing magic"
	sudo apt -qq install -y m4 tcsh csh libx11-dev tcl-dev tk-dev \
	libcairo2-dev mesa-common-dev libglu1-mesa-dev
	git clone https://github.com/RTimothyEdwards/magic.git "$SRC_DIR/magic"
	cd "$SRC_DIR/magic" || exit
	git checkout magic-8.3
	./configure
else
	echo ">>>> Updating magic"
	cd "$SRC_DIR/magic" || exit
	git pull
fi
make clean
make && sudo make install
make clean

# Install/update netgen
# ---------------------
if [ ! -d "$SRC_DIR/netgen" ]; then
	echo ">>>> Installing netgen"
	git clone https://github.com/RTimothyEdwards/netgen.git "$SRC_DIR/netgen"
	cd "$SRC_DIR/netgen" || exit
	git checkout netgen-1.5
        ./configure
else
	echo ">>>> Updating netgen"
	cd "$SRC_DIR/netgen" || exit
	git pull
fi
make clean
make -j"$(nproc)" && sudo make install
make clean

# Install/update ngspice
# ----------------------
if [ ! -d "$SRC_DIR/ngspice" ]; then
	echo ">>>> Installing ngspice"
	sudo apt -qq install -y libxaw7-dev libxmu-dev libxext-dev libxft-dev \
	libfontconfig1-dev libxrender-dev libfreetype6-dev libx11-dev libx11-6 \
	libtool bison flex libreadline-dev libfftw3-dev 
	git clone http://git.code.sf.net/p/ngspice/ngspice "$SRC_DIR/ngspice"
	cd "$SRC_DIR/ngspice" || exit
	./autogen.sh
	./configure --disable-debug --with-readline=yes --enable-openmp \
		CFLAGS="-m64 -O2" LDFLAGS="-m64 -s" 
else
	echo ">>>> Updating ngspice"
        cd "$SRC_DIR/ngspice" || exit
        git pull
fi
make clean
make -j"$(nproc)" && sudo make install
make clean

# setup gnome-terminal (WA for Ubuntu 22 WSL2)
# --------
sudo apt -qq install -y gnome-terminal
systemctl --user start gnome-terminal-server

# Finished
# --------
echo ""
echo ">>>> All done. Please restart before you run xxxx-setup.sh"
echo ""