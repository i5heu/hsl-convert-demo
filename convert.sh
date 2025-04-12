#!/bin/bash
set -e

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 input_video.mp4"
  exit 1
fi

INPUT="$1"

echo "Encoding AV1 HLS stream - Low Quality (360p)..."
ffmpeg -i "$INPUT" \
  -vf scale=-2:360 \
  -c:v libaom-av1 -crf 35 -b:v 0 -cpu-used 8 \
  -c:a aac -b:a 96k \
  -force_key_frames "expr:gte(t,n_forced*4)" \
  -reset_timestamps 1 \
  -avoid_negative_ts make_zero \
  -hls_time 4 \
  -hls_playlist_type vod \
  -hls_segment_type fmp4 \
  -hls_flags independent_segments \
  -hls_segment_filename "output_av1_low_%03d.m4s" \
  output_av1_low.m3u8

echo "Encoding AV1 HLS stream - High Quality (720p)..."
ffmpeg -i "$INPUT" \
  -vf scale=-2:720 \
  -c:v libaom-av1 -crf 30 -b:v 0 -cpu-used 8 \
  -c:a aac -b:a 128k \
  -force_key_frames "expr:gte(t,n_forced*4)" \
  -reset_timestamps 1 \
  -avoid_negative_ts make_zero \
  -hls_time 4 \
  -hls_playlist_type vod \
  -hls_segment_type fmp4 \
  -hls_flags independent_segments \
  -hls_segment_filename "output_av1_high_%03d.m4s" \
  output_av1_high.m3u8

echo "Encoding AV1 HLS stream - Full HD (1080p)..."
ffmpeg -i "$INPUT" \
  -vf scale=-2:1080 \
  -c:v libaom-av1 -crf 28 -b:v 0 -cpu-used 8 \
  -c:a aac -b:a 128k \
  -force_key_frames "expr:gte(t,n_forced*4)" \
  -reset_timestamps 1 \
  -avoid_negative_ts make_zero \
  -hls_time 4 \
  -hls_playlist_type vod \
  -hls_segment_type fmp4 \
  -hls_flags independent_segments \
  -hls_segment_filename "output_av1_fullhd_%03d.m4s" \
  output_av1_fullhd.m3u8

echo "Generating master playlist..."
cat <<EOF > master.m3u8
#EXTM3U
#EXT-X-VERSION:7
#EXT-X-STREAM-INF:BANDWIDTH=300000,RESOLUTION=640x360,CODECS="av01.0.05M.08, mp4a.40.2"
output_av1_low.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=600000,RESOLUTION=1280x720,CODECS="av01.0.05M.08, mp4a.40.2"
output_av1_high.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=1000000,RESOLUTION=1920x1080,CODECS="av01.0.05M.08, mp4a.40.2"
output_av1_fullhd.m3u8
EOF

echo "All streams and master playlist generated."
