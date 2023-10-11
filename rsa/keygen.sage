from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives.serialization import Encoding, NoEncryption, PublicFormat, PrivateFormat
import random

BITS = round(409.6)

half_bits = BITS // 2

p = next_prime(random.randrange(2^(half_bits-1), 2^half_bits))
q = next_prime(random.randrange(2^(half_bits-1), 2^half_bits))

n = p * q
e = 2^16 + 1

public_numbers = rsa.RSAPublicNumbers(int(e), int(n))
print(public_numbers)
public_key = public_numbers.public_key()

with open("public.pem", "wb") as f:
    f.write(public_key.public_bytes(Encoding.PEM, PublicFormat.SubjectPublicKeyInfo))

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
