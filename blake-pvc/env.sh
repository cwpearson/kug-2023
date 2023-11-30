export ROOT_DIR=/projects/cwpears/kug-2023/blake-pvc

export KOKKOS_SHA=f8788ef2ae1940b627cc6ebc6abeef2c34e7e8dc # 2023 11 30
export KOKKOS_SRC="$ROOT_DIR/kokkos-${KOKKOS_SHA:0:8}"
export KOKKOS_BUILD="$ROOT_DIR/kokkos-build-${KOKKOS_SHA:0:8}"
export KOKKOS_INSTALL="$ROOT_DIR/kokkos-install-${KOKKOS_SHA:0:8}"

export KERNELS_SHA=a80eb9114ddda2d9454e4f3cc8a3dd5143ecdfc8 # 2023 11 30
export KERNELS_SRC="$ROOT_DIR/kernels-${KERNELS_SHA:0:8}"
export KERNELS_BUILD="$ROOT_DIR/kernels-build-${KERNELS_SHA:0:8}"

source /projects/x86-64-icelake-rocky8/spack-config/blake-setup-user-module-env.sh
module load intel-oneapi-compilers/2023.1.0 intel-oneapi-dpl/2022.1.0
module load cmake

# Required for the hashmap accumulator
export ZES_ENABLE_SYSMAN=1