#!/usr/bin/bash

printf "\n\n### DIA 3 ###\n\n"

# Anotar arquivo VCF com formato HGVS
bcftools annotate --set-id '22:g.%POS%REF>%FIRST_ALT' -Ov temp/variants_filt_reg_filt.vcf > temp/variants_anno.vcf

# Copiar o VCF obtido para a pasta de outputs
cp temp/variants_anno.vcf Outputs\ Exigidos/Dia_3.vcf

### Cálculo transversões e transições (parte 1) e
### Variantes na região de 16000000 a 20000000 (parte 2)
python Scripts/Dia_3_p1.py


### Informações sobre variantes (partes 3 e 4)
python Scripts/Dia_3_p2.py
