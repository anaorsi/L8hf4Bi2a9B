#!/usr/bin/bash

# Criação de pastas para arquivos temporários e outputs desejados
mkdir temp
mkdir Outputs

# Indexação da referência utilizando BWA
echo "Indexação da referência com BWA"
../../../bwa/bwa index Inputs/grch38.chr22.fasta.gz

# Remoção de adaptadores
../../../fastp -i Inputs/amostra-lbb_R1.fq.gz -I Inputs/amostra-lbb_R2.fq.gz -o temp/limpo_R1.fq.gz -O temp/limpo_R2.fq.gz
mv fastp.html temp/
mv fastp.json temp/

# Alinhamento utilizando BWA
echo "Alinhamento com BWA"
../../../bwa/bwa mem Inputs/grch38.chr22.fasta.gz temp/limpo_R1.fq.gz temp/limpo_R2.fq.gz | samtools sort -o temp/alignment.bam -

# Indexação com Samtools
echo "Indexação com Samtools"
samtools index temp/alignment.bam temp/alignment.bam.bai

# Extração do arquivo fasta de referência
gzip -dk Inputs/grch38.chr22.fasta.gz

# Chamada de variantes
echo "Bcftools mpileup e call"
bcftools mpileup --max-depth 1000000 --ff UNMAP,SECONDARY -f Inputs/grch38.chr22.fasta temp/alignment.bam | bcftools call -mv -Ov -m --ploidy 2 -o temp/variants.vcf

# Filtragem das variantes
echo "Filtrando as variantes"
bcftools filter -g3 -i 'QUAL>20 & DP>10' -Ov -o Outputs/variants_filt.vcf temp/variants.vcf

# Estatísticas e plots (opcional)
#bcftools stats Outputs/variants_filt.vcf > temp/to_plot.vchk
#plot-vcfstats -p Outputs/outplot temp/to_plot.vchk

# Script em Python para checar se todas as variantes do "pequeno-gabarito.vcf" estão presentes no vcf final
echo "Conferindo resultados com o arquivo pequeno-gabarito"
python3 Scripts/checar_gabarito.py

# Compactar arquivo VCF
echo "Compactando o arquivo VCF utilizando bgzip"
bgzip Outputs/variants_filt.vcf
