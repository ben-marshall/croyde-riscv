
export REPO_HOME=`pwd`
export REPO_WORK=$REPO_HOME/work

if [[ -z "$RISCV" ]]; then
    export RISCV=/opt/riscv
fi

if [[ -z "$VERILATOR_ROOT" ]]; then
    export VERILATOR_ROOT=/home/ben/tools/verilator
fi

if [[ -z "$YOSYS_ROOT" ]]; then
    export YOSYS_ROOT=/home/ben/tools/yosys
fi

export PATH=$RISCV:$PATH

echo "------------------------[CPU Project Setup]--------------------------"
echo "\$REPO_HOME      = $REPO_HOME"
echo "\$REPO_WORK      = $REPO_WORK"
echo "\$RISCV          = $RISCV"
echo "\$VERILATOR_ROOT = $VERILATOR_ROOT"
echo "\$YOSYS_ROOT     = $YOSYS_ROOT"
echo "\$PATH           = $PATH"
echo "---------------------------------------------------------------------"
