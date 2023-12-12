# Copyright 2023 a1147
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
import os
import sys
# CONTAINER ID   IMAGE                        COMMAND       CREATED      STATUS       PORTS                    NAMES
# ed608bafb770   bluenviron/mediamtx:latest   "/mediamtx"   2 days ago   Up 2 hours   0.0.0.0:8554->8554/tcp   media-server
# 
# ffmpeg -re -stream_loop -1 -i 3.mp4  -f rtsp -rtsp_transport tcp rtsp://127.0.0.1:8554/stream


# test valid: rtsp://admin:12345@172.0.0.15:554/h264/ch1/main/av_stream

# NVR: rtsp://admin:z1234567@172.0.0.2:554/Streaming/Channels/101
# 101指的是1通道，01主码流
# 回放: rtsp://admin:z1234567@172.0.0.2:554/Streaming/Tracks/101\?starttime=20230927t080000z&endtime=20230927t200000z
# rtsp://admin:z1234567@172.0.0.2:554/Streaming/Tracks/12101?starttime=20231123T115217Z&endtime=20231124T080000Z
# ffmpeg -rtsp_transport tcp -i rtsp://admin:z1234567@172.0.0.2:554/Streaming/Channels/101?starttime=20230916t083812z&endtime=20230910t084816z -vcodec copy -acodec copy -f flv rtmp://localhost:8554/stream

# 模拟海康
# ffmpeg -re -stream_loop -1 -i 黑苹果AMD笔记本教程.mp4 -rtsp_transport tcp  -f rtsp   rtsp://127.0.0.1:8554/Streaming/Channels/102
# ffmpeg -re -stream_loop -1 -i 黑苹果AMD笔记本教程.mp4 -rtsp_transport tcp  -f rtsp   rtsp://127.0.0.1:8554/Streaming/Tracks/102

# ?starttime=20131013t093812z&endtime=20131013t104816z
import os
import multiprocessing

def push_stream_by_video(video_path: str, channel_id: str):
    os.system(f'ffmpeg -re -stream_loop -1 -i {video_path} -c copy -an -f rtsp -rtsp_transport tcp  rtsp://localhost:8554/Streaming/Channels/{channel_id}02')


def push_playback_by_video(video_path: str, channel_id: str):
    os.system(f'ffmpeg -re -stream_loop -1 -i {video_path} -c copy -an -f rtsp -rtsp_transport tcp  rtsp://localhost:8554/Streaming/Tracks/{channel_id}02')

def push_video(video_path: str, channel_id: str):
    p1 = multiprocessing.Process(target=push_stream_by_video, args=[video_path, channel_id])
    p2 = multiprocessing.Process(target=push_playback_by_video, args=[video_path, channel_id])
    p1.start()
    p2.start()
    return (p1, p2)

if __name__ == "__main__":
    ps = []
    # for p in push_video('./videos/1/D128_20230926190002.mp4', '1'):
    #     ps.append(p)
    for p in push_video('./videos/test.mp4', '1'):
        ps.append(p)
    # for p in push_video('./videos/1/D104_20230926142900.mp4', '2'):
    #     ps.append(p)
    # for p in push_video('./videos/1/D47_20230926144009.mp4', '3'):
    #     ps.append(p)
    # for p in push_video('./videos/1/D58_20230926144123.mp4', '4'):
    #     ps.append(p)
    # for p in push_video('./videos/1/D123_20230926151703.mp4', '5'):
    #     ps.append(p)
    # for p in push_video('./videos/1/D58_20230926144123.mp4', '6'):
    #     ps.append(p)
    # for p in push_video('./videos/1/D127_20230926104305.mp4', '7'):
    #     ps.append(p)
    # for p in push_video('./videos/1/D48_20230926153006.mp4', '8'):
    #     ps.append(p)
    # for p in push_video('./videos/2/D61_20230926143703.mp4', '9'):
    #     ps.append(p)
    # for p in push_video('./videos/2/D100_20230928125003.mp4', '10'):
    #     ps.append(p)
    for p in ps:
        p.join()