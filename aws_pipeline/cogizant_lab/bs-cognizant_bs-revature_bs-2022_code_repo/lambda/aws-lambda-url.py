from bs4 import BeautifulSoup
import requests
import boto3

url = "https://search.longhornrealty.com/idx/results/listings?pt=4&a_propStatus%5B%5D=Active&ccz=city&idxID=c007&per=25&srt=newest&city%5B%5D=22332&city%5B%5D=45916"
page = requests.get(url)


def lambda_handler(event, context):
    print("Hello Bryon Have a good afternoon!")
