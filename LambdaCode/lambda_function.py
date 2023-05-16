import json


def retrieve_handler(event, context):
    response = [
        {"id": 1, "name": "Anakin Skywalker"},
        {"id": 2, "name": "Darth Vader"},
        {"id": 3, "name": "Obi Wan Kenobi"},
        {"id": 4, "name": "Han Solo"},
    ]
    return {"statusCode": 200, "body": json.dumps(response)}
