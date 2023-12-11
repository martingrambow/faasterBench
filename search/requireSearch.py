import http.client
import json
import base64
conn = http.client.HTTPSConnection("api.github.com")

headersList = {
 "Accept": "*/*",
 "User-Agent": "Thunder Client (https://www.thunderclient.com)",
 "Authorization": "Bearer <GH PAT HERE>" 
}

payload = ""

conn.request("GET", "/search/code?q=require('nodemailer');+functions-framework+language:js&per_page=100", payload, headersList)
response = conn.getresponse()
result = response.read()
repoList = []
urlDict = {}
requireCountDict = {}
jsonfile = json.loads(result.decode("utf-8"))
for entry in jsonfile['items']:
    apiURL = entry['url'][22:]
    print(apiURL)
    repositoryURL = entry['repository']['full_name']
    functionURL = entry['html_url']
    urlDict[repositoryURL] = functionURL
    repoList.append(repositoryURL)   
    conn.request("GET", apiURL, payload, headersList)
    response = conn.getresponse()
    result = response.read()
    jsonfile1 = json.loads(result.decode("utf-8"))
    b64Bytes = jsonfile1['content'].encode("utf-8")
    print(b64Bytes)
    stringBytes = base64.b64decode(b64Bytes) 
    decodedString = stringBytes.decode("utf-8") 
    requires =decodedString.count("require")
    requireCountDict[functionURL] = requires
sortedDict = list(reversed(sorted(requireCountDict.items(), key=lambda x:x[1])))
for entry in sortedDict:
    print(entry)
