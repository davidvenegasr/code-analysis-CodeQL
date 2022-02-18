import sys
import json

from numpy import PINF


with open(sys.argv[1]) as fileList:
    for name in fileList:
        name = name.replace("\n", "")
        files = [f'{name}Original_Filtrado.json',f'{name}Generico_Filtrado.json']

        
        for file in files:
            f = open(file)
            data = json.load(f)
            print(file.upper())
            cant = len(data)
            print(f'#PROY > 0 : {cant}')
            total = sum(map(lambda x: int(x['total']), data))
            print(f'TOTAL: {total}')
            
            print(f'PROMEDIO: {total/cant}')

            
        # Closing file
        f.close()