#!/bin/bash

set -e

Help() {
echo -e "
This script adds a taxonomy (in the form of root ; [...] ; s__C.acnes ) to sequence headers of a fna/fasta file. Its arguments are :
	-t --taxonomy <PATH> path to the taxonomy file from greengenes2.
	-s --sequences <PATH> path tot he fasta/fna file of greengenes2.
	-e --ete4 <FLAG> flag to set to ete4 input (different column for taxids). \u2691
	-o --output <PATH> path tot he output directory.
	-h --help displays this help message and exits.
"
}

if [ $# -eq 0 ]
then
	Help
	exit 0
fi

ete4=0

while [ $# -gt 0 ]
do
	case $1 in
	-t | --taxonomy) taxonomy="$2"
	shift 2;;
        -s | --sequences) sequences="$2"
	shift 2;;
	-o | --output) output="$2"
	shift 2;;
	-e | --ete4) ete4=1
	shift ;;
	-h | --help) Help; exit 0;;
	-* | --*) unknown="$1"; echo -e "ERROR: unknown argument: $unknown. Exiting."; exit 1;;
	*) shift ;;
	esac
done

if [ ! -f "$taxonomy" ]
then
	echo "ERROR: Input file ${taxonomy} does not exist or is not a regular file. Exiting"
	exit 1
elif [ ! -f "$sequences" ]
then
	echo "ERROR: Input file ${sequences} does not exist or is not a regular file. Exiting"
        exit 1
fi

if [ -d "$output" ]
then
        echo -e "WARNING: output directory ${output} already exists."
else
        mkdir "$output"
fi

if [ "$ete4" -eq 0 ]
then
	awk 'BEGIN {FS="\t"}
	     (NR==FNR) {arr[$1]=$4}
	     (NR!=FNR) {
	         if ($0 ~ /^>/) {
	             key = substr($0, 2);
	             if (key in arr) {
	                 print $0"|kraken:taxid|"arr[key];
	             } else {
	                 print $0"|kraken:taxid|131567";
	             }
	         } else {
	             print $0;
	         }
	     }' "$taxonomy" "$sequences" > "$output"/gg2_for_kraken2.fna
else
	awk 'BEGIN {FS="\t"}
             (NR==FNR) {arr[$1]=$4}
             (NR!=FNR) {
                 if ($0 ~ /^>/) {
                     key = substr($0, 2);
                     if (key in arr) {
                         print $0"|kraken:taxid|"arr[key];
                     } else {
	                 print $0"|kraken:taxid|"131567;
                     }
                 } else {
                     print $0;
                 }
             }' "$taxonomy" "$sequences" > "$output"/gg2_for_kraken_ete4.fna
fi
