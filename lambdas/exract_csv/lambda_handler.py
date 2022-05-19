from zipfile import ZipFile
from botocore.exceptions import ClientError
from os import environ

logger = logging.getLogger()
csv_file = '2m Sales Records.csv'
ARCHIVE_BUCKET_NAME = environ.get('ARCHIVE_BUCKET_NAME')
s3_client = boto3.client('s3')

def unzip_file(archive_name):
    tmp_file = '/tmp/' + csv_file
    with zipfile.ZipFile(archive_name) as z:
        with open(tmp_file, 'wb') as f:
            f.write(z.read(csv_file))
    return tmp_file

def lambda_handler(event, context):
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    tmp_file = '/tmp/' + key

    try:
        s3_client.download_file(bucket, key, tmp_file)
        csv_tmp_file = unzip_file(tmp_file)
        csv_file_key = csv_tmp_file.split('/')[-1]
        response = s3_client.upload_file(csv_file, ARCHIVE_BUCKET_NAME, csv_file_key)
    except ClientError as e:
        logger.error(e)
        return False
    return True

