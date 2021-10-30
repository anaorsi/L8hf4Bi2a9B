#!/usr/bin/bash

printf "### DIA 1 ###\n\n"

# Criação de pastas para arquivos temporários e outputs desejados
mkdir temp

# Indexação da referência utilizando BWA
printf "Indexação da referência com BWA\n"
bwa index Inputs/grch38.chr22.fasta.gz

# Remoção de adaptadores
printf "\n\nRemoção de adaptadores\n"
fastp -i Inputs/amostra-lbb_R1.fq.gz -I Inputs/amostra-lbb_R2.fq.gz -o temp/limpo_R1.fq.gz -O temp/limpo_R2.fq.gz
mv fastp.html temp/
mv fastp.json temp/

# Alinhamento utilizando BWA
printf "\n\nAlinhamento com BWA\n"
bwa mem -M Inputs/grch38.chr22.fasta.gz temp/limpo_R1.fq.gz temp/limpo_R2.fq.gz | samtools sort -o temp/alignment.bam -

# Indexação com Samtools
printf "\n\nIndexação com Samtools\n"
samtools index temp/alignment.bam temp/alignment.bam.bai

# Extração do arquivo fasta de referência
gzip -dk Inputs/grch38.chr22.fasta.gz

# Chamada de variantes
printf "\n\nBcftools mpileup e call\n"
bcftools mpileup --max-depth 1000000 --ff UNMAP,SECONDARY -f Inputs/grch38.chr22.fasta temp/alignment.bam | bcftools call -mv -Ov -m --ploidy 2 -o temp/variants.vcf

# Filtragem das variantes
printf "\n\nFiltrando as variantes\n"
bcftools filter -g3 -i 'QUAL>20 & DP>10' -Ov -o temp/variants_filt.vcf temp/variants.vcf

# Estatísticas e plots (opcional)
#bcftools stats temp/variants_filt.vcf > temp/to_plot.vchk
#plot-vcfstats -p temp/outplot temp/to_plot.vchk

# Script em Python para checar se todas as variantes do "pequeno-gabarito.vcf" estão presentes no vcf final
printf "\n\nConferindo resultados com o arquivo pequeno-gabarito\n"
python Scripts/checar_gabarito.py

# Compactar arquivo VCF e copiar para pasta Outputs Exigidos
printf "\n\nCompactando o arquivo VCF utilizando bgzip\n"
cp temp/variants_filt.vcf temp/variants_filt_copy.vcf
bgzip temp/variants_filt.vcf
cp temp/variants_filt.vcf.gz Outputs\ Exigidos/Dia_1.vcf.gz
mv temp/variants_filt_copy.vcf temp/variants_filt.vcf
