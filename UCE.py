from Bio import AlignIO
import sys, getopt, re

def main(argv):

    fastafile = ""
    reference = ""
    outputfile = ""
    
    try:
        opts, args = getopt.getopt(argv, "hi:r:o:", ["fasta_file=", "reference_ID=", "outfile="])
    except getopt.GetoptError:
        print ('Error: UCE.py -i <fastafile> -r <reference> -o <outputfile>')
        print ('   or: UCE.py --fasta_file=<fastafile> --reference_ID=<reference> --outfile=<outputfile>')
        sys.exit(2)
    for opt, arg in opts:
        if opt == "-h":
            print ('UCE.py -i <fastafile> -r <reference> -o <outputfile>')
            print ('or: UCE.py --fasta_file=<fastafile> --reference_ID=<reference> --outfile=<outputfile>')
            sys.exit()
        elif opt in ("-i", "--fasta_file"):
            fastafile = arg
        elif opt in ("-r", "--reference_ID"):
            reference = arg
        elif opt in ("-o", "--outfile"):
            outputfile = arg
    return fastafile, reference, outputfile

def read_fasta_file(file_path):
    alignment = AlignIO.read(file_path, 'fasta')
    return alignment
    

def find_substitutions(alignment, reference_seq_id):
    reference_seq = None
    for record in alignment:
        if record.id == reference_seq_id:
            reference_seq = record.seq
            break

    if reference_seq is None:
        raise ValueError(f"Reference sequence name '{reference_seq_id}' not found in the alignment.")

    substitutions = []

    for record in alignment:
        if record.id != reference_seq_id:
            current_seq = record.seq
            ref_pos = 0
            curr_pos = 0
            for i, (ref_base, current_base) in enumerate(zip(reference_seq, current_seq)):
                if ref_base != '-':
                    ref_pos += 1
                if current_base != '-':
                    curr_pos += 1

                if ref_base != '-' and current_base != '-' and ref_base != current_base:
                    substitutions.append([
                        ref_pos,
                        curr_pos,
                        ref_base,
                        current_base,
                        record.id
                    ])

    return substitutions

def print_substitutions(substitutions):
    for i in range(len(substitutions)):
        substitutions[i] = '\t'.join([str(a) for a in substitutions[i]])
    return substitutions

if __name__ == "__main__":
    fastafile, reference, outputfile= main(sys.argv[1:])

    alignment = read_fasta_file(fastafile)
    substitutions = find_substitutions(alignment, reference)
    substitutions = print_substitutions(substitutions)
    with open(outputfile, 'a') as f:
        f.write('\n'.join(substitutions))
