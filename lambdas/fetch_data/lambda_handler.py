import logging
import requests

logger = logging.getLogger()

remote_file = 'https://eforexcel.com/wp/wp-content/uploads/2020/09/2m-Sales-Records.zip'

def download_file(url, local_filename):
    with requests.get(url, stream=True) as r:
        r.raise_for_status()
        with open(local_filename, 'wb') as f:
            for chunk in r.iter_content(chunk_size=8192): 
                f.write(chunk)

def lambda_handler(event, context):
    logger.debug('Event: ' + str(event))
    local_filename = remote_file.split('/')[-1]
    download_file(remote_file, local_filename)
