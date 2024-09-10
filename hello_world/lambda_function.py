import json
import requests


def lambda_handler(event, context):

    response = requests.get("https://test-api.k6.io/public/crocodiles/")
    if response.status_code == 200:
        data = response.json()
        random_info = data

    else:
        random_info = "No data returned."

    return {
        "statusCode": 200,
        "body": json.dumps(
            {
                "message": "This message was created using a serverless REST API created with Terraform!",
                "random_info": random_info
            }
        ),
    }
