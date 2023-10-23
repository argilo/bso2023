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

cat fm/dtmf.sigmf-data hop/hop.sigmf-data paint/paint.sigmf-data > out.sc16

grcc transmit.grc
