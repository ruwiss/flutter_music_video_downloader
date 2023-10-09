import json
import requests
from flask import Flask, abort, redirect, request, jsonify
import yt_dlp as youtube_dl
from bs4 import BeautifulSoup
from flask_cors import CORS
import env
import database
import helper

app = Flask(__name__)
CORS(app)


database.create_tables()


@app.route("/settings")
def get_settings():
    settings_json = {}
    for item in database.get_app_settings():
        settings_json[item["name"]] = item["value"]
    return jsonify(settings_json)


@app.route("/liste/<lang>")
def top(lang):
    data = database.get_top_list(lang)
    if not data:
        data = database.get_top_list("en")

    result = {"playLists": []}

    for item in data:
        playlist_name = item["playlist_name"]
        yt_id = item["yt_id"]
        title = item["title"]
        thumbnail = item["thumbnail"]
        duration = item["duration"]

        playlist_exists = False
        for playlist in result["playLists"]:
            if playlist_name in playlist:
                playlist_exists = True
                playlist[playlist_name][yt_id] = {
                    "title": title,
                    "thumbnail": thumbnail,
                    "duration": duration,
                }
                break

        if not playlist_exists:
            new_playlist = {
                playlist_name: {
                    yt_id: {
                        "title": title,
                        "thumbnail": thumbnail,
                        "duration": duration,
                    }
                }
            }
            result["playLists"].append(new_playlist)

    database.lang_request(lang)
    return jsonify(result)


@app.route("/dinle/<yt_id>")
def listen(yt_id):
    if database.is_blocked(yt_id):
        return abort(404)
    try:
        ydl = youtube_dl.YoutubeDL(env.yt_dl_audio_settings)
        with ydl:
            result = ydl.extract_info(env.youtube_watch(yt_id), download=False)
    except:
        return abort(404)

    listen_url = ""

    for f in result["formats"]:
        if "140" in f["format"]:
            listen_url = f["url"]

    if not listen_url:
        return abort(404)

    return redirect(listen_url)


@app.route("/yt/<yt_id>")
def download_mp4(yt_id):
    if database.is_blocked(yt_id):
        return abort(404)
    try:
        ydl = youtube_dl.YoutubeDL(env.yt_dl_video_settings)
        with ydl:
            result = ydl.extract_info(env.youtube_watch(yt_id), download=False)
    except:
        abort(404)

    download_url = ""
    for f in result["formats"]:
        audio_channels = f.get("audio_channels")
        ext = f.get("ext")
        if ext == "mp4" and audio_channels:
            download_url = f["url"]

    if not download_url:
        return abort(404)

    return redirect(download_url)


@app.route("/ara/v2/<query>")
def search(query):
    videos_info = []

    try:
        response = requests.get(env.youtube_search_url(query)).text
        soup = BeautifulSoup(response, "lxml")
        json_text = (
            str(soup)
            .split("var ytInitialData = ")[-1]
            .split("</script>")[0]
            .strip()[:-1]
        )

        json_data = json.loads(json_text)

        content = json_data["contents"]["twoColumnSearchResultsRenderer"][
            "primaryContents"
        ]["sectionListRenderer"]["contents"][0]["itemSectionRenderer"]["contents"]

        for data in content:
            for key, value in data.items():
                if type(value) is dict and key == "videoRenderer":
                    video_id = value.get("videoId")
                    if database.is_blocked(video_id):
                        continue
                    video_title = value.get("title")["runs"][0]["text"]
                    video_thumbnail = value.get("thumbnail")["thumbnails"][-1]["url"]
                    duration_list = value.get("lengthText")["simpleText"].split(":")
                    duration = ":".join([i.zfill(2) for i in duration_list])
                    videos_info.append(
                        {
                            "videoId": video_id,
                            "title": video_title,
                            "thumbnail": video_thumbnail,
                            "duration": duration,
                        }
                    )
    except:
        helper.api_alert("Youtube Arama - Scrape İşleminde Sorun Var")

        response = requests.get(env.deha_search_api(query))
        json_data = json.loads(response.text)
        if (
            (response.status_code == 200)
            and ("data" in json_data)
            and (json_data["data"] is not None)
        ):
            data = json.loads(response.text)["data"]
            print(type(data))
            if data is list:
                for i in data:
                    title = i["title"]
                    thumbnail = i["thumbnail"]
                    video_id = i["yid"]
                    if database.is_blocked(video_id):
                        continue
                    videos_info.append(
                        {"videoId": video_id, "title": title, "thumbnail": thumbnail}
                    )

        else:
            helper.api_alert("Harici API - Arama kısmı çalışmıyor.")

            response = requests.get(env.search_api(query))
            data = json.loads(response.text)

            for item in data["items"]:
                video_id = item["id"]["videoId"]  # video ID'si
                if database.is_blocked(video_id):
                    continue
                title = item["snippet"]["title"]  # video başlığı
                thumbnail = item["snippet"]["thumbnails"]["default"][
                    "url"
                ]  # video küçük resmi
                videos_info.append(
                    {"videoId": video_id, "title": title, "thumbnail": thumbnail}
                )

        return videos_info

    return videos_info


