from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives.serialization import Encoding, NoEncryption, PublicFormat, PrivateFormat
from datetime import datetime
import json
import random
import zipfile

FLAG = "flag{oOoo0pS_0fF_bY_10x}"
BITS = round(409.6)

NUM_FILES = 1000
START_DT = datetime(2023, 1, 1)
END_DT = datetime(2023, 10, 26)

half_bits = BITS // 2

p = next_prime(random.randrange(2^(half_bits-1), 2^half_bits))
q = next_prime(random.randrange(2^(half_bits-1), 2^half_bits))

n = p * q
e = 2^16 + 1

public_numbers = rsa.RSAPublicNumbers(int(e), int(n))
public_key = public_numbers.public_key()

# display with: openssl rsa -pubin -in public.pem -text -noout

phi = (p-1) * (q-1)
d = inverse_mod(e, phi)
dmp1 = d % (p-1)
dmq1 = d % (q-1)
iqmp = inverse_mod(q, p)

private_numbers = rsa.RSAPrivateNumbers(int(p), int(q), int(d), int(dmp1),
                                        int(dmq1), int(iqmp), public_numbers)
private_key = private_numbers.private_key()

with open("private.pem", "wb") as f:
    f.write(private_key.private_bytes(Encoding.PEM, PrivateFormat.PKCS8, NoEncryption()))

# display with: openssl rsa -in private.pem -text -noout

assert len(FLAG) % 2 == 0
flag_indexes = random.sample(range(NUM_FILES), len(FLAG) // 2)
flag_offset = 0
dts = [datetime.fromtimestamp(random.uniform(START_DT.timestamp(), END_DT.timestamp())) for _ in range(NUM_FILES)]
dts.sort()

with zipfile.ZipFile("crypt.zip", "w") as myzip:
    zi = zipfile.ZipInfo(filename="public.pem", date_time=(2022, 3, 4, 14, 15, 16))
    with myzip.open(zi, "w") as f:
        f.write(public_key.public_bytes(Encoding.PEM, PublicFormat.SubjectPublicKeyInfo))

    for index, dt in enumerate(dts):
        payload = {
            "machine_id": random.randrange(20, 40),
            "status": "ok"
        }

        if index in flag_indexes:
            payload["status"] = FLAG[flag_offset:flag_offset + 2]
            flag_offset += 2

        json_payload = json.dumps(payload, separators=(",", ":"))
        plaintext = json_payload.encode()
        assert len(plaintext) <= 41

        ciphertext = public_key.encrypt(json_payload.encode()[:41], padding.PKCS1v15())
        filename = f"log/{dt.year:04}{dt.month:02}{dt.day:02}_{dt.hour:02}{dt.minute:02}{dt.second:02}.enc"
        zi = zipfile.ZipInfo(filename, date_time=(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second))

        with myzip.open(zi, "w") as f:
            f.write(ciphertext)

# decrypt with: openssl pkeyutl -decrypt -inkey private.pem -in message.enc
