import http.client
import json
conn = http.client.HTTPSConnection("api.github.com")

headersList = {
 "Accept": "*/*",
 "User-Agent": "Thunder Client (https://www.thunderclient.com)",
 "Authorization": "Bearer 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" 
}

payload = ""

conn.request("GET", "/search/code?q=require('nodemailer');+functions-framework:js&per_page=100", payload, headersList)
response = conn.getresponse()
result = response.read()
repoList = []
urlDict = {}
starFunctionDict = {}
print(result.decode("utf-8"))
jsonfile = json.loads(result.decode("utf-8"))
for entry in jsonfile['items']:
    repositoryURL = entry['repository']['full_name']
    functionURL = entry['html_url']
    urlDict[repositoryURL] = functionURL
    repoList.append(repositoryURL)
for entry in repoList:
    print(entry)
    conn.request("GET", "/repos/"+entry, payload, headersList)
    response = conn.getresponse()
    result = response.read()
    #print(result.decode("utf-8"))
    jsonresult = json.loads(result.decode("utf-8"))
    stars = jsonresult['stargazers_count']
    starFunctionDict[urlDict[entry]] = stars 
sortedDict = list(reversed(sorted(starFunctionDict.items(), key=lambda x:x[1])))
for entry in sortedDict:
    print(entry)
