#!/bin/bash

####################################################
# Script to build FuzzBench campaigns. Retry may be
# useful when some of the builds are failed.
####################################################

if [ $# -lt 2 ]; then
  echo "build-partial-targets: <fuzzer> <nproc>"
  exit 1
fi

# Bind fuzzer
FUZZER="$1"
N_PROC="$2"

# Benches#1
TARGETS=(
  bloaty_fuzz_target  curl_curl_fuzzer_http freetype2_ftfuzzer harfbuzz_hb-shape-fuzzer
  jsoncpp_jsoncpp_fuzzer lcms_cms_transform_fuzzer libjpeg-turbo_libjpeg_turbo_fuzzer libpcap_fuzz_both
  libxml2_xml re2_fuzzer sqlite3_ossfuzz zlib_zlib_uncompress_fuzzer
  # 20231023 zlib_zlib_uncompress_fuzzer failed for aflplusplus_406
  # 20231026 last fail is temporary, retry does work.
)


for TARGET in "${TARGETS[@]}"
do
  echo "make -j $N_PROC build-$FUZZER-$TARGET"
  make -j "$N_PROC" "build-$FUZZER-$TARGET"
done