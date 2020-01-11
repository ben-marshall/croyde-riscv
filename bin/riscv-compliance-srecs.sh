#!/bin/sh

VARIANTS="rv32i rv32im rv32imc rv64i rv64im"

OBJCOPY=$RISCV/bin/riscv64-unknown-elf-objcopy
OBJDUMP=$RISCV/bin/riscv64-unknown-elf-objdump
DEST=$REPO_HOME/work/riscv-compliance

export PATH=$RISCV/bin:$PATH

mkdir -p $DEST

for V in $VARIANTS
do

    cd extern/riscv-compliance
    make -B RISCV_PREFIX=riscv64-unknown-elf- \
            RISCV_TARGET=riscvOVPsim \
            RISCV_DEVICE=$V
    cd -

    SRC_DIR=$REPO_HOME/extern/riscv-compliance/work/$V
    SRC_FILES=`find $SRC_DIR -executable -type f`

    mkdir -p $DEST/$V

    for F in $SRC_FILES
    do
        $OBJCOPY -O srec --srec-forceS3 $F $F.srec
        chmod -x $F.srec
        BNAME=`basename $F`
        grep "80.*:" $F.objdump \
            | grep -v ">:" | cut -c 11- | sed 's/\t//' \
            | sort | uniq | sed 's/ +/ /' | sed 's/\t/ /' \
            | sed 's/\(^....    \)    /0000\1/' \
            > $DEST/$V/$BNAME.gtkwl
        mv $F.srec $DEST/$V/$BNAME.srec
        $OBJDUMP -D $F > $DEST/$V/$BNAME.dis
        echo $DEST/$V/$BNAME.srec
    done

done
