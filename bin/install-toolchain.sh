#!/bin/bash

if [[ -z "$TOOLS_DIR" ]]; then
    export TOOLS_DIR=./work/tools
fi

RV_DIR=$TOOLS_DIR/riscv64-unknown-elf

if [[ -z "$RISCV" ]]; then
    export RISCV=$RV_DIR
fi

TC_URL=https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14.tar.gz
TC_FILE=$TOOLS_DIR/toolchain.tar.gz
ARCHIVE_FOLDER=$TOOLS_DIR/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14

echo "------------------- Installing Tools --------------------------"
echo "TOOLS_DIR         '$TOOLS_DIR'"
echo "RISCV             '$RISCV'"
echo "Toolchain URL     '$TC_URL'"
echo "Archive Folder    '$ARCHIVE_FOLDER'"

set -e

mkdir -p $TOOLS_DIR

if [ ! -e $RISCV/bin/riscv64-unknown-elf-gcc ]; then

    if [ ! -f $TC_FILE ]; then

        echo "Downloading $TC_URL"

        wget -O $TC_FILE $TC_URL

    else

        echo "Toolchain archive already downloaded."

    fi

    echo "Unpacking $TC_FILE"

    tar -xzf $TC_FILE -C $TOOLS_DIR

    ls $TOOLS_DIR

    export RISCV=$TOOLS_DIR/$ARCHIVE_FOLDER

    echo "Toolchain installed to '$RISCV'"

else

    echo "Using cached toolchain installation..."

fi


