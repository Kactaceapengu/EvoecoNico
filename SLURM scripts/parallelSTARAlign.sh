#!/bin/bash
#
#SBATCH --job-name=STARparallelALIGN
#SBATCH --ntasks=1
#SBATCH --mem=1G
#SBATCH --partition=basic
#SBATCH --mail-type=BEGIN,END,TIME_LIMIT_50,TIME_LIMIT_80,TIME_LIMIT
#SBATCH --time=00:30:00

# SET input path to where the TRIMMOMATIC output files "_TrimP.R1.fastq.gz" are located:
input_path="/lisc/scratch/evoeco/trinh/RNAseq/data/Data_Trimmed_PE/"


date=$(date +"%Y-%m-%d_%H-%M-%S")
# Create directories with date in their names
scripts_dir="$input_path/scripts#$date"
output_dir="$input_path/Mapped#$date"
mkdir -p "$scripts_dir"
mkdir -p "$output_dir"

# Change directory to input path
cd "$input_path"

# Loop through the files
for i in $(ls *_TrimP.R1.fastq.gz | sed -e 's/_TrimP.R1.fastq.gz//' -e 's/_TrimP.R2.fastq.gz//' | sort -u); do
    # Create SLURM script for each file
    echo "#!/bin/bash" > "$scripts_dir/StarAlign.$i.sh"
    echo "#" >> "$scripts_dir/StarAlign.$i.sh"

	# CHANGE job parameters HERE:
    echo "#SBATCH --job-name=StarAlign.$i" >> "$scripts_dir/StarAlign.$i.sh"
    echo "#SBATCH --cpus-per-task=4" >> "$scripts_dir/StarAlign.$i.sh"
    echo "#SBATCH --mem=42G" >> "$scripts_dir/StarAlign.$i.sh"
    echo "#SBATCH --mail-type=BEGIN,END,TIME_LIMIT_50,TIME_LIMIT_80,TIME_LIMIT" >> "$scripts_dir/StarAlign.$i.sh"
    echo "#SBATCH --time=02:00:00" >> "$scripts_dir/StarAlign.$i.sh"
    echo "#SBATCH --error=%x-%j.err" >> "$scripts_dir/StarAlign.$i.sh"
    echo "#SBATCH --output=%x-%j.out" >> "$scripts_dir/StarAlign.$i.sh"

    echo "#" >> "$scripts_dir/StarAlign.$i.sh"
    echo "module load star" >> "$scripts_dir/StarAlign.$i.sh"
    echo "cd \"$input_path\"" >> "$scripts_dir/StarAlign.$i.sh"
    # STAR Command for each SLURM job: runThreadN should equal cpus-per-task number
    echo "STAR  --runThreadN 4 \
        --genomeDir /lisc/user/trinh/Nicotiana/starindex/NbLab360starindex \
        --readFilesCommand zcat \
        --readFilesIn ./${i}_TrimP.R1.fastq.gz ./${i}_TrimP.R2.fastq.gz \
        --outFileNamePrefix \"$output_dir/${i}_\" \
        --outSAMtype BAM SortedByCoordinate \
        --outFilterMismatchNoverLmax 0.1 \
        --outFilterScoreMinOverLread 0.3" >> "$scripts_dir/StarAlign.$i.sh"
    
    # Submit the SLURM script
    cd "$scripts_dir"
    sbatch "StarAlign.$i.sh"
    sleep 1
done

