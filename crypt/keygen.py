#!/usr/bin/env python3

import secrets

with open("key.bin", "wb") as f:
    f.write(secrets.token_bytes(32))
