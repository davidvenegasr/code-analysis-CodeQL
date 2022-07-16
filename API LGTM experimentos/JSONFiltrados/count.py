from re import I
import sys
import json
import math

from numpy import PINF, append


with open(sys.argv[1]) as fileList:
    for name in fileList:
        name = name.replace("\n", "")
        files = [f'{name}Original_Filtrado.json',f'{name}Generico_Filtrado.json']

        list_dicts = []

        for file in files:
            d = {}
            f = open(file)
            data = json.load(f)
            for i in data:
                if i['total'] > 0:
                    d[i['project']['id']] = i['total']
            list_dicts.append(d)
            # print(file.upper())
            # cant = len(data)
            # print(f'#PROY > 0 : {cant}')
            # total = sum(map(lambda x: int(x['total']), data))
            # print(f'TOTAL: {total}')
            # mean = 0
            # if cant > 0:
            #     mean= total/cant
            #     var = sum(map(lambda x: (int(x['total'])-mean)**2, data))/ cant
            # print(f'PROMEDIO: {mean}')
            # st_dev = math.sqrt(var)
            # print(f'STD: {st_dev}')


        dict_a = list_dicts[0]
        dict_b = list_dicts[1]

        inter = dict_a.keys() & dict_b.keys()
        not_inter = dict_a.keys() - dict_b.keys()
        diffs = []
        for id in inter:
            diffs.append(dict_a[id]-dict_b[id])
        #print(f'PROMEDIO: {sum(diffs)/len(diffs) if len(diffs)> 0 else 0}')
        #print(f'Diff: {len(diffs)}')
        print(not_inter)
        for id in not_inter:
            #print(dict_a[id])

            for file in files:
                d = {}
                f = open(file)
                data = json.load(f)
                for i in data:
                    if i['project']['id'] == id:
                        print( i['project']['url-identifier'])
        # Closing file
        f.close