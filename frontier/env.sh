export ROOT_DIR=/lustre/orion/csc465/scratch/cpearson/kug-2023

export KOKKOS_SHA=f8788ef2ae1940b627cc6ebc6abeef2c34e7e8dc # 2023 11 30
export KOKKOS_SRC="$ROOT_DIR/kokkos-${KOKKOS_SHA:0:8}"
export KOKKOS_BUILD="$ROOT_DIR/kokkos-build-${KOKKOS_SHA:0:8}"
export KOKKOS_INSTALL="$ROOT_DIR/kokkos-install-${KOKKOS_SHA:0:8}"

export KERNELS_SHA=a80eb9114ddda2d9454e4f3cc8a3dd5143ecdfc8 # 2023 11 30
export KERNELS_SRC="$ROOT_DIR/kernels-${KERNELS_SHA:0:8}"
export KERNELS_BUILD="$ROOT_DIR/kernels-build-${KERNELS_SHA:0:8}"

module load PrgEnv-amd