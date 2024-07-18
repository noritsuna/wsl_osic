#!/bin/sh
# ========================================================================
# Initialization of IIC Open-Source EDA Environment for Ubuntu WSL2
# This script is for use with SG13G2.
# ========================================================================

# Define setup environment
# ------------------------
export PDK_ROOT="$HOME/pdk"
export MY_STDCELL=sg13g2_stdcells
export SRC_DIR="$HOME/src"
my_path=$(realpath "$0")
my_dir=$(dirname "$my_path")
export SCRIPT_DIR="$my_dir"
export PDK_GIT_NAME="IHP-Open-PDK"
export PDK_NAME="ihp-sg13g2"
export PDK="$PDK_GIT_NAME/$PDK_NAME"
export OPENVAF_VERSION="_23_5_0_"
export KLAYOUT_VERSION="0.29.4"

# --------
echo ""
echo ">>>> Initializing..."
echo ""

# Install/Update KLayout
# ---------------------
echo ">>>> Installing KLayout-$KLAYOUT_VERSION"
wget https://www.klayout.org/downloads/Ubuntu-22/klayout_$KLAYOUT_VERSION-1_amd64.deb
sudo apt remove -y klayout
sudo apt -qq install -y ./klayout_$KLAYOUT_VERSION-1_amd64.deb
rm klayout_$KLAYOUT_VERSION-1_amd64.deb

# Delete previous PDK
# ---------------------------------------------
if [ -d "$PDK_ROOT" ]; then
	echo ">>>> Delete previous PDK"
	sudo rm -rf "$PDK_ROOT"
	sudo mkdir "$PDK_ROOT"
	sudo chown "$USER:staff" "$PDK_ROOT"
fi

# Install OpenVAF
# -----------------------------------
cd $HOME
mkdir bin
cd bin
wget https://openva.fra1.cdn.digitaloceanspaces.com/openvaf$OPENVAF_VERSIONlinux_amd64.tar.gz
tar zxf openvaf$OPENVAF_VERSIONlinux_amd64.tar.gz
rm openvaf$OPENVAF_VERSIONlinux_amd64.tar.gz
export PATH=$HOME/bin:$PATH

# Install PDK
# -----------------------------------
cd $PDK_ROOT
git clone https://github.com/IHP-GmbH/IHP-Open-PDK.git

cd $PDK_GIT_NAME
pip install -r requirements.txt
cd $PDK_NAME/libs.tech/xschem/
export PDK_ROOT="$HOME/pdk/$PDK_GIT_NAME"
python3 install.py
export PDK_ROOT="$HOME/pdk"
export PYTHONPYCACHEPREFIX=/tmp

# Copy KLayout Configurations
# ----------------------------------
if [ ! -d "$HOME/.klayout" ]; then
	mkdir $HOME/.klayout
#	mkdir -p $HOME/.klayout/tech/$PDK_NAME/
#	cp -f $PDK_ROOT/$PDK/libs.tech/klayout/tech/sg13g2.lyp $HOME/.klayout/tech/$PDK_NAME/
#	cp -f $PDK_ROOT/$PDK/libs.tech/klayout/tech/sg13g2.lyt $HOME/.klayout/tech/$PDK_NAME/
	mkdir -p $HOME/.klayout/tech/
	cp -f $PDK_ROOT/$PDK/libs.tech/klayout/tech/sg13g2.lyp $HOME/.klayout/tech/
	cp -f $PDK_ROOT/$PDK/libs.tech/klayout/tech/sg13g2.lyt $HOME/.klayout/tech/

	cp -rf $PDK_ROOT/$PDK/libs.tech/klayout/tech/drc $HOME/.klayout/drc
	cp -rf $PDK_ROOT/$PDK/libs.tech/klayout/tech/lvs $HOME/.klayout/lvs
	cp -rf $PDK_ROOT/$PDK/libs.tech/klayout/tech/macros $HOME/.klayout/macros
	cp -rf $PDK_ROOT/$PDK/libs.tech/klayout/tech/pymacros $HOME/.klayout/pymacros
	cp -rf $PDK_ROOT/$PDK/libs.tech/klayout/python $HOME/.klayout/python

	mkdir $HOME/.klayout/libraries
fi

# Install GDSfactory
# -----------------------------------
pip install gdsfactory

# Install OpenEMS
# -----------------------------------
sudo apt-get install -y build-essential cmake git libhdf5-dev libvtk7-dev libboost-all-dev libcgal-dev libtinyxml-dev qtbase5-dev libvtk7-qt-dev octave liboctave-dev gengetopt help2man groff pod2pdf bison flex libhpdf-dev libtool 
sudo pip install numpy matplotlib cython h5py

cd $SRC_DIR
if [ ! -d "$SRC_DIR/openEMS-Project" ]; then
	git clone --recursive https://github.com/thliebig/openEMS-Project.git
	cd openEMS-Project
else
	cd openEMS-Project
	git pull --recurse-submodules
fi
./update_openEMS.sh ~/opt/openEMS --with-hyp2mat --with-CTB --python

# Create .spiceinit
# -----------------
{
	echo "set num_threads=$(nproc)"
	echo "set ngbehavior=hsa"
	echo "set ng_nomodcheck"
} > "$HOME/.spiceinit"

# Create iic-init.sh
# ------------------
if [ ! -d "$HOME/.xschem" ]; then
	mkdir "$HOME/.xschem"
fi
{
	echo "export PDK_ROOT=$PDK_ROOT"
	echo "export PDK=$PDK"
	echo "export STD_CELL_LIBRARY=$MY_STDCELL"
	echo "export PYTHONPYCACHEPREFIX=/tmp"
	echo "export PATH=\"$HOME/bin:$PATH\""
} >> "$HOME/.bashrc"

# Copy various things
# -------------------
cp -f $PDK_ROOT/$PDK/libs.tech/xschem/xschemrc $HOME/.xschem

# Fix paths in xschemrc to point to correct PDK directory
# -------------------------------------------------------

# Finished
# --------
echo ""
echo ">>>> All done. Please restart or re-read .bashrc"
echo ""
