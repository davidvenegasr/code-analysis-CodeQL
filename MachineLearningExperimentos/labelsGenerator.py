 # Create .csv file with labels for each file in the folder and save it in the same folder

import csv
import api
                #Original, generic
queries = [('q1','4594110748752943812', '5746933745788705615'),
           ('q2','67975537488907456','3873070621485790444'),
           ('q3','301938438716750982','1316429291096176277'),
           ('q4','3111970067476574900','7022037157405226340'),
           ('q5','8300017492647067900','8196117331945926328'),
           ('q6','7022037157405226340','679640495890764388')]


def getIdList(data):
    ids = []
    for j in data:
        if j['status'] == 'success':
            ids.append(j['project']['id'])
    ids = [str(n) for n in ids]
    return ids

def getIntersection(lst1, lst2):
    return list(set(lst1) & set(lst2))

def getTotal(jsonList, id):
    for json in jsonList:
        if id == str(json['project']['id']):
            return json['total']

filename = 'labels.csv'
# opening the file with w+ mode truncates the file
f = open(filename, "w+")
header = ['query-idProyecto','gen >= rel* 1' , 'gen >= rel* 1.1', 'gen >= rel* 1.2', 'gen >= rel* 1.3']
writer = csv.writer(f)
writer.writerow(header)
f.close()

for q in queries:

    jsonOriginal = api.getJson(q[1])
    jsonGenerico = api.getJson(q[2])

    interIds = getIntersection(getIdList(jsonOriginal), getIdList(jsonGenerico))
        

    with open('labels.csv', 'a', encoding='UTF8', newline='') as file:
        writer = csv.writer(file)

        for id in interIds:
            orig = getTotal(jsonOriginal, id) 
            gen = getTotal(jsonGenerico, id) 
            bool1_0 = gen >= orig 
            bool1_1 = gen >= (orig * 1.1)
            bool1_2 = gen >= (orig * 1.2)
            bool3_3 = gen >= (orig * 1.3)
            row = [f'{q[0]}-{id}', bool1_0 ,bool1_1, bool1_2, bool3_3]
            writer.writerow(row)