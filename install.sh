# -------------------------------------------------------------------------------------------------
# Copyright (C) 2023 Advanced Micro Devices, Inc
# SPDX-License-Identifier: MIT
# ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- --
#!/bin/bash

SCRIPT_DIR=$( realpath $( dirname -- "$0"; ) )
echo $SCRIPT_DIR
exit

# Build MTS necessary patch to xrfdc package
echo "Cloning the PYNQ repository"
git clone https://github.com/Xilinx/PYNQ
cd PYNQ
git apply ../boards/patches/xrfdc_mts.patch

pushd /usr/local/share/pynq-venv/lib/python3.10/site-packages/pynqutils
echo "INFO: patching pynqutils begin"
git apply $SCRIPT_DIR/pynqutils.patch
echo "INFO: patching pynqutils done"
popd

pushd sdbuild/packages/xrfdc
. pre.sh
. qemu.sh
popd
cd ..

# Create a device-tree overlay to access PL-DRAM
sudo apt-get update -y
sudo apt-get install -y device-tree-compiler
cd boards/$BOARD/dts
make
cp ddr4.dtbo ../../../rfsoc_mts/
cd ../../..

# Install python package and notebook
python3 -m pip install . --no-build-isolation
pynq-get-notebooks RFSoC-MTS -p $PYNQ_JUPYTER_NOTEBOOKS
echo "$BOARD Ready..."
