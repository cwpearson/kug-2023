#!/bin/bash
#SBATCH  -A m3953
#SBATCH -C "gpu&hbm40g"
#SBATCH  -G 1
#SBATCH --qos regular
#SBATCH -N 1
#SBATCH -t 60

set -eou pipefail

srun -A m3953 -C "gpu&hbm40g" -G 1 --qos regular -N 1 -t 60 ./run-worker.sh
