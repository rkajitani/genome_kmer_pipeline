#!/usr/bin/env python

import sys
import argparse
import pandas as pd
import numpy as np


def main():
    parser = argparse.ArgumentParser(description="", formatter_class=argparse.MetavarTypeHelpFormatter)

    parser.add_argument("df", type=str, help="target dataframe (TSV file)")
    parser.add_argument("-m", "--min_bases", type=int, default=0, help="minimum total bases of reads")
    parser.add_argument("-M", "--max_bases", type=int, default=0, help="maximum total bases of reads")
    parser.add_argument("-r", "--min_avg_len", type=int, default=0, help="minimum average length of reads")
    parser.add_argument("-p", "--paired", action="store_true", help="only select paired-ends")
    parser.add_argument("-i", "--illumina", action="store_true", help="only select Illumina")
    parser.add_argument("-s", "--hi_mi_nova", action="store_true", help="only select HiSeq, MiSeq, and NovaSeq")
    parser.add_argument("-l", "--lat_lon", action="store_true", help="only select ones with lat_lon attribute")
    parser.add_argument("-c", "--date", action="store_true", help="only select ones with collection_date attribute")
    parser.add_argument("-d", "--diploid", action="store_true", help="only select diploid")

    args = parser.parse_args()

    df = pd.read_table(args.df, sep="\t")
    df.replace(".", np.nan, inplace=True)
    df["Taxonomy"] = pd.to_numeric(df["Taxonomy"], errors="coerce")

    filt_df = df[
            (df["LibrarySource"] == "GENOMIC") &
            (df["LibraryStrategy"] == "WGS") &
            (df["LibrarySelection"] == "RANDOM")
    ]
    filt_df = filt_df.dropna(subset=["Taxonomy"])
    filt_df["Taxonomy"] = filt_df["Taxonomy"].astype("int")

    if args.min_bases > 0:
        filt_df = filt_df[filt_df["bases"] >= args.min_bases]
    if args.max_bases > 0:
        filt_df = filt_df[filt_df["bases"] <= args.max_bases]
    if args.min_avg_len > 0:
        filt_df = filt_df[filt_df["avgLength"] >= args.min_avg_len]
    if args.paired:
        filt_df = filt_df[filt_df["LibraryLayout"] == "PAIRED"]
    if args.illumina:
        filt_df = filt_df[filt_df["Platform"] == "ILLUMINA"]
    if args.hi_mi_nova:
        filt_df = filt_df[filt_df["Model"].str.contains("NovaSeq|HiSeq|MiSeq", case=False)]
    if args.diploid:
        filt_df = filt_df[
            filt_df["ploidy"].isna() | 
            filt_df["ploidy"].str.lower().str.startswith("diplo") | 
            filt_df["ploidy"].str.lower().str.startswith("2")
        ]
    if args.lat_lon:
        filt_df = filt_df.dropna(subset=["lat_lon"])
    if args.date:
        filt_df.dropna(subset=["collection_date"])

    filt_df.to_csv(sys.stdout, index=False, sep="\t", na_rep=".")


if __name__ == "__main__":
    main()
