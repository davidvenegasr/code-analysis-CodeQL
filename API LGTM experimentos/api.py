from unittest import result
import requests
import json 
import sys 
import pyjq

results = []
    
url = f'https://lgtm.com/api/v1.0/queryjobs/{sys.argv[1]}/results/?no-filter=True'
name = sys.argv[2]

response = requests.get(url, headers={"Accept":"application/json", "Authorization": "Bearer 26820ff16417539fb36b0fa49e190d27c437cf6a577220009b3316c71e100658"})
raw = response.json()  

for i in raw["data"]:  
    results.append(i) 
next_url = raw["next"]


while next:  
    r = requests.get(next_url, headers={"Authorization": "Bearer 26820ff16417539fb36b0fa49e190d27c437cf6a577220009b3316c71e100658"})
    raw = r.json()
    for i in raw["data"]:  
        results.append(i)                                
    if "next" in raw.keys():
        next_url = raw["next"]
    else: 
        next = None


with open(f'{name}.json', 'w') as f:
    json.dump(results, f)

resultsF = pyjq.all('.[] | select(.total>0)', results) 

with open(f'{name}_Filtrado.json', 'w') as f:
    json.dump(resultsF, f)
