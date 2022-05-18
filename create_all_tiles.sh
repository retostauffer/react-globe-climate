#!/bin/bash
# ----------------------------------------------------------
# Used during development
# ----------------------------------------------------------

set -u
set -e

# To loop trough
##VARS=(ci swvl1 tp)
##YEARS=(1982 2019 2020 2021)
##YEARS=(2021)
##MONTHS=(1 2 3 4 5 6 7 8 9 10 11 12)

##for var in ${VARS[@]}; do
##    for year in ${YEARS[@]}; do
##        for month in ${MONTHS[@]}; do
##            printf "\nCreating tiles for %d/%d for %s\n" "${year}" "${month}" "${var}"
##            ./visualize_tiles.py -y ${year} -m ${month} -v ${var}
##        done
##    done
##done


# ---------------------------------------------------------
# ---------------------------------------------------------
VARS=(2t ci swvl1 tp)
curr_year=`date -d "-45 days" +%Y`
curr_mon=`date -d "-45 days" +%m`

for var in ${VARS[@]}; do
    year=1979
    while [ $year -le $((curr_year)) ] ; do
        month=1
        while [ $month -le 12 ] ; do
            if [ $year -eq $((curr_year)) ] && [ $month -gt $((curr_mon)) ] ; then
                break
            fi
            printf "Creating tiles for %d/%d for %s ..." "${year}" "${month}" "${var}"

            ## Checking number of existing files
            ## _tiles/tp/202106/
            tilesdir=`printf "_tiles/%s/%04d%02d" "${var}" "${year}" "${month}"`
            npngs=`find ${tilesdir} -name "*.png" | wc -l`
            if [ $npngs -ge 84 ] ; then
                printf " found %d tiles, skipping ...\n" ${npngs}
            else
                printf " start processing ...\n"
                ./visualize_tiles.py -y ${year} -m ${month} -v ${var}
            fi
            let month=$month+1
        done
        let year=$year+1
    done
done


