#!/bin/bash

#source activate genome_kmer_wf_test

if [ "$#" -ne 1 ]; then
	echo "Usage: $0 sra_id"
	exit 1
fi

s=$1
max_file_size=500G

/usr/bin/time prefetch --max-size $max_file_size -o raw.sra $s >prefetch.stdout 2>prefetch.stderr
