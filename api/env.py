api_key = "your_api_key"


def fetch_playlist_url(playlist_id):
    return f"https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId={playlist_id}&maxResults=15&key={api_key}"


def fetch_video_url(video_id):
    return f"https://www.googleapis.com/youtube/v3/videos?part=snippet&id={video_id}&key={api_key}"


def fetch_video_duration_url(video_id):
    return f"https://www.googleapis.com/youtube/v3/videos?part=contentDetails&id={video_id}&key={api_key}"


def youtube_watch(yt_id):
    return f"https://www.youtube.com/watch?v={yt_id}"


def search_api(query):
    return f"https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=15&q={query}&type=video&key={api_key}"



def youtube_search_url(query):
    return f"https://www.youtube.com/results?search_query={query}"


def auto_complete_api(query):
    return f"https://suggestqueries.google.com/complete/search?hl=en&ds=yt&q={query}&output=firefox"


yt_dl_audio_settings = {
    "format": "bestaudio",
    "outtmpl": "%(id)s.%(ext)s",
    "restrictfilenames": True,
    "ignoreerrors": True,
}

yt_dl_video_settings = {
    "format": "best",
    "outtmpl": "%(id)s.%(ext)s",
    "restrictfilenames": True,
    "ignoreerrors": True,
}
