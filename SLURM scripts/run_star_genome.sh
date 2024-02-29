#!/bin/bash
#
#SBATCH --job-name=star_genomeindexing     
#SBATCH --mail-type=BEGIN,END,TIME_LIMIT_50,TIME_LIMIT_80,TIME_LIMIT
#SBATCH --cpus-per-task=4
#SBATCH --mem=35GB
#SBATCH --time=2:00:00
#SBATCH --error=%x-%j.err
#SBATCH --output=%x-%j.out

# Exit the slurm script if a command fails
set -e


# Load necessary modules
module load star

# STAR command with your specific parameters
STAR --runMode genomeGenerate \
     --genomeDir /lisc/user/trinh/Nicotiana/starindex/NbLab360starindex \
     --genomeFastaFiles /lisc/project/evoeco/trinh/reference/NbLab360.genome.fasta
	--runThreadN 4 \
     --sjdbGTFfile /lisc/project/evoeco/trinh/reference/NbLab360.v103.gff3 \
     --sjdbGTFtagExonParentTranscript Parent \
     --sjdbOverhang 149 \

# If we reached this point, the assembly succeeded. We clean up resources.
rm -rf $TMPDIR

