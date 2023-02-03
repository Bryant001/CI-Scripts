import sys
import requests
import json
from veracode_api_signing.plugin_requests import RequestsAuthPluginVeracodeHMAC


api_base = "https://api.veracode.com/appsec/v1"
sca_base = "https://api.veracode.com/srcclr"
headers = {"User-Agent": "Python HMAC Example"}
app_name = "verademo_dotnet"
sbom_out = {}

if __name__ == "__main__":
    if not app_name:
        query_name = ""
    else:
        query_name = "?name=" + app_name
    try:
        response = requests.get(api_base + "/applications" + query_name, auth=RequestsAuthPluginVeracodeHMAC(), headers=headers)
    except requests.RequestException as e:
        print("Whoops!")
        print(e)
        sys.exit(1)

    if response.ok:
        data = response.json()
        data_file = open("SBOM.json", "w", newline='')
        for app in data["_embedded"]["applications"]:
            print(app["profile"]["name"]) # prints the app names to the console/terminal
            print(app["guid"])
            try:
                response2 = requests.get(sca_base + "/sbom/v1/targets/" + app["guid"] + "/cyclonedx?type=application&linked=true", auth=RequestsAuthPluginVeracodeHMAC(), headers=headers)
                sbom = response2.json()
                json.dump(sbom, data_file, indent=4)
            except requests.RequestException as e:
                print("Whoops!")
                print(e)
                sys.exit(1)
        data_file.close()
    else:
        print(response.status_code)
