#!/usr/bin/bash

source activate ncbi

cat header.txt > efetch_sra_rm_invalid.xml
fgrep -v -f header.txt -f footer.txt ../efetch_sra.xml | ./xml_rm_invalid_docsum.py >> efetch_sra_rm_invalid.xml
cat footer.txt >> efetch_sra_rm_invalid.xml

echo -e "Run\tBioSample\tPlatform\tModel\tCenterName\tLibrarySource\tLibraryStrategy\tLibrarySelection\tLibraryLayout\tbases\tspots\tspots_with_mates\tInsertSize\tavgLength" >sra.tsv
cat efetch_sra_rm_invalid.xml | /usr/bin/time xtract -pattern Row -def "NA" -element Run BioSample Platform Model CenterName LibrarySource LibraryStrategy LibrarySelection LibraryLayout bases spots spots_with_mates InsertSize avgLength 2>extract_sra.log | perl -F"\t" -ane 'print if (@F == 14)' >>sra.tsv
