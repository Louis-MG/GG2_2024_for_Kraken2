#!/usr/bin/env python3
from ete4 import NCBITaxa
import csv
import argparse

# Initialize NCBITaxa
ncbi = NCBITaxa()

def get_taxid_from_line(feature_id, taxon):
    '''
    This function goes through the given taxonomy from the most precise assignation (species)
    to the least precise. Each name is tested for a taxid. It stops at the first success.
    Sequence ID, assigned name (successful level), rank of the successful level, taxid and rank
    name are written in  the output file.
    '''
    # Split the taxonomy string into a dictionary of rank:value
    tax_dict = {}
    for item in taxon.split('; '):
        if not item.strip():
            continue
        rank, value = item.split('__', 1)
        tax_dict[rank] = value

    # Define the order of ranks to try, from most specific to least
    rank_order = ['s', 'g', 'f', 'o', 'c', 'p', 'd']
    rank_names = {
        's': 'species',
        'g': 'genus',
        'f': 'family',
        'o': 'order',
        'c': 'class',
        'p': 'phylum',
        'd': 'domain'
    }

    with open('2024.09.taxonomy.name2taxid.ete4.tsv', 'a', newline='') as csvfile:
        linewriter = csv.writer(csvfile, delimiter="\t",
                            quotechar=None)
        for rank in rank_order:
            if rank in tax_dict and tax_dict[rank]:
                try:
                    name = tax_dict[rank]
                    # get a taxid for the name
                    name2taxid = ncbi.get_name_translator([name])
                    if name in name2taxid and name2taxid[name]:
                        taxid = name2taxid[name][0]
                        rank_of_taxid = ncbi.get_rank([taxid])[taxid]
                        # verifies that the rank found corresponds to the rank used
                        if rank_of_taxid == rank_names[rank]:
                            linewriter.writerow([feature_id, name, rank_names[rank], taxid, rank_of_taxid])
                            break
                        else:
                            continue
                except Exception as e:
                    linewriter.writerow([feature_id, name, rank_names[rank], None, None])
                    print(f"Error for {feature_id} at rank {rank}: {e}")
                    continue
        #linewriter.writerow([feature_id, name, rank_names[rank], None, None])

def main(input_file):
    with open(input_file, 'r') as f:
        reader = csv.reader(f, delimiter='\t')
        header = next(reader)
        for line in reader:
            feature_id, taxon, _ = line
            get_taxid_from_line(feature_id, taxon)

if __name__ == '__main__':
    import sys
    if len(sys.argv) != 2:
        print("Usage: python script.py <input_file>")
        sys.exit(1)
    main(sys.argv[1])
