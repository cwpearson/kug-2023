
set -eou pipefail

source "$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"/env.sh

LOG_DIR="$(date +"%Y%m%d_%H%M%S")_run"
export LOG_DIR
mkdir -p "$LOG_DIR"

srun -n 1 -t 1 /opt/rocm-5.7.0/bin/rocm-smi \
  --showdriverversion \
  --showproductname \
  --showmclkrange \
  -v \
  --showsclkrange \
  --showfwinfo \
  |& tee "$LOG_DIR/rocm-smi.log"  || true
srun -n 1 -t 1 /opt/rocm-5.7.0/bin/rocminfo |& tee "$LOG_DIR/rocminfo.log" || true
srun -n 1 -t 1 lscpu |& tee "$LOG_DIR/lscpu.log" || true
srun -n 1 -t 1 hostname |& tee "$LOG_DIR/hostname.log" || true
srun -n 1 -t 1 cat /proc/cpuinfo |& tee "$LOG_DIR/cpuinfo.log" || true
srun -n 1 -t 1 env |& tee "$LOG_DIR/env.log" || true

srun -n 1 -t 60 "$KERNELS_BUILD"/perf_test/blas/blas3/KokkosKernels_Blas3_gemm_benchmark --hip 0 |& tee "$LOG_DIR/gemm.log"
srun -n 1 -t 60 "$KERNELS_BUILD"/perf_test/sparse/KokkosKernels_sparse_spmv_benchmark -f /projects/cwpears/sparc_gpu_problems/single_gpu/matrix.mm |& tee "$LOG_DIR/spmv.log"