#!/bin/bash

if [[ -z "$TOOLS_DIR" ]]; then
    export TOOLS_DIR=./work/tools
fi

if [[ -z "$VERILATOR_ROOT" ]]; then
    export VERILATOR_ROOT=$TOOLS_DIR/verilator
fi

VERILATOR_BIN=$VERILATOR_ROOT/bin/verilator

echo "------------------- Installing Tools --------------------------"
echo "TOOLS_DIR         '$TOOLS_DIR'"
echo "VERILATOR_ROOT    '$VERILATOR_ROOT'"

set -e

mkdir -p $TOOLS_DIR

if [ ! -e  $VERILATOR_BIN ]; then

    echo "Building Verilator..."
    echo
    echo -en 'travis_fold:start:before_install.verilator\\r'
    echo

    git clone https://git.veripool.org/git/verilator $VERILATOR_ROOT

    cd $VERILATOR_ROOT

    git checkout v4.100

    autoconf

    ./configure

    echo "Running $(nproc) wide."

    make -j $(nproc)

    sudo make install
    
    echo
    echo -en 'travis_fold:end:before_install.verilator\\r'
    echo

    cd -

else

    echo "Using cached Verilator build..."

fi


