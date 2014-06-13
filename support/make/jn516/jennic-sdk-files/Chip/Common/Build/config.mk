###############################################################################
#
# MODULE:   config.mk
#
# DESCRIPTION: Selects a configuration makefile based on JENNIC_CHIP and
#              JENNIC_CHIP_FAMILY.
# 
###############################################################################
#
# This software is owned by NXP B.V. and/or its supplier and is protected
# under applicable copyright laws. All rights are reserved. We grant You,
# and any third parties, a license to use this software solely and
# exclusively on NXP products [NXP Microcontrollers such as JN5148, JN5142, JN5139]. 
# You, and any third parties must reproduce the copyright and warranty notice
# and any other legend of ownership on each copy or partial copy of the 
# software.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# Copyright NXP B.V. 2012. All rights reserved
#
###############################################################################

###############################################################################
# Toolchain

TOOL_BASE_DIR ?= $(SDK_BASE_DIR)/Tools

SUBWCREV ?= $(TOOL_BASE_DIR)/TortoiseSVN/bin/subwcrev.exe

###############################################################################
# Include the chip or chip family definitions.
# Chip takes precendence over chip family

ifdef JENNIC_CHIP
include $(SDK_BASE_DIR)/Chip/$(JENNIC_CHIP)/Build/config_$(JENNIC_CHIP).mk
else
ifdef JENNIC_CHIP_FAMILY
include $(SDK_BASE_DIR)/Chip/$(JENNIC_CHIP_FAMILY)/Build/config_$(JENNIC_CHIP_FAMILY).mk
else
$(error JENNIC_CHIP or JENNIC_CHIP_FAMILY must be specified)
endif
endif

###############################################################################

ifndef JENNIC_STACK
JENNIC_STACK = MAC
endif

###############################################################################
# Define the selected Jennic chip

CFLAGS += -DJENNIC_CHIP=$(JENNIC_CHIP)
CFLAGS += -DJENNIC_CHIP_$(JENNIC_CHIP)
CFLAGS += -DJENNIC_CHIP_FAMILY=$(JENNIC_CHIP_FAMILY)
CFLAGS += -DJENNIC_CHIP_FAMILY_$(JENNIC_CHIP_FAMILY)

CFLAGS += -DJENNIC_STACK_$(JENNIC_STACK)

###############################################################################
# Chip independent compiler options

CFLAGS += -Wall
#CFLAGS += -Wunreachable-code

###############################################################################
# Compiler Paths

CC	= gcc
AS	= as
LD	= ld
AR	= ar
NM	= nm
STRIP	= strip
SIZE	= size
OBJCOPY = objcopy
OBJDUMP = objdump
RANLIB	= ranlib

ifdef LINUX_CROSS_COMPILE
CC:=$(LINUX_CROSS_COMPILE)-$(CC)
AS:=$(LINUX_CROSS_COMPILE)-$(AS)
LD:=$(LINUX_CROSS_COMPILE)-$(LD)
AR:=$(LINUX_CROSS_COMPILE)-$(AR)
NM:=$(LINUX_CROSS_COMPILE)-$(NM)
STRIP:=$(LINUX_CROSS_COMPILE)-$(STRIP)
SIZE:=$(LINUX_CROSS_COMPILE)-$(SIZE)
OBJCOPY:=$(LINUX_CROSS_COMPILE)-$(OBJCOPY)
OBJDUMP:=$(LINUX_CROSS_COMPILE)-$(OBJDUMP)
else

ifdef CROSS_COMPILE
CC:=$(TOOL_BASE_DIR)/$(TOOLCHAIN_PATH)/bin/$(CROSS_COMPILE)-$(CC)
AS:=$(TOOL_BASE_DIR)/$(TOOLCHAIN_PATH)/bin/$(CROSS_COMPILE)-$(AS)
LD:=$(TOOL_BASE_DIR)/$(TOOLCHAIN_PATH)/bin/$(CROSS_COMPILE)-$(LD)
AR:=$(TOOL_BASE_DIR)/$(TOOLCHAIN_PATH)/bin/$(CROSS_COMPILE)-$(AR)
NM:=$(TOOL_BASE_DIR)/$(TOOLCHAIN_PATH)/bin/$(CROSS_COMPILE)-$(NM)
STRIP:=$(TOOL_BASE_DIR)/$(TOOLCHAIN_PATH)/bin/$(CROSS_COMPILE)-$(STRIP)
SIZE:=$(TOOL_BASE_DIR)/$(TOOLCHAIN_PATH)/bin/$(CROSS_COMPILE)-$(SIZE)
OBJCOPY:=$(TOOL_BASE_DIR)/$(TOOLCHAIN_PATH)/bin/$(CROSS_COMPILE)-$(OBJCOPY)
OBJDUMP:=$(TOOL_BASE_DIR)/$(TOOLCHAIN_PATH)/bin/$(CROSS_COMPILE)-$(OBJDUMP)
endif

endif

###############################################################################
