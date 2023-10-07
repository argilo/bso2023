#!/usr/bin/env python3

import random
import socket
import time

MEAN_SLEEP_TIME = 5.0
NUM_SENSORS = 20
FLAG_PROBABILITY = 0.05

UDP_IP = "127.0.0.1"
UDP_PORT = 1337

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

tot = 0
for _ in range(1000):
    sleep_time = random.expovariate(1 / MEAN_SLEEP_TIME)
    time.sleep(sleep_time)

    sensor_number = random.randint(1, NUM_SENSORS)
    temperature = random.gauss(28.0, 1.0)
    humidity = random.gauss(55, 3.0)
    if random.random() < FLAG_PROBABILITY:
        message = f"Sensor {sensor_number:02}: " + "flag{foobarbazfoobarbazfoobarbaz}"
    else:
        message = f"Sensor {sensor_number:02}: Temperature {temperature:.1f}°C, Humidity {humidity:.0f}%"
    print(message)
    sock.sendto(message.encode(), (UDP_IP, UDP_PORT))
