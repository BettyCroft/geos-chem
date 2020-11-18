#!/bin/bash

#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: intTests_slurm.sh
#
# !DESCRIPTION: Runs integration tests on the various GEOS-Chem Classic
#  run directories (using the SLURM scheduler).  Compilation tests and
#  execution tests are submitted as separate SLURM jobs, using dependencies.
#\\
#\\
# !CALLING SEQUENCE:
#  ./intTests_slurm.sh /integration/test/root/folder ENV-FILE          or
#  ./intTests_slurm.sh /integration/test/root/folder ENV-FILE short=1
#
# !REVISION HISTORY:
#  03 Nov 2020 - R. Yantosca - Initial version
#  See the subsequent Git history with the gitk browser!
#EOP
#------------------------------------------------------------------------------
#BOC

#=============================================================================
# Check arguments and define variables
#=============================================================================

# 1st argument: Root directory for integration tests
INT_TEST_ROOT=${1}
if [[ "x${INT_TEST_ROOT}" == "x" ]]; then
    echo "ERROR: The root-level directory for tests has not been specified!"
    exit
fi

# 2nd argument: Environment file
ENV_FILE=${2}
if [[ "x${ENV_FILE}" == "x" ]]; then
    echo "ERROR: The enviroment file (w/ module loads) has not been specified!"
    exit
fi

# 3rd argument: Run a short integration test (for development)?
SHORT=${3}

# Current directory
THIS_DIR=$(pwd -P)

#=============================================================================
# Create integration test directories in the root folder
#=============================================================================

# Create GEOS-Chem run directories in the integration test root folder
./intTestCreate.sh ${INT_TEST_ROOT} ${ENV_FILE} ${SHORT}
if [[ $? -ne 0 ]]; then
   exit 0
fi

# Change to the integration test root folder
if [[ -d ${INT_TEST_ROOT} ]]; then
    cd ${INT_TEST_ROOT}
else
    echo "ERROR: ${INT_TEST_ROOT} is not a valid directory!  Exiting..."
    exit 1
fi

#=============================================================================
# Submit compilation tests script
#=============================================================================
OUTPUT=$(sbatch intTestCompile_slurm.sh)
OUTPUT=($OUTPUT)
CMP_ID=${OUTPUT[3]}

#=============================================================================
# Submit execution tests script as a job dependency
#=============================================================================
OUTPUT=$(sbatch --dependency=afterok:${CMP_ID} intTestExecute_slurm.sh)
OUTPUT=($OUTPUT)
EXE_ID=${OUTPUT[3]}

# Change back to this directory
cd ${THIS_DIR}

#=============================================================================
# Cleanup and quit
#=============================================================================
echo ""
echo "Compilation tests submitted as SLURM job ${CMP_ID}"
echo "Execution   tests submitted as SLURM job ${EXE_ID}"

# Free local variables
unset ENV_FILE
unset INT_TEST_ROOT
unset JOBID
unset OUTPUT
unset SHORT
unset THIS_DIR
#EOC