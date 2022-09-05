"""

Ejemplo de uso en linux: 
python3 api.py 67975537488907456 LDAPOriginal

"""

from unittest import result
from urllib import response
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry
import json 

def getIdList(data):
    ids = []
    for j in data:
        if j['status'] == 'success':
            ids.append(j['project']['id'])
    ids = [str(n) for n in ids]
    return ids

def getJson(arg):

    results = []
    
    url = f'https://lgtm.com/api/v1.0/queryjobs/{arg}/results/'

    response = requests.get(url, headers={"Accept":"application/json", "Authorization": "Bearer 26820ff16417539fb36b0fa49e190d27c437cf6a577220009b3316c71e100658"})
    raw = response.json()  

    for i in raw["data"]:  
        results.append(i) 
    next_url = raw["next"]

    while next_url:  
        r = requests.get(next_url, headers={"Authorization": "Bearer 26820ff16417539fb36b0fa49e190d27c437cf6a577220009b3316c71e100658"})
        raw = r.json()
        for i in raw["data"]:  
            results.append(i)                                
        if "next" in raw.keys():
            next_url = raw["next"]
        else: 
            next_url = None
    
    json_string = json.dumps(results)
    data = json.loads(json_string)
    return data



def getJsonResultsDetailed(query_id,proyct_id=None):

    url = f'https://lgtm.com/api/v1.0/queryjobs/{query_id}/results/{proyct_id}'
    
    session = requests.Session()
    retry = Retry(connect=10, backoff_factor=0.5)
    adapter = HTTPAdapter(max_retries=retry)
    session.mount('http://', adapter)
    session.mount('https://', adapter)

    
    results = []
    

    # response = requests.get(url, headers={"Accept":"application/json", "Authorization": "Bearer 26820ff16417539fb36b0fa49e190d27c437cf6a577220009b3316c71e100658"})
    response = session.get(url, headers={"Accept":"application/json", "Authorization": "Bearer 26820ff16417539fb36b0fa49e190d27c437cf6a577220009b3316c71e100658"})
    raw = response.json()  

    if 'data' in raw.keys():
        for i in raw["data"]:  
            results.append(i) 

    if 'next' in raw.keys():
        next_url = raw["next"]
    else:
        next_url = None
        
    while next_url:  
        # r = requests.get(next_url, headers={"Authorization": "Bearer 26820ff16417539fb36b0fa49e190d27c437cf6a577220009b3316c71e100658"})
        r = session.get(next_url, headers={"Authorization": "Bearer 26820ff16417539fb36b0fa49e190d27c437cf6a577220009b3316c71e100658"})
        raw = r.json()
        if 'data' in raw.keys():
            for i in raw["data"]:  
                results.append(i) 
                                            
        if "next" in raw.keys():
            next_url = raw["next"]
        else: 
            next_url = None

    
    json_string = json.dumps(results)
    data = json.loads(json_string)
    return data

if __name__ == "__main__":
    #print(getJson(3778082360928566917))
    print(getJsonResultsDetailed(3778082360928566917, 1877191215))