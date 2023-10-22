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

cat fm/dtmf.sigmf-data hop/hop.sigmf-data > out.sc16

grcc transmit.grc
