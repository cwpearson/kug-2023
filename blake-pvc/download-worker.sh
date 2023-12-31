#! /bin/bash

set -eou pipefail

source "$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"/env.sh

LOG_DIR="$(date +"%Y%m%d_%H%M%S")_build"
export LOG_DIR
mkdir -p "$LOG_DIR"

# intel blows up SSH for some reason?
#module del intel/oneAPI/hpc-toolkit/2022.1.2
git clone git@github.com:kokkos/kokkos.git "$KOKKOS_SRC" || true
(cd "$KOKKOS_SRC" && git checkout $KOKKOS_SHA) || true
git clone "$KERNELS_REMOTE" "$KERNELS_SRC" || true
(cd "$KERNELS_SRC" && git checkout $KERNELS_SHA) || true
git clone "$PTI_REMOTE" "$PTI_SRC" || true
(cd "$PTI_SRC" && git checkout $PTI_SHA) || true

# re-set up our environment
#source "$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"/env.sh

module list |& tee "$LOG_DIR/module-list.log"
lscpu |& tee "$LOG_DIR/lscpu.log"
hostname |& tee "$LOG_DIR/hostname.log"
env 2>&1 >> "$LOG_DIR/env.log"

## Configure onetrace
cmake -S "$PTI_SRC/tools/onetrace" -B "$PTI_BUILD" \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_CXX_COMPILER=icpx \
|& tee "$LOG_DIR"/onetrace-config.log

## build onetrace
make -C "$PTI_BUILD" \
|& tee "$LOG_DIR/onetrace-build.log"

## Configure Kokkos
cmake -S "$KOKKOS_SRC" -B "$KOKKOS_BUILD" \
-DCMAKE_INSTALL_PREFIX="$KOKKOS_INSTALL" \
-DCMAKE_CXX_STANDARD=17 \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_CXX_COMPILER=icpx \
-DKokkos_ENABLE_SYCL=ON \
-DKokkos_ARCH_SPR=ON \
-DKokkos_ARCH_INTEL_PVC=ON \
-DKokkos_ENABLE_ONEDPL=OFF \
-DCMAKE_CXX_FLAGS="-fp-model=precise -fno-finite-math-only -mavx512f" \
-DBUILD_SHARED_LIBS=ON

## Build & Install Kokkos
cmake --build "$KOKKOS_BUILD" -j "$(nproc)" -t install

## Configure Kernels
cmake -S "$KERNELS_SRC" -B "$KERNELS_BUILD" \
-DKokkos_DIR="$KOKKOS_INSTALL/lib64/cmake/Kokkos" \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_CXX_COMPILER=icpx \
-DKokkosKernels_ENABLE_TPL_MKL=ON \
-DKokkosKernels_ENABLE_TESTS=ON \
-DKokkosKernels_ENABLE_PERFTESTS=ON \
-DKokkosKernels_ENABLE_BENCHMARK=ON \
-DCMAKE_CXX_FLAGS="-fp-model=precise -mavx512f" \
-DBUILD_SHARED_LIBS=ON

## Build Kernels
VERBOSE=1 make -C "$KERNELS_BUILD" -j "$(nproc)" \
KokkosKernels_Blas3_gemm_benchmark \
KokkosKernels_sparse_spmv_benchmark \
|& tee "$LOG_DIR/kernels-build.log"
