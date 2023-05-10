#!/usr/bin/bash

./tsv_left_join.py sra.tsv biosample_reform.tsv 1 0 >sra_biosample.tsv

t=4
taxonkit_v0.12.0 lineage -j $t -i 15 sra_biosample_filt.tsv >tmp.tsv
taxonkit_v0.12.0 reformat -j $t -i 29 -f "{k};{p};{c};{o};{f};{g};{s}" tmp.tsv | cut -f1-28,30 >sra_biosample_filt_tax.tsv
rm tmp.tsv
