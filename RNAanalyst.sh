#!/bin/sh
for sample in A10-4 A12-5 A13 A14-8 A16 A17 A18 A19 A1 A20 A2 A4-1 A5 A6-2 A8-3 B11-6 B11 B12 B13-7 B14 B15 B16 B17 B20-11 B3-3 B6 B7 B8-4 B9 B1-1 C10 C11 C12-4 C13 C14 C16-5 C17 C18 C19 C20 C3 C4 C5 C6 C9-3 D10-3 D12 D14 D15 D16 D17-5 D20 D2 D3-1 D4 D5-2 D6 D7 D8 D175 
do
	echo "#####---Quality control analysis---#####"
	fastqc -t 15 -o /media/yyzhang/data/data/shiqiang/RNAcount/qc/ -f fastq /media/yyzhang/data/data/shiqiang/2/zjk/00.CleanData/${sample}/${sample}_1.clean.fq /media/yyzhang/data/data/shiqiang/2/zjk/00.CleanData/${sample}/${sample}_2.clean.fq
	echo "#####---Remove adapter and low quality reads---#####"
	trimmomatic PE -threads 15 /media/yyzhang/data/data/shiqiang/2/zjk/00.CleanData/${sample}/${sample}_1.clean.fq /media/yyzhang/data/data/shiqiang/2/zjk/00.CleanData/${sample}/${sample}_1.clean.fq /media/yyzhang/data/data/shiqiang/RNAcount/${sample}_1.paired.fq.gz /media/yyzhang/data/data/shiqiang/RNAcount/${sample}_1.unpaired.fq.gz /media/yyzhang/data/data/shiqiang/RNAcount/${sample}_2.paired.fq.gz /media/yyzhang/data/data/shiqiang/RNAcount/${sample}_2.unpaired.fq.gz ILLUMINACLIP:/media/yyzhang/data/data/shiqiang/miniconda3/share/trimmomatic-0.39-2/adapters/TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
	echo "#####---Mapping to genome---#####"
	STAR --runThreadN 15 --genomeSAindexNbases 12 --genomeDir /media/yyzhang/data/data/shiqiang/RNAcount/index --readFilesCommand zcat --readFilesIn media/yyzhang/data/data/shiqiang/RNAcount/${sample}_1.paired.fq media/yyzhang/data/data/shiqiang/RNAcount/${sample}_2.paired.fq  --outFileNamePrefix media/yyzhang/data/data/shiqiang/RNAcount/${sample} --outSAMtype BAM SortedByCoordinate
	#featureCounts -T 15 -p -t mRNA -g mRNA -a /media/yyzhang/data/data/shiqiang/RNAcount/IRGSP-1.0_representative_transcript_exon_2024-07-12.gtf -o /media/yyzhang/data/data/shiqiang/RNAcount *Aligned.sortedByCoord.out.bam
done
