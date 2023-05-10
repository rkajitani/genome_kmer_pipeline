#!/usr/bin/env python

import sys

col_names = [
    "BioSample",
    "Taxonomy",
    "Organism",
    "Title",
    "ploidy",
    "propagation",
    "sex",
    "estimated_size",
    "tissue",
    "lat_lon",
    "geo_loc_name",
    "env_biome",
    "env_broad_scale",
    "env_local_scale",
    "collection_date"
]

col_idx_dict = dict()
for i, col_name in enumerate(col_names):
    col_idx_dict[col_name] = i

print("\t".join(col_names))
with open(sys.argv[1]) as fin:
    for line in fin:
        f = line.rstrip("\n").split("\t")
        out_list = ["."] * len(col_names)
        for i in range(0, 4):
            out_list[i] = f[i]
        for i in range(4, len(f)):
            attr = f[i].split("$")
            if len(attr) >= 2 and attr[0] in col_idx_dict:
                out_list[col_idx_dict[attr[0]]] = "$".join(attr[1:])
        print("\t".join(out_list))
