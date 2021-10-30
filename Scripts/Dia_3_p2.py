## Adaptado de https://rest.ensembl.org/documentation/info/vep_hgvs_get

## Importar pacotes
import requests, sys

## Definição de variáveis para a API REST
server = "https://rest.ensembl.org"
ext = "/vep/human/hgvs"
headers={ "Content-Type" : "application/json", "Accept" : "application/json"}

## Ler o arquivo VCF
with open('temp/variants_anno.vcf', 'r') as reader:
	mine = reader.readlines()
reader.close()

## Parsear as informações necessárias
variantes = [i.split("\t")[2] for i in mine[37:] if i.split("\t")[7][:5] != "INDEL"]


## Variáveis que armazenarão os resultados desejados
ms = []
gnomad = []

## Uma vez que o tamanho máximo do POST é 200, é necessário realizar vários requests
for j in [(0, 200), (200, 400), (400, 600), (600, len(variantes))]:
	## Selecionar slice do request atual
	varia = variantes[j[0]:j[1]]	

	## Formatar dados a serem enviados
	data = '{ "hgvs_notations" : ['
	for i in varia: data = data + '"' + i + '", '
	data = data[:-2] + ' ] }'

	## Request
	r = requests.post(server+ext, headers=headers, data=data)
	if not r.ok:
		r.raise_for_status()
		sys.exit()
	decoded = r.json()

	## Iterar pelos resultados
	for i in range(len(decoded)):

		cons = decoded[i]["transcript_consequences"][0]["consequence_terms"]
		if "missense_variant" in cons: ms.append(varia[i])
		
		if "frequencies" in decoded[i]["colocated_variants"][0].keys():
			my_key = decoded[i]["colocated_variants"][0]["frequencies"].keys()
			if len(my_key)>1: print("Ops")
			if "gnomad" in decoded[i]["colocated_variants"][0]["frequencies"][list(my_key)[0]].keys():
				gno = decoded[i]["colocated_variants"][0]["frequencies"][list(my_key)[0]]["gnomad"]
				if gno < 0.01: gnomad.append(varia[i] + ": " + str(gno))

print("Parte 3: Variantes missense")
print("\n".join(ms))
print("\nLinha do arquivo VCF:")
print([i for i in mine[37:] if i.split("\t")[2] in ms][0])

print("\n\nParte 4: Variantes com MAF<0.01 no gnomaAD v3.1.1")
print("\n".join(gnomad))
print("\nLinha do arquivo VCF:")
print([i for i in mine[37:] if i.split("\t")[2] in [j.split(" ")[0][:-1] for j in gnomad]][0])
