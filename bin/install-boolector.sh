#!/bin/bash

if [[ -z "$TOOLS_DIR" ]]; then
    export TOOLS_DIR=./work/tools
fi

if [[ -z "$BOOLECTOR_ROOT" ]]; then
    export BOOLECTOR_ROOT=$TOOLS_DIR/boolector
fi

BOOLECTOR_PATH=$BOOLECTOR_ROOT/install

export PATH=$BOOLECTOR_PATH:$PATH

BOOLECTOR_BIN=$BOOLECTOR_PATH/boolector

echo "------------------- Installing Tools --------------------------"
echo "TOOLS_DIR         '$TOOLS_DIR'"
echo "BOOLECTOR_ROOT    '$BOOLECTOR_ROOT'"
echo "PATH              '$PATH'"

set -e

mkdir -p $TOOLS_DIR

if [ ! -e  $BOOLECTOR_BIN ]; then

    echo "Building Boolector..."
    echo
    echo -en 'travis_fold:start:before_install.boolector\\r'
    echo

    git clone https://github.com/boolector/boolector
    cd boolector
    ./contrib/setup-btor2tools.sh
    ./contrib/setup-lingeling.sh
    ./configure.sh
    make -C build -j$(nproc)
    mkdir -p $BOOLECTOR_PATH
    sudo cp build/bin/{boolector,btor*} $BOOLECTOR_PATH
    sudo cp deps/btor2tools/bin/btorsim $BOOLECTOR_PATH
    
    echo
    echo -en 'travis_fold:end:before_install.boolector\\r'
    echo

    cd -

else

    echo "Using cached Boolector build..."

fi


echo "boolector executable path: $(which boolector)"

