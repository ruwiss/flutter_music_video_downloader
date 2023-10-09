import requests
import env
import database
import helper


def fetch_playlists():
    for fetch_item in database.get_fetch():
        lang = fetch_item["lang"]
        playlist_name = fetch_item["name"]
        playlist_id = fetch_item["playlist_id"]

        response = requests.get(env.fetch_playlist_url(playlist_id))
        playlist_items = response.json()["items"]

        video_ids = [
            item["snippet"]["resourceId"]["videoId"] for item in playlist_items
        ]

        fetched_data = []

        for video_id in video_ids:
            if database.is_blocked(video_id):
                continue
            try:
                response = requests.get(env.fetch_video_url(video_id))
                video_info = response.json()["items"][0]["snippet"]
                video_title = video_info["title"]
                thumbnail_url = video_info["thumbnails"]["default"]["url"]

                response = requests.get(env.fetch_video_duration_url(video_id))

                duration_str = response.json()["items"][0]["contentDetails"]["duration"]
                duration_list = (
                    duration_str.replace("PT", "")
                    .replace("H", ":")
                    .replace("M", ":")
                    .replace("S", "")
                    .split(":")
                )

                duration = ":".join([i.zfill(2) for i in duration_list])

                fetched_data.append(
                    {
                        "lang": lang,
                        "playlist_name": playlist_name,
                        "video_id": video_id,
                        "video_title": video_title,
                        "thumbnail_url": thumbnail_url,
                        "duration": duration,
                    }
                )

                print(f"({duration}): {video_title}")
            except:
                print(f"({video_id}) Fetch Error")

        database.remove_playlist_lang(lang)
        for data in fetched_data:
            database.set_top_list(
                data["lang"],
                data["playlist_name"],
                data["video_id"],
                data["video_title"],
                data["thumbnail_url"],
                data["duration"],
            )
        if not fetched_data:
            helper.api_alert(f"Fetch işleminde ciddi bir sorun var.")
        else:
            helper.api_alert(
                f"[{helper.get_current_time()}]: Oynatma listeleri güncellendi."
            )


if __name__ == "__main__":
    fetch_playlists()
