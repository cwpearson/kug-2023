#!/bin/bash

set -eou pipefail

srun -A m3953 -C "gpu&hbm40g" --qos regular -N 1 -t 120 ./run-worker.sh
