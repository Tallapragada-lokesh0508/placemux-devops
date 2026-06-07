import json

def predict(event, context):
    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Inference endpoint ready', 'service': 'placemux-ml'})
    }
