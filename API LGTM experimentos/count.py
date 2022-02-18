import sys
import json

from numpy import PINF


with open(sys.argv[1]) as fileList:
    for name in fileList:
        
        files = [f'{name}Original_Filtrado.json',f'{name}Generico_Filtrado.json']

        
        for file in files:
            f = open(file)
            data = json.load(f)
            print(name.upper())
            cant = len(data)
            print(f'#PROY > 0 : {cant}')
            total = sum(map(lambda x: int(x['total']), data))
            print(f'TOTAL: {total}')
            
            print(f'PROMEDIO: {total/cant}')
            # Calculamos total
            for i in data['emp_details']:
                print(i)
            
        # Closing file
        f.close()