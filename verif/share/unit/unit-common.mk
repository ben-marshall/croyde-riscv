
UNIT_TEST_BUILD_TARGETS =
UNIT_TEST_RUN_TARGETS =

#
# 1. Unit test catagory: {core, ccx}
define unit_test_build_dir
$(REPO_WORK)/${1}/unit
endef

#
# 1. Unit test catagory: {core, ccx}
# 2. Unit test name
define map_unit_test_elf
$(call unit_test_build_dir,${1})/${2}/${2}.elf
endef

#
# 1. Unit test catagory: {core, ccx}
# 2. Unit test name
define map_unit_test_objdump
$(call unit_test_build_dir,${1})/${2}/${2}.objdump
endef

#
# 1. Unit test catagory: {core, ccx}
# 2. Unit test name
define map_unit_test_srec
$(call unit_test_build_dir,${1})/${2}/${2}.srec
endef

#
# 1. Unit test catagory: {core, ccx}
# 2. Unit test name
define map_unit_test_hex 
$(call unit_test_build_dir,${1})/${2}/${2}.hex 
endef

#
# 1. Unit test catagory: {core, ccx}
# 2. Unit test name
define map_unit_test_gtkwave
$(call unit_test_build_dir,${1})/${2}/${2}.gtkwl
endef

#
# 1. Unit test catagory: {core, ccx}
# 2. Unit test name
define map_unit_test_log
$(call unit_test_build_dir,${1})/${2}/${2}.log
endef

#
# 1. Unit test catagory: {core, ccx}
# 2. Unit test name
define map_unit_test_vcd
$(call unit_test_build_dir,${1})/${2}/${2}.vcd
endef


#
# 1. Unit test catagory: {core, ccx}
# 2. Unit test name
# 3. Unit test CFLAGS
# 4. Unit test Assembly/C sources
# 5. HEX OBJCOPY Flags
define build_unit_test

$(call map_unit_test_elf,${1},${2}) : ${4}
	mkdir -p $(dir $(call map_unit_test_elf,${1},${2}))
	$(CC) ${3} -o $${@} $${^}

$(call map_unit_test_objdump,${1},${2}) : $(call map_unit_test_elf,${1},${2})
	$(OBJDUMP) -D $${<} > $${@}

$(call map_unit_test_srec,${1},${2}) : $(call map_unit_test_elf,${1},${2})
	$(OBJCOPY) -O srec --srec-forceS3 --srec-len=4 $${<} $${@}

$(call map_unit_test_hex,${1},${2}) : $(call map_unit_test_elf,${1},${2})
	$(OBJCOPY) ${5} -O verilog $${<} $${@}

$(call map_unit_test_gtkwave,${1},${2}) : $(call map_unit_test_objdump,${1},${2})
	grep "10.*:" $${<} \
	    | grep -v ">:" | cut -c 14- | sed 's/\t//' \
	    | sort | uniq | sed 's/ +/ /' | sed 's/\t/ /' \
	    | sed 's/\(^....    \)    /0000\1/' \
	    > $${@}

build-unit-${1}-${2} : $(call map_unit_test_elf,${1},${2}) \
                       $(call map_unit_test_objdump,${1},${2}) \
                       $(call map_unit_test_srec,${1},${2}) \
                       $(call map_unit_test_hex,${1},${2}) \
                       $(call map_unit_test_gtkwave,${1},${2})

UNIT_TEST_BUILD_TARGETS += build-unit-${1}-${2}

endef

