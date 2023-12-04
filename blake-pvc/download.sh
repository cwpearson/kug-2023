#! /bin/bash

srun -N 1 -p PV --exclude=blake15 -n 1 -t 120 ./download-worker.sh