#!/usr/bin/env python

import sys

if len(sys.argv) != 5:
    print("usage:", sys.argv[0], "left.tsv right.tsv left_col_index right_col_index(0-origin)", file=sys.stderr)
    exit(0)

import pandas as pd

left_df = pd.read_table(sys.argv[1], sep="\t", header=None, index_col=int(sys.argv[3]), dtype=object)
right_df = pd.read_table(sys.argv[2], sep="\t", header=None, index_col=int(sys.argv[4]), dtype=object)
left_df.index = left_df.index.astype(str)
right_df.index = right_df.index.astype(str)
merged_df = pd.merge(left_df, right_df, left_index=True, right_index=True, how="left")
merged_df.to_csv(sys.stdout, sep="\t", header=None)
