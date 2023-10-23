#!/bin/bash

if [ $# -lt 1 ]; then
  echo "build-partial-targets: <fuzzer>"
  exit 1
fi

# Bind fuzzer
FUZZER="$1"

TARGETS=(
  bloaty_fuzz_target  curl_curl_fuzzer_http freetype2_ftfuzzer harfbuzz_hb-shape-fuzzer
  jsoncpp_jsoncpp_fuzzer lcms_cms_transform_fuzzer libjpeg-turbo_libjpeg_turbo_fuzzer libpcap_fuzz_both
  libxml2_xml re2_fuzzer sqlite3_ossfuzz zlib_zlib_uncompress_fuzzer
)

for TARGET in "${TARGETS[@]}"
do
  echo "make -j$(nproc) build-$FUZZER-$TARGET"
  make -j"$(nproc)" "build-$FUZZER-$TARGET"
done