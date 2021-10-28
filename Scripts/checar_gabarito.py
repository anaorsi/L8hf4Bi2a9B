
# Leitura do pequeno-gabarito
with open('Inputs/pequeno-gabarito.vcf', 'r') as reader:
	gaba = reader.readlines()
reader.close()

# Leitura do pequeno-gabarito
with open('Outputs/variants_filt2.vcf', 'r') as reader:
	mine = reader.readlines()
reader.close()

# Definição da flag que vai indicar se foi encontrado algum problema
flag = 0

# Para cada linha no arquivo pequeno-gabarito, será feita a conferência
for i in gaba[5:]:

	# Separação das colunas do arquivo vcf
	k = i.split("\t")
	
	# Seleção dos atributos importantes para conferência
	pos = k[1] # posição
	ref = k[3] # alelo referência
	alt = k[4] # alelo alternativo
	pl = k[9][:3] # ploidia

	# Busca no vcf obtido por mim
	mini_flag = 0
	for j in mine:
		if pos in j:
			# Separação das colunas do arquivo vcf
			k_meu = j.split("\t")
			
			# Seleção dos atributos importantes para conferência
			ref2 = k_meu[3] # alelo referência
			alt2 = k_meu[4] # alelo alternativo
			pl2 = k_meu[9][:3] # ploidia			
			
			# Checagem dos valores esperados
			if (ref==ref2) & (alt==alt2) & (pl==pl2):
				miniflag = 1
			else:
				flag = 1
				miniflag = 1
				print("Problema na posição " + pos)
				print("Ref: " + ref + " " + ref2)
				print("Alt: " + alt + " " + alt2)
				print("Pl: " + pl + " " + pl2)

			break
	if mini_flag == 0:
		flag = 1
		print("Variante não encontrada na posição " + pos)

if flag==0:
	print("O vcf obtido está condizente com o pequeno-gabarito")
