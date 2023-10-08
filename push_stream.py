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

# ffmpeg -rtsp_transport tcp -i rtsp://admin:z1234567@172.0.0.2:554/Streaming/Channels/101?starttime=20230916t083812z&endtime=20230910t084816z -vcodec copy -acodec copy -f flv rtmp://localhost:8554/stream

# 模拟海康
# ffmpeg -re -stream_loop -1 -i 黑苹果AMD笔记本教程.mp4 -rtsp_transport tcp  -f rtsp   rtsp://127.0.0.1:8554/Streaming/Channels/101
# ffmpeg -re -stream_loop -1 -i 黑苹果AMD笔记本教程.mp4 -rtsp_transport tcp  -f rtsp   rtsp://127.0.0.1:8554/Streaming/Tracks/101

# ?starttime=20131013t093812z&endtime=20131013t104816z


if __name__ == "__main__":
    pass