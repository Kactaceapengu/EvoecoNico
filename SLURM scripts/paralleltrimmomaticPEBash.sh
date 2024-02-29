#!/bin/bash
#
#SBATCH --job-name=Trimmomatic$TRIMmode
#SBATCH --ntasks=1
#SBATCH --mem=1G
#SBATCH --partition=basic
#SBATCH --mail-type=BEGIN,END,TIME_LIMIT_50,TIME_LIMIT_80,TIME_LIMIT
#SBATCH --time=00:30:00

input_path="/lisc/scratch/evoeco/trinh/RNAseq/data/"
date=$(date +"%Y-%m-%d_%H-%M-%S")
TRIMmode="PE"  # Set TRIMMOMATIC mode; PE is default; for SE change paths of the TRIMMOMATIC command to single input and output paths!

# Create directories with date in their names
scripts_dir="$input_path/scripts#$date"
output_dir="$input_path/Data_Trimmed_$TRIMmode#$date"
mkdir -p "$scripts_dir"
mkdir -p "$output_dir"

# Change directory to input path
cd "$input_path"

# Loop through the files
for i in $(ls *_R1.fastq.gz | sed -e 's/_R1.fastq.gz//' -e 's/_R2.fastq.gz//' | sort -u); do
    # Create SLURM script for each file
    echo "#!/bin/bash" > "$scripts_dir/Trimmomatic$TRIMmode.$i.sh"
    echo "#" >> "$scripts_dir/Trimmomatic$TRIMmode.$i.sh"
	# Change SLURM parameters HERE:
    echo "#SBATCH --job-name=Trimmomatic$TRIMmode.$i" >> "$scripts_dir/Trimmomatic$TRIMmode.$i.sh"
    echo "#SBATCH --cpus-per-task=6" >> "$scripts_dir/Trimmomatic$TRIMmode.$i.sh"
    echo "#SBATCH --mem=2G" >> "$scripts_dir/Trimmomatic$TRIMmode.$i.sh"
    echo "#SBATCH --mail-type=BEGIN,END,TIME_LIMIT_50,TIME_LIMIT_80,TIME_LIMIT" >> "$scripts_dir/Trimmomatic$TRIMmode.$i.sh"
    echo "#SBATCH --time=02:00:00" >> "$scripts_dir/Trimmomatic$TRIMmode.$i.sh"
    echo "#SBATCH --error=%x-%j.err" >> "$scripts_dir/Trimmomatic$TRIMmode.$i.sh"
    echo "#SBATCH --output=%x-%j.out" >> "$scripts_dir/Trimmomatic$TRIMmode.$i.sh"

    echo "#" >> "$scripts_dir/Trimmomatic$TRIMmode.$i.sh"
    echo "module load trimmomatic/0.39" >> "$scripts_dir/Trimmomatic$TRIMmode.$i.sh"
    echo "cd \"$input_path\"" >> "$scripts_dir/Trimmomatic$TRIMmode.$i.sh"
    # TRIMMOMATIC Command for each SLURM job:
    echo "java -jar /apps/trimmomatic/0.39/trimmomatic-0.39.jar $TRIMmode \
        -phred33 \
        -threads 6 \
        ${i}_R1.fastq.gz ${i}_R2.fastq.gz \
        $output_dir/${i}_TrimP.R1.fastq.gz $output_dir/${i}_TrimU.R1.fastq.gz \
        $output_dir/${i}_TrimP.R2.fastq.gz $output_dir/${i}_TrimU.R2.fastq.gz \
        SLIDINGWINDOW:4:30 MINLEN:36" >> "$scripts_dir/Trimmomatic$TRIMmode.$i.sh" # TRIMMOMATIC PARAMETERS
    # Submit the SLURM script
    cd "$scripts_dir"
    sbatch "Trimmomatic$TRIMmode.$i.sh"
    sleep 1
done
