#!/usr/bin/bash


### Preparação dos Arquivos

# Descomprimir o arquivo coverage.bed.gz
cp Inputs/coverage.bed.gz Inputs/coverage_copy.bed.gz
bgzip -d Inputs/coverage.bed.gz
mv Inputs/coverage_copy.bed.gz Inputs/coverage.bed.gz

### Bedtools: Determinar variantes com overlap às regiões esperadas:
../../../bedtools intersect -a Inputs/coverage.bed -b temp/variants_filt.vcf > temp/variants_filt_reg.bed


### Bedtools: Determinar coberturas:
# Das regiões que deveriam ter sido cobertas
../../../bedtools coverage -a Inputs/coverage.bed -b temp/alignment.bam > temp/hist_good.bed

# Das regiões que não deveriam ter sido cobertas
../../../bedtools complement -i Inputs/coverage.bed -g Inputs/grch38.chr22.fasta.fai > temp/complement.bed
../../../bedtools coverage -a temp/complement.bed -b temp/alignment.bam > temp/hist_bad.bed


### Obtenção das informações solicitadas sobre o arquivo BAM com samtools
# Total de reads
TOT=$(samtools view -c temp/alignment.bam)
echo "Reads no total "$TOT
# Total de reads usados
NREADS=$(samtools view -F 0x04 -c temp/alignment.bam)
echo "nreads "$NREADS
# Pares mapeados corretamente:
PP=$(samtools view -F 0x04 -f 0x2 -c temp/alignment.bam)
echo "proper_pairs "$PP
# Reads com MapQ = 0
Q0=$(samtools view -h temp/alignment.bam | awk '{if($5<1) {print $0}}' | samtools view -F 0x04 -c)
echo "mapQ_0 "$Q0
# Reads com MapQ < 20
Q20=$(samtools view -h temp/alignment.bam | awk '{if($5<20) {print $0}}' | samtools view -F 0x04 -c)
echo "mapQ_20 "$Q20
# Reads com múltiplos alinhamentos
MALIGN=$(samtools view -F 0x04 -f 0x100 -c temp/alignment.bam)
echo "mult_align "$MALIGN


### Novos ajustes baseados nos resultados observados

# Questão 1: com bcftools, filtrar VCF para as regiões presentes no BED
echo "Filtrando as variantes"
bcftools index temp/variants_filt.vcf.gz
bcftools filter -R temp/variants_filt_reg.bed -Ov -o temp/variants_filt_reg.vcf temp/variants_filt.vcf.gz
bcftools filter -i 'QUAL>215' -Ov -o temp/variants_filt_reg_filt.vcf temp/variants_filt_reg.vcf
cp temp/variants_filt_reg_filt.vcf Outputs\ Exigidos/Dia_2.vcf

# Questão 2: Com bedtools, gerar arquivo BED com regiões não cobertas (threshold determinado no QC)
awk -v OFS='\t' '{ if ($8 < 0.95 ) print $1, $2, $3, $4 }' temp/hist_good.bed > Outputs\ Exigidos/Dia_2.bed

# Questão 3:
# Escrever arquivo tsv contendo as informações extraídas
awk -v OFS="\t" -v nreads="$NREADS" -v pp="$PP" -v q0="$Q0" 'BEGIN {print "nreads", "proper_pairs", "mapQ_0\n" nreads, pp, q0}' > Outputs\ Exigidos/Dia_2.tsv