@app.route("/complete/<query>")
def auto_complete(query):
    response = requests.get(env.auto_complete_api(query))
    if response.status_code != 200:
        return abort(response.status_code)

    data = json.loads(response.text)
    return {data[0]: data[1]}


@app.route("/ringtones/")
@app.route("/ringtones/<id>")
def get_ringtone(id=None):
    if id:
        return redirect(database.get_ringtone_url(id))
    else:
        return jsonify(database.get_ringtones())


# ----------- Admin Panel ----------- #


@app.route("/e/settings", methods=["GET", "POST", "DELETE"])
def app_settings():
    if request.method == "GET":
        return database.get_app_settings()
    elif request.method == "POST":
        data = request.get_json()
        database.set_app_setting(data["name"], data["value"])
        return "OK"
    elif request.method == "DELETE":
        data = request.get_json()
        database.delete_app_setting(data["name"])
        return "OK"


@app.route("/e/block", methods=["GET", "POST"])
def blocked_videos():
    if request.method == "GET":
        return [e["yt_id"] for e in database.get_blocks()]
    elif request.method == "POST":
        data = request.get_json()
        if "block" in data:
            yt_id_list = [tuple([yt_id]) for yt_id in data["block"]]
            database.set_blocks(yt_id_list)
        return "OK"
    else:
        return abort(404)


@app.route("/e/langRequests")
def language_requests():
    return jsonify(database.get_lang_requests())


@app.route("/e/content", methods=["GET", "POST"])
def edit_content():
    if request.method == "GET":
        return database.get_fetch(is_json=True)
    elif request.method == "POST":
        data = request.get_json()
        database.set_fetch(data["fetch"])
        return "OK"
    else:
        return abort(404)


@app.route("/e/log", methods=["GET", "DELETE"])
def log_data():
    if request.method == "GET":
        with open("log.txt", "r", encoding="utf-8") as log:
            return {"log": "".join(log.readlines())}
    elif request.method == "DELETE":
        with open("log.txt", "w", encoding="utf-8") as log:
            log.write(f"Temizlendi: {helper.get_current_time()}")
        return "OK"
    else:
        return abort(404)


@app.route("/e/ringtone", methods=["GET", "POST", "DELETE"])
def ringtone():
    if request.method == "GET":
        return jsonify(database.get_all_ringtones())
    elif request.method == "POST":
        data = request.get_json()
        database.insert_ringtone(data)
        return "OK"
    elif request.method == "DELETE":
        data = request.get_json()
        database.remove_ringtone(data["id"])
        return "OK"
    else:
        return abort(404)


if __name__ == "__main__":
    app.run(debug=False)
