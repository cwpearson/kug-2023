export ROOT_DIR=/projects/cwpears/kug-2023/blake-h100

export KOKKOS_SHA=f8788ef2ae1940b627cc6ebc6abeef2c34e7e8dc # 2023 11 30
export KOKKOS_SRC="$ROOT_DIR/kokkos-${KOKKOS_SHA:0:8}"
export KOKKOS_BUILD="$ROOT_DIR/kokkos-build-${KOKKOS_SHA:0:8}"
export KOKKOS_INSTALL="$ROOT_DIR/kokkos-install-${KOKKOS_SHA:0:8}"

export KERNELS_REMOTE="git@github.com:cwpearson/kokkos-kernels.git"
export KERNELS_SHA=a91a1f24560692d6a294e764f82f497dc10aeb7d # 2023 12 08
export KERNELS_SRC="$ROOT_DIR/kernels-${KERNELS_SHA:0:8}"
export KERNELS_BUILD="$ROOT_DIR/kernels-build-${KERNELS_SHA:0:8}"

source /projects/x86-64-icelake-rocky8/spack-config/blake-setup-user-module-env.sh
module load gcc/11.3.0 cuda/11.8.0
module load cmake