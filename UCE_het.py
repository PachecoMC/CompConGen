from Bio import AlignIO
import sys, getopt, re
import pandas as pd

def main(argv):
    fastafile = ""
    positionfile = ""
    reference = ""
    outputfile = ""
    
    try:
        opts, args = getopt.getopt(argv, "hi:p:r:o:", ["fasta_file=", "position_file=", "reference_ID=", "outfile="])
    except getopt.GetoptError:
        print ('Error: UCE_het.py -i <fastafile> -p <positionfile> -r <reference> -o <outputfile>')
        print ('   or: UCE_het.py --fasta_file=<fastafile> --position_file=<positionfile> --reference_ID=<reference> --outfile=<outputfile>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == "-h":
            print ('UCE_het.py -i <fastafile> -p <positionfile> -r <reference> -o <outputfile>')
            print ('or: UCE_het.py --fasta_file=<fastafile> --position_file=<positionfile> --reference_ID=<reference> --outfile=<outputfile>')
            sys.exit()
        elif opt in ("-i", "--fasta_file"):
            fastafile = arg
        elif opt in ("-p", "--position_file"):
            positionfile = arg
        elif opt in ("-r", "--reference_ID"):
            reference = arg
        elif opt in ("-o", "--outfile"):
            outputfile = arg
    return fastafile, positionfile, reference, outputfile

def read_fasta_file(file_path):
    alignment = AlignIO.read(file_path, 'fasta')
    return alignment

def read_positions_file(file_path):
    pos_table=pd.read_table(file_path, header=None, names=["UCE", "pos", "ref", "alt", "seq"])
    return pos_table

def extract_bases_and_positions(seq_a, seq_b, positions_a):
    bases_and_positions = []
    pos_b = 0  # position in sequence B without gaps
    pos_a_counter = 0  # position counter in sequence A without gaps

    for i, (base_a, base_b) in enumerate(zip(seq_a, seq_b)):
        if base_b != '-':
            pos_b += 1

        if base_a != '-':
            pos_a_counter += 1

        if base_b != '-' and pos_a_counter in list(positions_a["pos"]):
            pos_het = positions_a.loc[positions_a["pos"] == pos_a_counter]
            bases_and_positions.append([
                pos_b,
                pos_a_counter,
                base_b,
                base_a,
                pos_het["seq"].values[0],
                pos_het["ref"].values[0],
                pos_het["alt"].values[0],
            ])

    return bases_and_positions

def print_bases_and_positions(bases_and_positions):
    for i in range(len(bases_and_positions)):
        bases_and_positions[i] = '\t'.join([str(a) for a in bases_and_positions[i]])
    return bases_and_positions

if __name__ == "__main__":
    fasta_file_path, positions_file_path, reference, outputfile= main(sys.argv[1:])

    alignment = read_fasta_file(fasta_file_path)
    positions_a = read_positions_file(positions_file_path)

    seq_a = None
    seq_b = None
    bases_and_positions = []

    for seq_id_a in positions_a.seq.unique():
        positions_seq = positions_a.loc[positions_a['seq'] == seq_id_a]
        for record in alignment:
            if record.id == seq_id_a:
                seq_a = record.seq
            elif record.id == reference:
                seq_b = record.seq

        if seq_a is None or seq_b is None:
            raise ValueError(f"One or both sequences '{seq_id_a}' or '{reference}' not found in the file.")
        
        bases_seq = extract_bases_and_positions(seq_a, seq_b, positions_seq)
        if bases_seq !=[]:
            for i in bases_seq:
                bases_and_positions.append(i)
    bases_and_positions = print_bases_and_positions(bases_and_positions)
    with open(outputfile, 'a') as f:
        f.write('\n'.join(bases_and_positions))
