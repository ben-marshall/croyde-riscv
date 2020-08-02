#!/bin/bash

if [[ -z "$TOOLS_DIR" ]]; then
    export TOOLS_DIR=./work/tools
fi

if [[ -z "$SYMBIYOSYS_ROOT" ]]; then
    export SYMBIYOSYS_ROOT=$TOOLS_DIR/symbiyosys
fi

SYMBIYOSYS_PATH=$SYMBIYOSYS_ROOT/usr/local/bin

export PATH=$SYMBIYOSYS_PATH:$PATH

SYMBIYOSYS_BIN=$SYMBIYOSYS_PATH/sby

echo "------------------- Installing Tools --------------------------"
echo "TOOLS_DIR         '$TOOLS_DIR'"
echo "SYMBIYOSYS_ROOT   '$SYMBIYOSYS_ROOT'"
echo "PATH              '$PATH'"

set -e

mkdir -p $TOOLS_DIR

if [ ! -e  $SYMBIYOSYS_BIN ]; then

    echo "Building SymbiYosys..."
    echo
    echo -en 'travis_fold:start:before_install.symbiyosys\\r'
    echo

    git clone https://github.com/YosysHQ/SymbiYosys.git $SYMBIYOSYS_ROOT

    cd $SYMBIYOSYS_ROOT

    git checkout b6dc1c9da3b697da72fd13f6c0d59ac021fd49de

    sudo make install DESTDIR=$SYMBIYOSYS_ROOT
    
    echo
    echo -en 'travis_fold:end:before_install.symbiyosys\\r'
    echo

    cd -

else

    echo "Using cached SymbiYosys build..."

fi

echo "SBY executable path: $(which sby)"

