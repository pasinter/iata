import logging
import requests
import boto3
from botocore.exceptions import ClientError
from os import environ

logger = logging.getLogger()
remote_archive = 'https://eforexcel.com/wp/wp-content/uploads/2020/09/2m-Sales-Records.zip'
csv_file = '2m Sales Records.csv'
ARCHIVE_BUCKET_NAME = environ.get('ARCHIVE_BUCKET_NAME')
s3_client = boto3.client('s3')

def download_file(url, local_filename):
    headers = {
        'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36',
        'sec-ch-ua': '" Not A;Brand";v="99", "Chromium";v="100", "Google Chrome";v="100"',
        'sec-ch-ua-mobile': '?0',
        'sec-ch-ua-platform': '"macOS"',
        'sec-fetch-dest': 'document',
        'sec-fetch-mode': 'navigate',
        'sec-fetch-site': 'none',
        'sec-fetch-user': '?1',
        'accept-encoding': 'gzip, deflate, br',
        'accept-language': 'en-GB,en;q=0.9,fr-FR;q=0.8,fr;q=0.7,ru-RU;q=0.6,ru;q=0.5,en-US;q=0.4,hy;q=0.3',
        'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
    }

    tmp_file = '/tmp/' + local_filename

    with requests.get(url, stream=True, headers=headers) as r:
        r.raise_for_status()
        with open(tmp_file, 'wb') as f:
            for chunk in r.iter_content(chunk_size=8192): 
                f.write(chunk)
    return tmp_file

def lambda_handler(event, context):
    logger.debug('Event: ' + str(event))
    local_filename = remote_archive.split('/')[-1]
    tmp_file = download_file(remote_archive, local_filename)

    try:
        response = s3_client.upload_file(tmp_file, ARCHIVE_BUCKET_NAME, local_filename)
    except ClientError as e:
        logging.error(e)
        return False

