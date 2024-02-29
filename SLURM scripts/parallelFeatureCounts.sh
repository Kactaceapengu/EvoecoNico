#!/bin/bash
#
#SBATCH --job-name=parallelFeatureCounts
#SBATCH --ntasks=1
#SBATCH --mem=1G
#SBATCH --partition=basic
#SBATCH --mail-type=BEGIN,END,TIME_LIMIT_50,TIME_LIMIT_80,TIME_LIMIT
#SBATCH --time=00:30:00

Cmdname="FeatureCounts"

# Change paths to get STAR aligned .BAM data sorted in sample folders! (f.ex. GOS_VEL_Leaf):
input_path="/lisc/scratch/evoeco/trinh/RNAseq/data/Data_Trimmed_PE/Mapped/"

# Change paths to get genome reference .fasta and annotation .gff3 data:
genome_ref_filepath="/lisc/scratch/evoeco/trinh/RNAseq/reference/NbLab360.genome.fasta"
annotation_filepath="/lisc/scratch/evoeco/trinh/RNAseq/reference/NbLab360.v103.gff3"

date=$(date +"%Y-%m-%d_%H-%M-%S")

# Create directories with date in their names
scripts_dir="$input_path/$Cmdname-scripts#$date"
mkdir -p "$scripts_dir"

# Loop through folders in the Mapped directory
for folder in "$input_path"*/; do
	folder_name=$(basename "$folder")
    if [[ "$folder_name" != *"$Cmdname-scripts"* ]]; then
        folder_name=$(basename "$folder")
        # Change directory to the current folder
        cd "$input_path/$folder"
        
        # Create SLURM script for each folder
        echo "#!/bin/bash" > "$scripts_dir/$Cmdname.$folder_name.sh"
        echo "#" >> "$scripts_dir/$Cmdname.$folder_name.sh"

        # Change job parameters
        echo "#SBATCH --job-name=$Cmdname.$folder_name" >> "$scripts_dir/$Cmdname.$folder_name.sh"
        echo "#SBATCH --cpus-per-task=6" >> "$scripts_dir/$Cmdname.$folder_name.sh"
        echo "#SBATCH --mem=16G" >> "$scripts_dir/$Cmdname.$folder_name.sh"
        echo "#SBATCH --mail-type=BEGIN,END,TIME_LIMIT_50,TIME_LIMIT_80,TIME_LIMIT" >> "$scripts_dir/$Cmdname.$folder_name.sh"
        echo "#SBATCH --time=03:00:00" >> "$scripts_dir/$Cmdname.$folder_name.sh"
        echo "#SBATCH --error=%x-%j.err" >> "$scripts_dir/$Cmdname.$folder_name.sh"
        echo "#SBATCH --output=%x-%j.out" >> "$scripts_dir/$Cmdname.$folder_name.sh"

        echo "#" >> "$scripts_dir/$Cmdname.$folder_name.sh"
        echo "module load subread/2.0.6" >> "$scripts_dir/$Cmdname.$folder_name.sh"
        echo "cd \"$input_path$folder_name\"" >> "$scripts_dir/$Cmdname.$folder_name.sh"
        
        # featureCounts command for each SLURM job
        echo "/apps/subread/2.0.6/bin/featureCounts \
            -T 6 \
            -a $annotation_filepath \
            -o ./$folder_name.txt \
            -g ID \
            -t gene \
            -G $genome_ref_filepath \
            -p \
            --countReadPairs \
			*.bam" >> "$scripts_dir/$Cmdname.$folder_name.sh"

        # Submit the SLURM script
        cd "$scripts_dir"
        sbatch "$Cmdname.$folder_name.sh"
        sleep 1
    fi
done

