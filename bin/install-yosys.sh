#!/bin/bash

if [[ -z "$TOOLS_DIR" ]]; then
    export TOOLS_DIR=./work/tools
fi

if [[ -z "$YOSYS_ROOT" ]]; then
    export YOSYS_ROOT=~/$TOOLS_DIR/verilator
fi

YOSYS_BIN=$YOSYS_ROOT/yosys

echo "------------------- Installing Tools --------------------------"
echo "TOOLS_DIR         '$TOOLS_DIR'"
echo "YOSYS_ROOT        '$YOSYS_ROOT'"

set -e

mkdir -p $TOOLS_DIR

if [ ! -e  $YOSYS_BIN ]; then

    echo "Building Yosys..."
    echo
    echo -en 'travis_fold:start:before_install.yosys\\r'
    echo

    git clone https://github.com/YosysHQ/yosys.git $YOSYS_ROOT

    cd $YOSYS_ROOT

    git checkout yosys-0.9

    make config-gcc

    echo "Running $(nproc) wide."

    make -j $(nproc)

    sudo make install
    
    echo
    echo -en 'travis_fold:end:before_install.yosys\\r'
    echo

    cd -

else

    echo "Using cached Yosys build..."

fi



