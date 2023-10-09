import sqlite3
import json
import helper
from datetime import datetime

conn = sqlite3.connect("data.db", check_same_thread=False)
conn.row_factory = sqlite3.Row

cur = conn.cursor()


def create_tables():
    sql = """
    CREATE TABLE IF NOT EXISTS app (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        value TEXT
    );

    CREATE TABLE IF NOT EXISTS blocked (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        yt_id TEXT
    );

    CREATE TABLE IF NOT EXISTS lang_requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lang TEXT,
        count INTEGER
    );

    CREATE TABLE IF NOT EXISTS fetch (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lang TEXT,
        name TEXT,
        playlist_id TEXT
    );


    CREATE TABLE IF NOT EXISTS top_list (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lang TEXT,
        playlist_name TEXT,
        yt_id TEXT,
        title TEXT,
        thumbnail TEXT,
        duration TEXT
    );

    CREATE TABLE IF NOT EXISTS ringtones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        image TEXT,
        url TEXT
    );

    """
    cur.executescript(sql)
    conn.commit()


def is_blocked(yt_id):
    cur.execute("SELECT id FROM blocked WHERE yt_id = ?", (yt_id,))
    return cur.fetchone()


def get_blocks():
    cur.execute("SELECT * FROM blocked")
    return cur.fetchall()


def set_blocks(yt_id_list):
    cur.execute("DELETE FROM blocked")
    cur.executemany("INSERT INTO blocked (yt_id) VALUES (?)", (yt_id_list))
    conn.commit()


def get_lang_requests():
    cur.execute("SELECT * FROM lang_requests")
    return json.loads(helper.row_to_json_str(cur.fetchall()))


def lang_request(lang):
    sql = "SELECT * FROM lang_requests WHERE lang = ?"
    cur.execute(sql, (lang,))
    single = cur.fetchall()

    count = 1
    if single:
        count = single[0]["count"] + 1
        cur.execute(
            "UPDATE lang_requests SET count = ? WHERE id = ?", (count, single[0]["id"])
        )
    else:
        cur.execute("INSERT INTO lang_requests (lang, count) VALUES (?, ?)", (lang, 1))
    conn.commit()
    set_app_user_counter(count)


def get_fetch(is_json=False):
    cur.execute("SELECT * FROM fetch")
    if is_json:
        return json.loads(helper.row_to_json_str(cur.fetchall()))
    else:
        return cur.fetchall()


def set_fetch(data):
    cur.execute("DELETE FROM fetch")
    for key, items in data.items():
        for item in items:
            cur.execute(
                "INSERT INTO fetch (name, lang, playlist_id) VALUES (?, ?, ?)",
                (item["name"], key, item["playlist_id"]),
            ),
    conn.commit()


def get_top_list(lang):
    cur.execute("SELECT * FROM top_list WHERE lang = ?", (lang,))
    return cur.fetchall()


def remove_playlist_lang(lang):
    cur.execute("DELETE FROM top_list WHERE lang = ?", (lang,))
    conn.commit()


def set_top_list(lang, playlist_name, yt_id, title, thumbnail, duration):
    cur.execute(
        "INSERT INTO top_list (lang, playlist_name, yt_id, title, thumbnail, duration) VALUES (?, ?, ?, ?, ?, ?)",
        (lang, playlist_name, yt_id, title, thumbnail, duration),
    )
    conn.commit()


def get_app_settings():
    cur.execute("SELECT * FROM app")
    return json.loads(helper.row_to_json_str(cur.fetchall()))


def set_app_setting(name, value):
    cur.execute("SELECT id FROM app WHERE name = ?", (name,))
    id = cur.fetchone()
    if id:
        cur.execute(
            "UPDATE app SET name = ?, value = ? WHERE id = ?", (name, value, id[0])
        )
    else:
        cur.execute("INSERT INTO app (name, value) VALUES (?, ?)", (name, value))

    conn.commit()


def delete_app_setting(name):
    cur.execute("DELETE FROM app WHERE name = ?", (name,))
    conn.commit()


def set_app_user_counter(count):
    setting = "user_count_timestamp"
    cur.execute("SELECT value FROM app WHERE name = ?", (setting,))
    data = cur.fetchone()

    now = datetime.now()
    now_timestamp = datetime.timestamp(now)

    if data:
        timestamp = data[0]
        user_datetime = datetime.fromtimestamp(float(timestamp))
        same_day = (now.month == user_datetime.month) and (now.day == user_datetime.day)

        if not same_day:
            cur.execute(
                "UPDATE app SET value = ? WHERE name = ?", (now_timestamp, setting)
            )
            cur.execute("DELETE FROM lang_requests")
            helper.api_alert(
                f"[{helper.get_current_time()}] Bugün uygulamaya giriş sayısı: {count}"
            )
            conn.commit()
    else:
        cur.execute(
            "INSERT INTO app (name, value) VALUES (?, ?)", (setting, now_timestamp)
        )
        conn.commit()


def get_all_ringtones():
    cur.execute("SELECT * FROM ringtones")
    return json.loads(helper.row_to_json_str(cur.fetchall()))


def get_ringtones():
    cur.execute("SELECT id, title, image FROM ringtones")
    return json.loads(helper.row_to_json_str(cur.fetchall()))


def get_ringtone_url(id):
    cur.execute("SELECT url FROM ringtones WHERE id = ?", (id,))
    data = cur.fetchone()
    return data[0]


def insert_ringtone(data):
    cur.execute(
        "INSERT INTO ringtones (title, image, url) VALUES (?, ?, ?)",
        (data["title"], data["image"], data["url"]),
    )
    conn.commit()


def remove_ringtone(id):
    cur.execute("DELETE FROM ringtones WHERE id = ?", (id,))
    conn.commit()
