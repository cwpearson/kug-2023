#! /bin/bash

set -eou pipefail

source "$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"/env.sh

LOG_DIR="$(date +"%Y%m%d_%H%M%S")_run"
export LOG_DIR
mkdir -p "$LOG_DIR"


srun -N 1 -p PV --exclude=blake15 -n1 -t 1 lscpu |& tee "$LOG_DIR/lscpu.log" || true
srun -N 1 -p PV --exclude=blake15 -n1 -t 1 hostname |& tee "$LOG_DIR/hostname.log" || true
srun -N 1 -p PV --exclude=blake15 -n1 -t 1 cat /proc/cpuinfo |& tee "$LOG_DIR/cpuinfo.log" || true

srun -N 1 -p PV --exclude=blake15 -n1 -t 120 "$KERNELS_BUILD"/perf_test/sparse/KokkosKernels_sparse_spmv_benchmark -f /projects/cwpears/sparc_gpu_problems/single_gpu/matrix.mm
