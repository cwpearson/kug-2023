#! /bin/bash

set -eou pipefail

source "$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"/env.sh

LOG_DIR="$(date +"%Y%m%d_%H%M%S")_run"
export LOG_DIR
mkdir -p "$LOG_DIR"

lscpu |& tee "$LOG_DIR/lscpu.log" || true
hostname |& tee "$LOG_DIR/hostname.log" || true
cat /proc/cpuinfo |& tee "$LOG_DIR/cpuinfo.log" || true
env |& tee "$LOG_DIR/env.log" || true

date
"$KERNELS_BUILD"/perf_test/blas/blas3/KokkosKernels_Blas3_gemm_benchmark --cuda 0 |& tee "$LOG_DIR/gemm.log"
date
"$KERNELS_BUILD"/perf_test/sparse/KokkosKernels_sparse_spmv_benchmark -f "$ROOT_DIR"/matrix.mm |& tee "$LOG_DIR/spmv.log"
date
