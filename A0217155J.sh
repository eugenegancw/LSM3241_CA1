#create the fasta files for the reverse, complement & reverse-complement orientation
### Alignment of the trimmed reads to ty5_6p

mkdir -p data/genome
mkdir -p results/sam


### Search for read present in both alignment
## Index reads with ty5-6p and with sacCer3 respectively 

echo "Step 1: index the reference genomes"
mkdir align-results


bowtie2-build data/genome/ty5_6p.fa data/genome/ty5_6p
export BOWTIE2_INDEXES=$(pwd)/data/genome
mkdir -p results/sam/transposonONLY results/bam/transposonONLY


echo "Step 2 part 1: align sequenced data with transposon reference sequence"
bowtie2 -x ty5_6p --very-fast -p 4 -1 results/trimmed/A0217155J_1.trim.fastq -2 results/trimmed/A0217155J_2.trim.fastq -S align-results/transposon-align.sam #Align sequenced data with reference transposon sequence
#transposon-align does not have quality control
samtools view -F 4 -f 9 -b align-results/transposon-align.sam >align-results/transposon-align.bam #extract reads mapped to ty5_6p sequence but have unmapped mates within the ty5_6p sequence
samtools sort -n align-results/transposon-align.bam -o align-results/transposon-align-sorted.bam 
samtools sort align-results/transposon-align.bam -o align-results/transposon-align-sorted_def.bam 
samtools index align-results/transposon-align-sorted_def.bam #index the bam file



#part 2 analysis for yeast genomoe might not be needed
echo "Step 2 part 2: align sequenced data with yeast reference sequence"
bowtie2-build data/genome/sacCer3.fa data/genome/sacCer3
export BOWTIE2_INDEXES=$(pwd)/data/genome
bowtie2 --fr -x sacCer3 \
--very-fast -p 4 \
-1 results/trimmed/A0217155J_1.trim.fastq \
-2 results/trimmed/A0217155J_2.trim.fastq \
-S align-results/yeast-align.sam #Align sequenced data with yeast genome sequence


samtools view -f 1 -b align-results/yeast-align.sam >align-results/yeast-align_1.bam #extract reads used for reference for IGV viewing

samtools view -F 4 -f 9 -b align-results/yeast-align.sam >align-results/yeast-align.bam #extract reads mapped to sacCer3 sequence but have unmapped mates within the sacCer3 sequence, while excluding unmapped reads

samtools sort -n align-results/yeast-align.bam -o align-results/yeast-align-sorted.bam 
samtools sort align-results/yeast-align.bam -o align-results/yeast-align-sorted_def.bam #sort by coordinates

##convert to both sam and text file
samtools view -h transposon-align-sorted_def.bam > transposon-align-sorted_def.sam 
samtools view -h yeast-align-sorted_def.bam > yeast-align-sorted_def.sam 

samtools view -h transposon-align-sorted.bam | cut -f1 | sort -u > yeast-align-sorted.txt 
samtools view -h yeast-align-sorted.bam | cut -f1 | sort -u > yeast-align-sorted.txt 


samtools flagstat align-results/yeast-align-sorted.bam #view information about sorted BAM file

samtools index align-results/yeast-align-sorted_def.bam #index the sorted BAM file

echo "view under IGV, load both yeast-align and yeast-align_1 in it"
#coverage seen should be flanking a region with no coverage, where on the left it is an unpaired reads with forwards primer while on the right it is unpaired reads with reverse primer
#ensure that the region is filled with majority of them being high quality as indicated by the darker grey shade

echo "found potential transposon region at - in IGV"

# Verify the transposon insertion site using BLASTn
cat data/[A0217155J_1.fq/A0217155J_2.fq] | grep -n [readname] 
cat data/[A0217155J_1.fq/A0217155J_2.fq]| head -n [line number +4] | tail -5 

#Find where the bases are truncated at and see if it matches with both the yeast and transposon
#Find the gene name and whether it is in the exon
#Find the function of the gene
