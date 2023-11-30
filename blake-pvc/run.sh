#! /bin/bash
#SBATCH -N 1
#SBATCH -p all

set -eou pipefail

source "$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"/env.sh

LOG_DIR="$(date +"%Y%m%d_%H%M%S")_run"
export LOG_DIR
mkdir -p "$LOG_DIR"


srun -n1 -t 1 lscpu |& tee "$LOG_DIR/lscpu.log" || true
srun -n1 -t 1 hostname |& tee "$LOG_DIR/hostname.log" || true
srun -n1 -t 1 cat /proc/cpuinfo |& tee "$LOG_DIR/cpuinfo.log" || true