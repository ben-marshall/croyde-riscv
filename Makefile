
ifndef REPO_HOME
    $(error "Please run 'source ./bin/source.me.sh' to setup the project workspace")
endif
ifndef RISCV
    $(error "Please set the RISCV environment variable")
endif

export CORE_RTL_DIR  = $(REPO_HOME)/rtl/core
export CORE_RTL_SRCS = $(shell find $(CPU_RTL_DIR) -name *.v)

export PATH:=$(RISCV)/bin:$(YOSYS_ROOT)/:$(PATH)

YOSYS           = $(YOSYS_ROOT)/yosys
YOSYS_SMTBMC    = $(YOSYS_ROOT)/yosys-smtbmc

VERILATOR       = $(VERILATOR_ROOT)/bin/verilator

RISCV_XLEN      = 64

CC              = $(RISCV)/bin/riscv$(RISCV_XLEN)-unknown-elf-gcc
AS              = $(RISCV)/bin/riscv$(RISCV_XLEN)-unknown-elf-as
AR              = $(RISCV)/bin/riscv$(RISCV_XLEN)-unknown-elf-ar
OBJDUMP         = $(RISCV)/bin/riscv$(RISCV_XLEN)-unknown-elf-objdump
OBJCOPY         = $(RISCV)/bin/riscv$(RISCV_XLEN)-unknown-elf-objcopy

include $(REPO_HOME)/src/fsbl/Makefile.in
include $(REPO_HOME)/src/rvkrypto/Makefile.in
include $(REPO_HOME)/src/examples/arty-helloworld/Makefile.in

include $(REPO_HOME)/flow/verilator/Makefile.in
include $(REPO_HOME)/flow/design-assertions/Makefile.in
include $(REPO_HOME)/flow/synthesis/Makefile.in
include $(REPO_HOME)/flow/riscv-formal/Makefile.in

include $(REPO_HOME)/verif/share/unit/unit-common.mk
include $(REPO_HOME)/verif/core/unit/Makefile.in
include $(REPO_HOME)/verif/ccx/unit/Makefile.in

include $(REPO_HOME)/flow/embench/Makefile.in
include $(REPO_HOME)/flow/arch-test/Makefile.in

build-unit-tests-core: $(filter build-unit-core%,$(UNIT_TEST_BUILD_TARGETS))
build-unit-tests-ccx : $(filter build-unit-ccx%,$(UNIT_TEST_BUILD_TARGETS))
run-unit-tests-core: $(filter run-unit-core%,$(UNIT_TEST_RUN_TARGETS))
run-unit-tests-ccx : $(filter run-unit-ccx%,$(UNIT_TEST_RUN_TARGETS))

clean:
	rm -rf work/*
