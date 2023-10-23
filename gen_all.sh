#!/usr/bin/env bash

set -e

cd crypt
./keygen.py
grcc fsk_tx.grc
cd ..

cd fm
grcc extract_fm.grc
./extract_fm.py
cd ..

cd hop
grcc hop.grc
./hop.py
cd ..

cd paint
grcc paint_wide.grc
convert \
  -background Black \
  -gravity Center \
  -pointsize 600 \
  -fill White \
  label:'flag\{this_is_a_very_wide_flag_indeed_c928359da12a4a00e32fa43063e5037256c571a0e75ff2019a6741215a166ff9\}' \
  -extent 40960x \
  -resize 4096x\! \
  flag.png
./paint_wide.py
cd ..

cd m17
grcc m17.grc
cat <(dd if=/dev/zero bs=16000 count=3) <(sox m17_flag.wav -r 8000 -t raw -) | ~/git/m17-tools/build/apps/m17-mod -S VE3IRR --bin > m17.bin
./m17.py
cd ..

cat fm/dtmf.sigmf-data m17/m17.sigmf-data hop/hop.sigmf-data paint/paint.sigmf-data > out.cf32

grcc transmit.grc
