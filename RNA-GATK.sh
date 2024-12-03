#!/bin/sh
#��Ŀ��spartina_microbabitat
#����ִ�й��ܣ�ʹ��GATK��ת¼������call SNP
#ʹ�����ݣ���1��60�������Ķ���ת¼�飨2�������ײݻ����飨������ѧ�ͷţ�
#ʹ����������ã�ѡ���GATK4.4,java17
for sample in A10-4 A12-5 A13 A14-8 A16 A17 A18 A19 A1 A20 A2 A4-1 A5 A6-2 A8-3 B11-6 B11 B12 B13-7 B14 B15 B16 B17 B20-11 B3-3 B6 B7 B8-4 B9 B1-1 C10 C11 C12-4 C13 C14 C16-5 C17 C18 C19 C20 C3 C4 C5 C6 C9-3 D10-3 D12 D14 D15 D16 D17-5 D20 D2 D3-1 D4 D5-2 D6 D7 D8 D175 
do
	
	#ʹ��STAR���ж��ζԱ�
	mkdir ./${sample}
	#STAR-2-mapping
	STAR --runThreadN 30 --outFileNamePrefix ./${sample}/${sample} --outSAMtype BAM SortedByCoordinate --outFilterMultimapNmax 1 --genomeDir /media/yyzhang/data/data/shiqiang/RNAcount/index/ --readFilesIn /media/yyzhang/data/data/shiqiang/2/zjk/00.CleanData/${sample}/${sample}_1.clean.fq /media/yyzhang/data/data/shiqiang/2/zjk/00.CleanData/${sample}/${sample}_2.clean.fq --twopassMode Basic --outSAMstrandField intronMotif
	
	#AddOrReplaceReadGroupsΪÿ���������ͷ�ļ�
	java -Xmx64g -jar /media/yyzhang/data/data/shiqiang/miniconda3/envs/gatk/picard.jar AddOrReplaceReadGroups \
        	I=/media/yyzhang/data/data/shiqiang/RNAcount/${sample}/${sample}Aligned.sortedByCoord.out.bam \
        	O=/media/yyzhang/data/data/shiqiang/RNAcount/${sample}/${sample}added_sorted.bam \
        	SO=coordinate \
        	RGID=${sample} \
        	RGLB=rna \
        	RGPL=illumina \
        	RGPU=hiseq \
        	RGSM=${sample}
	
	#MarkDuplicatesȥ��mark duplicate
  	java -Xmx64g -jar /media/yyzhang/data/data/shiqiang/miniconda3/envs/gatk/picard.jar MarkDuplicates \
       	 -I /media/yyzhang/data/data/shiqiang/RNAcount/${sample}/${sample}added_sorted.bam \
        	-O /media/yyzhang/data/data/shiqiang/RNAcount/${sample}/${sample}.sorted.markdup.bam \
        	-M /media/yyzhang/data/data/shiqiang/RNAcount/${sample}/${sample}.sorted.markdup.txt \
        	--REMOVE_DUPLICATES true \
        	--ASSUME_SORT_ORDER coordinate 
	#SplitNCigarReads��������cigar�ﺬ��n��reads,��ΪRNA��DNA�ȶ�����Ĳ�ͬ��������һ��HaplotypeCaller��ʱ����Ҫ���ں���ȥ������һ����cigar�к���N��reads���˼���
  	gatk --java-options "-Xmx40G -Djava.io.tmpdir=/media/yyzhang/data/data/shiqiang/GATKRNA/tmp/" SplitNCigarReads \
       	-R /media/yyzhang/data/data/shiqiang/RNAcount/ref/GWHCBIM00000000.genome.fasta \
       	-I /media/yyzhang/data/data/shiqiang/RNAcount/${sample}/${sample}.sorted.markdup.bam \
      	 -O /media/yyzhang/data/data/shiqiang/RNAcount/${sample}/${sample}split.bam
	
	#Variant Calling
	gatk --java-options "-Xmx80G -Djava.io.tmpdir=/media/yyzhang/data/data/shiqiang/GATKRNA/tmp/" HaplotypeCaller \
        	-R /media/yyzhang/data/data/shiqiang/RNAcount/ref/GWHCBIM00000000.genome.fasta \
        	-I /media/yyzhang/data/data/shiqiang/RNAcount/${sample}/${sample}split.bam \
        	-O /media/yyzhang/data/data/shiqiang/RNAcount/${sample}/${sample}.g.vcf.gz -ERC GVCF \
        	-RF OverclippedReadFilter \
        	-RF ProperlyPairedReadFilter \
       	 -RF FragmentLengthReadFilter \
        	-dont-use-soft-clipped-bases \
        	-stand-call-conf 30 \
        	-RF GoodCigarReadFilter \
        	-RF MappedReadFilter \
        	-RF MappingQualityAvailableReadFilter \
       	 -RF NotSecondaryAlignmentReadFilter \
        	-RF NotDuplicateReadFilter \
                       --ploidy 2
done


 