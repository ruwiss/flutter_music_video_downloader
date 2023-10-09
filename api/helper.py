from datetime import datetime
import json


def row_to_json_str(data) -> str:
    return json.dumps([dict(row) for row in data], indent=2)


def get_current_time():
    now = datetime.now()
    return now.strftime("%d/%m/%Y %H:%M:%S")


def api_alert(alert):
    with open("log.txt", "a", encoding="utf-8") as log:
        log.write(f"\n{get_current_time()}: {alert}")
        print(alert)
