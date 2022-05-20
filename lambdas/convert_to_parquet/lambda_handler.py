import logging
import pandas as pd
from botocore.exceptions import ClientError
from os import environ
import boto3
import json

logger = logging.getLogger()
PARQUET_DATA_BUCKET_NAME = environ.get('PARQUET_DATA_BUCKET_NAME')
s3_client = boto3.client('s3')
parquet_tmp_file = '/tmp/sales_data.parquet'

def lambda_handler(event, context):
    body = json.loads(event['Records'][0]['body'])
    bucket = body['Records'][0]['s3']['bucket']['name']
    key = body['Records'][0]['s3']['object']['key']
    tmp_file = '/tmp/' + key

    try:
        s3_client.download_file(bucket, key, tmp_file)
        df = pd.read_csv(tmp_file)
        df.to_parquet(parquet_tmp_file)
        parquet_file_key = parquet_tmp_file.split('/')[-1]
        response = s3_client.upload_file(tmp_file, PARQUET_DATA_BUCKET_NAME, parquet_file_key)
    except ClientError as e:
        logger.error(e)
        return False
    return True

