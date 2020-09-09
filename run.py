# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this file,
# You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2014-2020, Lars Asplund lars.anders.asplund@gmail.com

"""
AXI DMA
-------

Demonstrates the AXI read and write slave verification components as
well as the AXI-lite master verification component. An AXI DMA is
verified which uses an AXI master port to read and write data from
external memory. The AXI DMA also has a control register interface
via AXI-lite.
"""
import sys
sys.path.append("/home/emrah/git/vunit")
from pathlib import Path
from vunit import VUnit

VU = VUnit.from_argv()
VU.add_osvvm()
VU.add_com()
VU.add_verification_components()

SRC_PATH = Path(__file__).parent / "src"
#clear
# VU.add_library("data_types").add_source_files("/home/emrah/git/vunit/vunit/vhdl/data_types/src/*.vhd")
#VU.add_library("com_lib").add_source_files("/home/emrah/git/vunit/vunit/vhdl/com/src/*.vhd")
#VU.add_library("vc_lib").add_source_files("/home/emrah/git/vunit/vunit/vhdl/verification_components/src/*.vhd")

VU.add_library("lib").add_source_files([SRC_PATH / "*.vhd", SRC_PATH / "test" / "*.vhd"])

VU.main()
