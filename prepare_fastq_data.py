import sys
import os
import shutil
import gzip

# Assuming the first argument is the parent directory path
parent_directory = sys.argv[1] + "/fastq_pass/"
output_directory = sys.argv[1] + "/fastq_merged/"

def unzip_fastq_gz(directory):
    """Unzip all .fastq.gz files in the given directory."""
    print(f"Starting to unzip files in {directory}")
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.fastq.gz'):
                gz_file_path = os.path.join(root, file)
                fastq_file_path = gz_file_path.rsplit('.', 1)[0]  # Remove .gz extension
                print(f"Unzipping {gz_file_path}")
                with gzip.open(gz_file_path, 'rb') as f_in:
                    with open(fastq_file_path, 'wb') as f_out:
                        shutil.copyfileobj(f_in, f_out)
                print(f"Finished unzipping {gz_file_path}")

def concatenate_fastq(directory):
    """Concatenate all .fastq files in each subdirectory."""
    print(f"Starting to concatenate .fastq files in {directory}")
    for root, dirs, files in os.walk(directory):
        fastq_files = [f for f in files if f.endswith('.fastq')]
        if fastq_files:  # Only proceed if there are .fastq files in the directory
            concatenated_file_path = os.path.join(output_directory, os.path.basename(root) + '.fastq')
            print(f"Concatenating files into {concatenated_file_path}")
            with open(concatenated_file_path, 'wb') as f_out:
                for f in fastq_files:
                    file_path = os.path.join(root, f)
                    print(f"Adding {file_path} to {concatenated_file_path}")
                    with open(file_path, 'rb') as f_in:
                        shutil.copyfileobj(f_in, f_out)
            print(f"Finished concatenating files into {concatenated_file_path}")

if __name__ == "__main__":
    # Create output directory if it doesn't exist
    os.makedirs(output_directory, exist_ok=True)
    
    unzip_fastq_gz(parent_directory)
    concatenate_fastq(parent_directory)
    print(f"Processing complete. The merged files have been created in {output_directory}.")
