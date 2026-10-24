import csv,io,json,logging,os,boto3
from urllib.parse import unquote_plus
log=logging.getLogger(); log.setLevel(logging.INFO)
s3=boto3.client('s3')
def handler(event,context):
    failed=[]
    for record in event.get('Records',[]):
        try:
            msg=json.loads(record['body'])
            if msg.get('source')!='aws.s3' or msg.get('detail-type')!='Object Created': raise ValueError('INVALID_DATA unexpected event')
            detail=msg['detail']; bucket=detail['bucket']['name']; key=unquote_plus(detail['object']['key'])
            allowed={'science':os.environ['SCIENCE_BUCKET'],'medicine':os.environ['MEDICINE_BUCKET']}
            faculty=next((f for f,b in allowed.items() if b==bucket),None)
            if not faculty or not key.lower().endswith('.csv'): raise ValueError('INVALID_DATA invalid faculty or file type')
            data=s3.get_object(Bucket=bucket,Key=key)['Body'].read().decode('utf-8-sig')
            reader=csv.DictReader(io.StringIO(data))
            if not reader.fieldnames or 'value' not in reader.fieldnames: raise ValueError('INVALID_DATA missing value column')
            rows=list(reader)
            if not rows: raise ValueError('INVALID_DATA empty CSV')
            try: values=[float(row['value']) for row in rows]
            except (TypeError,ValueError): raise ValueError('INVALID_DATA non-numeric value') from None
            result={'faculty':faculty,'source_key':key,'records':len(values),'total':sum(values),'mean':sum(values)/len(values)}
            s3.put_object(Bucket=os.environ['OUTPUT_BUCKET'],Key=f'{faculty}/{key}.summary.json',Body=json.dumps(result).encode(),ContentType='application/json')
            log.info('PROCESSED faculty=%s key=%s',faculty,key)
        except Exception:
            log.exception('PROCESSING_ERROR messageId=%s',record['messageId'])
            failed.append({'itemIdentifier':record['messageId']})
    return {'batchItemFailures':failed}
