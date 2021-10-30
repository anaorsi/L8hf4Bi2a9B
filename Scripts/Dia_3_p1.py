
print("Parte 1: Transições e Transversões")

### Definir os tipos de mutação
ti = {("A", "G"), ("G", "A"), ("C", "T"), ("T", "C")}
tv = {("A", "C"), ("A", "T"), ("C", "A"), ("C", "G"), ("G", "C"), ("G", "T"), ("T", "A"), ("T", "G")}

### Ler VCF
with open('temp/variants_anno.vcf', 'r') as reader:
	mine = reader.readlines()
reader.close()

### Parsear o arquivo
variantes = [(i.split("\t")[3], i.split("\t")[4]) for i in mine[37:] if i.split("\t")[7][:5] != "INDEL"]

### Contadores para os tipos de mutações
cti = 0
ctv = 0

### Iterar pelas variantes, contabilizando os tipos de mutações
for i in variantes:
	if i in ti: cti = cti + 1
	elif i in tv: ctv = ctv + 1
	else: print("Erro")

print("Ti total: " + str(cti))
print("Tv total: " + str(ctv))

print("Ti/Tv = " + str(float(cti)/float(ctv)))

##############
print("\n\nParte 2: Variantes na região de 16000000 a 20000000")

### Selecionar linhas do arquivo VCF de acordo com a posição determinada
regiao = [i for i in mine[37:] if (int(i.split("\t")[1])>=16000000) & (int(i.split("\t")[1])<=20000000)]

print("Foram encontradas " + str(len(regiao)) + " variantes na região determinada\n\n")

