# GG2_2024_for_Kraken2

Download the sequences `2024.09.seqs.fna.gz` and `2024.09.taxonomy.id.tsv.gz` files.

```bash
#run command in a mamba env containing ete4
python get_taxid_from_gg2.py 2024.09.taxonomy.id.tsv
#add header
bash add_taxo_to_seq_header.sh -e -o test_gg2 -s 2024.09.seqs.fna -t 2024.09.taxonomy.name2taxid.ete4.tsv 
```

Build the kraken2 DB.

```bash
#preparing DB
kraken2-build --download-taxonomy --db GG2
kraken2-build --download-library archaea --db GG2
kraken2-build --download-library bacteria --db GG2
#adding sequences
kraken2-build --add-to-library chr1.fa --db GG2
kraken2-build --build --db GG2 --threads 100
```
