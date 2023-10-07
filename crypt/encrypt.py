#!/usr/bin/env python3

import hashlib
import secrets
import socket
import struct

from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes


def encrypt(key, plaintext):
    nonce = hashlib.sha256(secrets.token_bytes(1)).digest()[:8]
    counter = 0
    full_nonce = struct.pack("<Q", counter) + nonce
    algorithm = algorithms.ChaCha20(key, full_nonce)
    cipher = Cipher(algorithm, mode=None)
    encryptor = cipher.encryptor()
    ciphertext = encryptor.update(plaintext)
    return nonce + ciphertext


with open("key.bin", "rb") as f:
    key = f.read(32)

UDP_IP = "127.0.0.1"
UDP_PORT = 1337

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.settimeout(5.0)
sock.bind((UDP_IP, UDP_PORT))

n = 1
while True:
    try:
        message, _ = sock.recvfrom(1024)
    except TimeoutError:
        message = f"This is a periodic test message. Sequential number: {n:05}.".encode()
        n += 1
    print(message)
    print(encrypt(key, message).hex())
