#!/usr/bin/env python3

import hashlib
import random
import secrets
import socket
import struct
import threading
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes

UDP_IP = "127.0.0.1"
UDP_PORT = 1337


def encrypt(key, plaintext):
    nonce = hashlib.sha256(secrets.token_bytes(1)).digest()[:8]
    counter = 0
    full_nonce = struct.pack("<Q", counter) + nonce
    algorithm = algorithms.ChaCha20(key, full_nonce)
    cipher = Cipher(algorithm, mode=None)
    encryptor = cipher.encryptor()
    ciphertext = encryptor.update(plaintext)
    return nonce + ciphertext


# Send periodic test messages of our own to make sure the system is working.
def send_test_messages(stop_event, stop_condition):
    MEAN_SLEEP_TIME = 5.0
    send_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    n = 1

    while not stop_event.is_set():
        message = f"This is a periodic test message. Sequential number: {n:05}."
        send_sock.sendto(message.encode(), (UDP_IP, UDP_PORT))
        n += 1

        sleep_time = random.expovariate(1 / MEAN_SLEEP_TIME)
        stop_condition.acquire()
        stop_condition.wait(sleep_time)
        stop_condition.release()


with open("key.bin", "rb") as f:
    key = f.read(32)

recv_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
recv_sock.bind((UDP_IP, UDP_PORT))

stop_event = threading.Event()
stop_condition = threading.Condition()
thread = threading.Thread(target=send_test_messages, args=(stop_event, stop_condition))
thread.start()

try:
    while True:
        message, _ = recv_sock.recvfrom(1024)
        print(message)
        print(encrypt(key, message).hex())
except KeyboardInterrupt:
    stop_event.set()
    stop_condition.acquire()
    stop_condition.notify()
    stop_condition.release()
