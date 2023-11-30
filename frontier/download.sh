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

srun -n1 -t 1 module list |& tee "$LOG_DIR/module-list.log"
srun -n1 -t 1 lscpu |& tee "$LOG_DIR/lscpu.log"
srun -n1 -t 1 hostname |& tee "$LOG_DIR/hostname.log"

## Configure Kokkos
cmake -S "$KOKKOS_SRC" -B "$KOKKOS_BUILD" \
-DCMAKE_INSTALL_PREFIX="$KOKKOS_INSTALL" \
-DCMAKE_CXX_STANDARD=17 \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_CXX_COMPILER=CC \
-DKokkos_ENABLE_HIP=ON \
-DKokkos_ARCH_NATIVE=ON \
-DKokkos_ARCH_AMD_GFX90A=ON

## Build & Install Kokkos
cmake --build "$KOKKOS_BUILD" -j "$(nproc)" -t install

## Configure Kernels
cmake -S "$KERNELS_SRC" -B "$KERNELS_BUILD" \
-DKokkos_DIR="$KOKKOS_INSTALL/lib64/cmake/Kokkos" \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_CXX_COMPILER=CC \
-DKokkosKernels_ENABLE_TPL_ROCSPARSE=ON \
-DKokkosKernels_ENABLE_TPL_ROCBLAS=ON \

## Build Kernels
cmake --build "$KERNELS_BUILD" -j "$(nproc)"