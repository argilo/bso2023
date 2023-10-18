#!/usr/bin/env python3

import random
import socket
import time

MEAN_SLEEP_TIME = 5.0
NUM_SENSORS = 20
FLAG_PROBABILITY = 0.05

UDP_IP = "127.0.0.1"
UDP_PORT = 1337

TARGET_LENGTH = 58

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

while True:
    sleep_time = random.expovariate(1 / MEAN_SLEEP_TIME)
    time.sleep(sleep_time)

    sensor_number = random.randint(1, NUM_SENSORS)
    temperature = random.gauss(28.0, 1.0)
    humidity = random.gauss(55, 3.0)
    if random.random() < FLAG_PROBABILITY:
        message = f"Sensor {sensor_number:02}: " + "Flag 2: flag{n3eD_2_cho0s3_b3tTer_n0nc3s}"
    else:
        message = f"Sensor {sensor_number:02}: Temperature {temperature:.1f}°C, Humidity {humidity:.0f}%"
    print(message)

    message_encoded = message.encode()
    message_encoded += bytes([0] * (TARGET_LENGTH - len(message_encoded)))
    print(message_encoded)
    sock.sendto(message_encoded, (UDP_IP, UDP_PORT))
