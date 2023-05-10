#!/usr/bin/bash

source activate ncbi

cat header.txt > efetch_biosample_rm_invalid.xml
fgrep -v -f header.txt -f footer.txt ../efetch_biosample.xml | ./xml_rm_invalid_docsum.py >> efetch_biosample_rm_invalid.xml
cat footer.txt >> efetch_biosample_rm_invalid.xml

cat efetch_biosample_rm_invalid.xml | /usr/bin/time xtract \
	-pattern DocumentSummary \
	-def "." \
	-element DocumentSummary/Accession DocumentSummary/Taxonomy DocumentSummary/Organism DocumentSummary/Title \
	-block Id -if Id@db -equals SRA -pfx "SRA$" -element Id \
	-block Attribute -if Attribute@attribute_name -equals ploidy -pfx "ploidy$" -element Attribute \
	-block Attribute -if Attribute@attribute_name -equals propagation -pfx "propagation$" -element Attribute \
	-block Attribute -if Attribute@attribute_name -equals sex -pfx "sex$" -element Attribute \
	-block Attribute -if Attribute@attribute_name -equals estimated_size -pfx "estimated_size$" -element Attribute \
	-block Attribute -if Attribute@attribute_name -equals tissue -pfx "tissue$" -element Attribute \
	-block Attribute -if Attribute@attribute_name -equals lat_lon -pfx "lat_lon$" -element Attribute \
	-block Attribute -if Attribute@attribute_name -equals geo_loc_name -pfx "geo_loc_name$" -element Attribute \
	-block Attribute -if Attribute@attribute_name -equals env_biome -pfx "env_biome$" -element Attribute \
	-block Attribute -if Attribute@attribute_name -equals env_broad_scale -pfx "env_broad_scale$" -element Attribute \
	-block Attribute -if Attribute@attribute_name -equals env_local_scale -pfx "env_local_scale$" -element Attribute \
	-block Attribute -if Attribute@attribute_name -equals collection_date -pfx "collection_date$" -element Attribute \
	> biosample_raw.tsv 2> xtract_biosample.log

./reform_biosample_tsv.py biosample_raw.tsv >biosample_reform.tsv 
