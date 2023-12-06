#! /bin/bash

set -eou pipefail

srun -N 1 -A csc465 -G 1 -n 1 -t 60 ./run-worker.sh
