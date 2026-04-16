# GENIE_PATH ?= $(shell pwd)/../../../genie

# ifeq ($(wildcard $(GENIE_PATH)),)
# GENIE_PATH := $(shell pwd)/genie
# endif

# include $(GENIE_PATH)/Makefile

GENIE_PATH ?= $(PWD)/genie

ifeq ($(wildcard $(GENIE_PATH)/Makefile),)
$(error Genie not found at $(GENIE_PATH). Please clone it into ./genie)
endif

include $(GENIE_PATH)/Makefile