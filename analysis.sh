#!/bin/bash

#source activate genome_kmer_wf_test

if [ "$#" -ne 1 ]; then
	echo "Usage: $0 num_threads"
	exit 1
fi

t=$1


rm fasterq-dump.done fastp.done genomescope2.done kmc.done kraken2.done &>/dev/null

error_handle() {
	exit_code=$?
    for s in fasterq-dump fastp kraken2 kmc genomescope2
    do
        if [ ! -e $s.done ]; then
            echo "error: $s step failed (exit code, $exit_code)!" >&2
            exit 1
        fi
    done
    exit 1
}

trap error_handle ERR


m=128G
tmp=.
/usr/bin/time fasterq-dump --seq-defline '@$si/$ri' --qual-defline '+' --split-3 --threads $t --mem $m --temp $tmp raw.sra >fasterq-dump.stdout 2>fasterq-dump.stderr
touch fasterq-dump.done


q=15
/usr/bin/time fastp -w $t -5 -3 -q $q -i raw_1.fastq -I raw_2.fastq -o trim_1.fastq -O trim_2.fastq >fastp.stdout 2>fastp.stderr
rm raw_1.fastq raw_2.fastq
touch fastp.done



kraken2_db=/data1/kajitani/DB/kraken2/k2_standard_20230314
conf_score=0.1
/usr/bin/time kraken2 --confidence $conf_score --paired --threads $t --db $kraken2_db --output kraken2_out.tsv trim_1.fastq trim_2.fastq >kraken2.stdout 2>kraken2.stderr
cut -f2,3 kraken2_out.tsv | perl -ane 'print($F[0], "/1\n") if ($F[1] eq "0" or $F[1] eq "9606")' >filt_1.list
perl -pne 's/1$/2/' filt_1.list >filt_2.list
for i in 1 2
do
    seqkit grep -w0 -f filt_${i}.list trim_${i}.fastq >filt_${i}.fastq 2>seqkit.stderr &
done
wait
rm kraken2_out.tsv trim_1.fastq trim_2.fastq
touch kraken2.done


k=21
m=128
min_occ=1
max_occ=10000000
hist_max_occ=10000000
ulimit -n 4096
ls filt_1.fastq filt_2.fastq >filt_reads.list
mkdir -p kmc_tmp
/usr/bin/time kmc -k$k -m$m -t$t -ci$min_occ -cs$max_occ -cx$max_occ @filt_reads.list k${k}_db kmc_tmp >k${k}_kmc.stdout 2>k${k}_kmc.stderr
/usr/bin/time kmc_tools transform k${k}_db histogram k${k}_histo.tsv -cx$max_occ >k${k}_histo.stdout 2>k${k}_histo.stderr
rm -rf kmc_tmp k${k}_db.kmc_suf k${k}_db.kmc_pre filt_1.fastq filt_2.fastq filt_1.list filt_2.list
touch kmc.done


/usr/bin/time genomescope2 -i k${k}_histo.tsv -k $k -p 2 -o k${k}_genomescope2_out >k${k}_genomescope2.stdout 2>k${k}_genomescope2.stderr
echo -e "het\tkcov\terr\tdup\tlen" >k21_genomescope2_out.tsv
perl -ne 'print(join("\t", ($1 * 100, $2, $3, $4, $5)), "\n") if (/Model converged het:(\S+) kcov:(\S+) err:(\S+) model fit:(\S+) len:(\S+)/)' k21_genomescope2.stdout >>k21_genomescope2_out.tsv
touch genomescope2.done
