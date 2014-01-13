#-------------------------------------------------------------------------
# Name - quality_filter_single.sh
# Desc - Quality filter all single end reads in the current folder and produces FASTQ and FASTA files
# Author - Ranjit Kumar (ranjit58@gmail.com)
#-------------------------------------------------------------------------

# Usage : quality_filter_single.sh INPUT_FOLDER TRIM_LENGTH 

# Parameters for QC filtering ###
RAW_DATA=$1
FWD_TRIM=$2
FIL_FASTQ="Filtered_FASTQ"

mkdir $FIL_FASTQ

# Running the QC on fastq files ###
echo -e "\nRunning the QC filtering on all fastq.gz files in the directory"

for file in $( ls ${RAW_DATA}/*.fastq.gz) ; 
do 
  #copying raw data
  cp $file .

done


echo -e ""
# Unzipping all gz files
gunzip -v *.fastq.gz

for file in $( ls *.fastq) ;
do

  # rename the file as temp.fastq
  mv $file temp.fastq

  echo -e "--Working on file $file --"

  # Trimming reads
  echo -e "Trimming till first ${FWD_TRIM} bases"
  fastx_trimmer -l $FWD_TRIM -i temp.fastq -o temp2.fastq -Q 33
  rm -f temp.fastq
  mv temp2.fastq temp.fastq

  # Doing first round quality filtering, removing read if
  echo -e "Running QC-1 (remove any read if more than 2% base having Q<10)"
  fastq_quality_filter -q 10 -p 98 -i temp.fastq -o temp2.fastq -Q 33
  rm -f temp.fastq
  mv temp2.fastq temp.fastq  


  echo -e "Running QC-2 (remove a read if 10% base have Q<30)"
  fastq_quality_filter -q 30 -p 90 -i temp.fastq -o $file -Q 33
  #fastq_quality_filter -q 30 -p 90 -i temp3.fastq -o $file -Q 33
  
  #copying the file into Filtered_FASTQ folder
  cp $file Filtered_FASTQ/$file
  rm -f temp.fastq
  
  echo -e "QC completed for file $file \n"

done


### Converting all the fastq files to the fasta fiels ###done
echo -e "\nRunning the fastq to fasta converison for all fastq files in the directory"
for file in $( ls *.fastq) ;
do
  echo -e "\nConverting fastq to fasta for file $file"
  fastq_to_fasta -r -i $file -o `echo $file|sed -e 's/fastq/fasta/g'` -Q33 ; 
  rm -f $file
done

echo -e "\nQC filtering program completed \n"
