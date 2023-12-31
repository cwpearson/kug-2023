#! /bin/bash

set -eou pipefail

source "$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"/env.sh

LOG_DIR="$(date +"%Y%m%d_%H%M%S")_build"
export LOG_DIR
mkdir -p "$LOG_DIR"

git clone git@github.com:kokkos/kokkos.git "$KOKKOS_SRC" || true
(cd "$KOKKOS_SRC" && git checkout $KOKKOS_SHA) || true
git clone git@github.com:kokkos/kokkos-kernels.git "$KERNELS_SRC" || true
(cd "$KERNELS_SRC" && git checkout $KERNELS_SHA) || true

# re-set up our environment
source "$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"/env.sh

module list |& tee "$LOG_DIR/module-list.log"
lscpu |& tee "$LOG_DIR/lscpu.log"
hostname |& tee "$LOG_DIR/hostname.log"
env |& tee "$LOG_DIR/env.log" || true

## Configure Kokkos
cmake -S "$KOKKOS_SRC" -B "$KOKKOS_BUILD" \
-DCMAKE_INSTALL_PREFIX="$KOKKOS_INSTALL" \
-DCMAKE_CXX_STANDARD=17 \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_CXX_COMPILER="$KOKKOS_SRC"/bin/nvcc_wrapper \
-DKokkos_ENABLE_CUDA=ON \
-DKokkos_ARCH_NATIVE=ON \
-DKokkos_ARCH_AMPERE80=ON \
|& tee "$LOG_DIR/kokkos-config.log"

## Build & Install Kokkos
cmake --build "$KOKKOS_BUILD" -j "$(nproc)" -t install \
|& tee "$LOG_DIR/kokkos-build.log"

## Configure Kernels
cmake -S "$KERNELS_SRC" -B "$KERNELS_BUILD" \
-DKokkos_DIR="$KOKKOS_INSTALL/lib64/cmake/Kokkos" \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_CXX_COMPILER="$KOKKOS_SRC"/bin/nvcc_wrapper \
-DKokkosKernels_ENABLE_TPL_CUSPARSE=ON \
-DKokkosKernels_ENABLE_TPL_CUBLASE=ON \
-DKokkosKernels_ENABLE_TESTS=ON \
-DKokkosKernels_ENABLE_PERFTESTS=ON \
-DKokkosKernels_ENABLE_BENCHMARK=ON \
-DTPLCUBLAS_ROOT=/opt/nvidia/hpc_sdk/Linux_x86_64/22.7/math_libs/11.7/lib64 \
|& tee "$LOG_DIR/kernels-config.log"

## Build Kernels
VERBOSE=1 make -C "$KERNELS_BUILD" -j "$(nproc)" \
KokkosKernels_Blas3_gemm_benchmark \
KokkosKernels_sparse_spmv_benchmark \
|& tee "$LOG_DIR/kernels-build.log"
