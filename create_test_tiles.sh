#!/bin/bash
# ----------------------------------------------------------
# Used during development
# ----------------------------------------------------------

set -u
set -e

# To loop trough
VARS=(2t ci swvl1 tp)
YEARS=(1982 2019 2020 2021)
MONTH=10

for var in ${VARS[@]}; do
    for year in ${YEARS[@]}; do
        printf "\nCreating tiles for %d/%d for %s\n" "${year}" "${MONTH}" "${var}"
        ./visualize_tiles.py -y ${year} -m ${MONTH} -v ${var}
    done
done
