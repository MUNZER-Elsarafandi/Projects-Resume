#!/usr/bin/env python3

"""
---------------------------------------------

Name : Munzer Elsarafandi

---------------------------------------------

Cryptography Benchmarking Project

This script benchmarks the performance of:

• Symmetric encryption:
    - AES-GCM
    - ChaCha20-Poly1305

• Asymmetric encryption:
    - RSA-OAEP

• Digital signatures:
    - RSA-PSS
    - DSA
    - ECDSA

• Key generation performance:
    - RSA
    - DSA
    - ECC

The script executes all benchmark categories in a single run and
automatically generates the CSV output files inside the 'results/' directory.

---------------------------------------------
Benchmark System Specification:

OS       : Windows 10
Python   : 3.12.6
Package  : cryptography 46.0.3
---------------------------------------------
"""

import os
import time
import csv
from pathlib import Path
import statistics

from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import rsa, dsa, ec, padding
from cryptography.hazmat.primitives.ciphers.aead import AESGCM, ChaCha20Poly1305

import pandas as pd
import matplotlib.pyplot as plt

# ======================== SETTINGS ========================

N_RUNS = 10
PLAINTEXT_SIZE = 10 * 1024
OUT_DIR = Path("results")
OUT_DIR.mkdir(exist_ok=True)

SECURITY_LEVELS = [80, 112, 128, 192, 256]

RSA_KEY_SIZES = {
    80: 1024,
    112: 2048,
    128: 3072,
    192: 4096,
    256: 8192,
}

DSA_KEY_SIZES = {
    80: 1024,
    112: 2048,
    128: 3072,
    192: None,
    256: None,
}

ECC_CURVES = {
    80: ec.SECP192R1(),
    112: ec.SECP224R1(),
    128: ec.SECP256R1(),
    192: ec.SECP384R1(),
    256: ec.SECP521R1(),
}

AES_KEY_SIZES = [128, 192, 256]


# ======================== UTILITY FUNCTIONS ========================

def mean_excluding_first(values):
    values = [v for v in values if v is not None]
    if len(values) <= 1:
        return None
    return statistics.mean(values[1:])


def time_function(fn, *args, **kwargs):
    t0 = time.perf_counter()
    result = fn(*args, **kwargs)
    t1 = time.perf_counter()
    return result, (t1 - t0)


# Clean, simple table
def print_table(headers, rows):
    if not rows:
        return

    rows = [[str(c) for c in row] for row in rows]

    widths = [len(h) for h in headers]
    for row in rows:
        for i, val in enumerate(row):
            widths[i] = max(widths[i], len(val))

    fmt = "  ".join(f"{{:<{w}}}" for w in widths)

    sep = "-" * (sum(widths) + 2 * (len(widths) - 1))

    print(fmt.format(*headers))
    print(sep)

    for row in rows:
        print(fmt.format(*row))

    print(sep)
    print()


# ======================== KEY GENERATION BENCHMARK ========================

def bench_keygen():
    rows = []

    for sec in SECURITY_LEVELS:
        rsa_size = RSA_KEY_SIZES.get(sec)
        if rsa_size:
            times = []
            for i in range(N_RUNS):
                try:
                    _, t = time_function(
                        rsa.generate_private_key,
                        public_exponent=65537,
                        key_size=rsa_size
                    )
                except Exception as e:
                    print(f"[!] RSA {rsa_size} key creation error: {e}")
                    t = None
                times.append(t)
                rows.append(["RSA", sec, rsa_size, i+1, t])
            mean_excluding_first(times)

        dsa_size = DSA_KEY_SIZES.get(sec)
        if dsa_size:
            times = []
            for i in range(N_RUNS):
                try:
                    _, t = time_function(dsa.generate_private_key, key_size=dsa_size)
                except Exception as e:
                    print(f"[!] DSA {dsa_size} key creation error: {e}")
                    t = None
                times.append(t)
                rows.append(["DSA", sec, dsa_size, i+1, t])
            mean_excluding_first(times)

        curve = ECC_CURVES.get(sec)
        if curve:
            times = []
            for i in range(N_RUNS):
                try:
                    _, t = time_function(ec.generate_private_key, curve)
                except Exception as e:
                    print(f"[!] ECC {curve.name} key creation error: {e}")
                    t = None
                times.append(t)
                rows.append(["ECC", sec, curve.name, i+1, t])
            mean_excluding_first(times)

    file = OUT_DIR / "keygen_results.csv"
    with file.open("w", newline="") as f:
        w = csv.writer(f)
        header = ["algorithm", "security_bits", "param"] + [f"run_{i+1}" for i in range(N_RUNS)] + ["average_time"]
        w.writerow(header)

        from collections import defaultdict
        grouped = defaultdict(list)

        for alg, sec, param, run, t in rows:
            grouped[(alg, sec, param)].append(t)

        table_rows = []

        for (alg, sec, param), times in grouped.items():
            avg = mean_excluding_first(times)
            row = [alg, sec, param] + [
                ("" if t is None else f"{t:.6f}") for t in times
            ] + [("" if avg is None else f"{avg:.6f}")]
            w.writerow(row)
            table_rows.append([alg, sec, param, f"{avg:.6f}s" if avg else "Failed"])

    print(f"[+] Key generation benchmark complete -> {file}")
    print_table(["Algorithm", "Security", "Parameter", "Avg Time"], table_rows)


# ======================== SYMMETRIC CIPHER BENCHMARK ========================

def bench_symmetric():
    rows = []
    plaintext = os.urandom(PLAINTEXT_SIZE)

    for key_bits in AES_KEY_SIZES:
        key_bytes = key_bits // 8
        aes_key = os.urandom(key_bytes)
        aesgcm = AESGCM(aes_key)

        for i in range(N_RUNS):
            nonce = os.urandom(12)

            def do_encrypt():
                return aesgcm.encrypt(nonce, plaintext, None)

            ct, t_enc = time_function(do_encrypt)

            def do_decrypt():
                return aesgcm.decrypt(nonce, ct, None)

            pt, t_dec = time_function(do_decrypt)
            assert pt == plaintext

            rows.append(["AES-GCM", key_bits, "encrypt", i+1, t_enc])
            rows.append(["AES-GCM", key_bits, "decrypt", i+1, t_dec])

    ch_key = os.urandom(32)
    ch = ChaCha20Poly1305(ch_key)

    for i in range(N_RUNS):
        nonce = os.urandom(12)

        def do_encrypt():
            return ch.encrypt(nonce, plaintext, None)

        ct, t_enc = time_function(do_encrypt)

        def do_decrypt():
            return ch.decrypt(nonce, ct, None)

        pt, t_dec = time_function(do_decrypt)
        assert pt == plaintext

        rows.append(["ChaCha20", 256, "encrypt", i+1, t_enc])
        rows.append(["ChaCha20", 256, "decrypt", i+1, t_dec])

    file = OUT_DIR / "symmetric_results.csv"
    with file.open("w", newline="") as f:
        w = csv.writer(f)
        header = ["algorithm", "key_bits", "operation"] + [f"run_{i+1}" for i in range(N_RUNS)] + ["average_time"]
        w.writerow(header)

        from collections import defaultdict
        grouped = defaultdict(list)

        for alg, bits, op, run, t in rows:
            grouped[(alg, bits, op)].append(t)

        table_rows = []

        for (alg, bits, op), times in grouped.items():
            avg = mean_excluding_first(times)
            row = [alg, bits, op] + [f"{t:.6f}" for t in times] + [f"{avg:.6f}"]
            w.writerow(row)
            table_rows.append([alg, bits, op, f"{avg:.6f}s"])

    print(f"[+] Symmetric cipher benchmark complete -> {file}")
    print_table(["Algorithm", "Key", "Op", "Avg Time"], table_rows)


# ======================== RSA ENCRYPTION BENCHMARK ========================

def bench_rsa_encryption():
    rows = []
    message = os.urandom(32)

    for sec in SECURITY_LEVELS:
        key_size = RSA_KEY_SIZES.get(sec)
        if not key_size:
            continue

        try:
            private_key = rsa.generate_private_key(public_exponent=65537, key_size=key_size)
        except:
            continue

        public_key = private_key.public_key()

        for i in range(N_RUNS):

            def do_encrypt():
                return public_key.encrypt(
                    message,
                    padding.OAEP(
                        mgf=padding.MGF1(hashes.SHA256()),
                        algorithm=hashes.SHA256(),
                        label=None
                    )
                )

            ct, t_enc = time_function(do_encrypt)

            def do_decrypt():
                return private_key.decrypt(
                    ct,
                    padding.OAEP(
                        mgf=padding.MGF1(hashes.SHA256()),
                        algorithm=hashes.SHA256(),
                        label=None
                    )
                )

            pt, t_dec = time_function(do_decrypt)
            assert pt == message

            rows.append(["RSA-OAEP", key_size, "encrypt", i+1, t_enc])
            rows.append(["RSA-OAEP", key_size, "decrypt", i+1, t_dec])

    file = OUT_DIR / "rsa_enc_results.csv"
    with file.open("w", newline="") as f:
        w = csv.writer(f)
        header = ["algorithm", "key_bits", "operation"] + [f"run_{i+1}" for i in range(N_RUNS)] + ["average_time"]
        w.writerow(header)

        from collections import defaultdict
        grouped = defaultdict(list)

        for alg, bits, op, run, t in rows:
            grouped[(alg, bits, op)].append(t)

        table_rows = []

        for (alg, bits, op), times in grouped.items():
            avg = mean_excluding_first(times)
            row = [alg, bits, op] + [f"{t:.6f}" for t in times] + [f"{avg:.6f}"]
            w.writerow(row)
            table_rows.append([alg, bits, op, f"{avg:.6f}s"])

    print(f"[+] RSA-OAEP benchmark complete -> {file}")
    print_table(["Algorithm", "Key", "Op", "Avg Time"], table_rows)


# ======================== SIGNATURE BENCHMARK ========================

def bench_signatures():
    rows = []
    message = os.urandom(128)

    for sec in SECURITY_LEVELS:
        rsa_size = RSA_KEY_SIZES.get(sec)
        if rsa_size:
            rsa_priv = rsa.generate_private_key(public_exponent=65537, key_size=rsa_size)
            rsa_pub = rsa_priv.public_key()

            for i in range(N_RUNS):
                sig, t_sign = time_function(
                    rsa_priv.sign,
                    message,
                    padding.PSS(
                        mgf=padding.MGF1(hashes.SHA256()),
                        salt_length=padding.PSS.MAX_LENGTH,
                    ),
                    hashes.SHA256()
                )

                _, t_verify = time_function(
                    rsa_pub.verify,
                    sig, message,
                    padding.PSS(
                        mgf=padding.MGF1(hashes.SHA256()),
                        salt_length=padding.PSS.MAX_LENGTH,
                    ),
                    hashes.SHA256()
                )

                rows.append(["RSA-PSS", rsa_size, "sign", i+1, t_sign])
                rows.append(["RSA-PSS", rsa_size, "verify", i+1, t_verify])

        dsa_size = DSA_KEY_SIZES.get(sec)
        if dsa_size:
            dsa_priv = dsa.generate_private_key(key_size=dsa_size)
            dsa_pub = dsa_priv.public_key()

            for i in range(N_RUNS):
                sig, t_sign = time_function(dsa_priv.sign, message, hashes.SHA256())
                _, t_verify = time_function(dsa_pub.verify, sig, message, hashes.SHA256())

                rows.append(["DSA", dsa_size, "sign", i+1, t_sign])
                rows.append(["DSA", dsa_size, "verify", i+1, t_verify])

        curve = ECC_CURVES.get(sec)
        if curve:
            ecc_priv = ec.generate_private_key(curve)
            ecc_pub = ecc_priv.public_key()

            for i in range(N_RUNS):
                sig, t_sign = time_function(ecc_priv.sign, message, ec.ECDSA(hashes.SHA256()))
                _, t_verify = time_function(ecc_pub.verify, sig, message, ec.ECDSA(hashes.SHA256()))

                rows.append(["ECDSA", curve.name, "sign", i+1, t_sign])
                rows.append(["ECDSA", curve.name, "verify", i+1, t_verify])

    file = OUT_DIR / "signature_results.csv"
    with file.open("w", newline="") as f:
        w = csv.writer(f)
        header = ["algorithm", "param", "operation"] + [f"run_{i+1}" for i in range(N_RUNS)] + ["average_time"]
        w.writerow(header)

        from collections import defaultdict
        grouped = defaultdict(list)

        for alg, param, op, run, t in rows:
            grouped[(alg, param, op)].append(t)

        table_rows = []

        for (alg, param, op), times in grouped.items():
            avg = mean_excluding_first(times)
            row = [alg, param, op] + [f"{t:.6f}" for t in times] + [f"{avg:.6f}"]
            w.writerow(row)
            table_rows.append([alg, param, op, f"{avg:.6f}s"])

    print(f"[+] Digital signature benchmark complete -> {file}")
    print_table(["Algorithm", "Parameter", "Op", "Avg Time"], table_rows)


# ======================== PLOTTING FUNCTIONS ========================

def load_csv(name):
    return pd.read_csv(OUT_DIR / name)

def save_fig(name):
    out = OUT_DIR / name
    plt.tight_layout()
    plt.savefig(out, dpi=300)
    plt.close()
    print(f"Saved plot to {out}")

def plot_keygen():
    df = load_csv("keygen_results.csv")
    df = df.dropna(subset=["average_time"])
    df["time_ms"] = df["average_time"] * 1000

    plt.figure()
    for alg in ["RSA", "DSA", "ECC"]:
        sub = df[df["algorithm"] == alg]
        if not sub.empty:
            plt.plot(sub["security_bits"], sub["time_ms"], marker="o", label=alg)

    plt.yscale("log")
    plt.xlabel("Security level (bits)")
    plt.ylabel("Time (ms) — log scale")
    plt.title("Key Pair Generation")
    plt.grid(True, which="both", linestyle="--")
    plt.legend()
    save_fig("plot_keygen.png")

def plot_symmetric():
    df = load_csv("symmetric_results.csv")
    df = df.dropna(subset=["average_time"])
    df["time_ms"] = df["average_time"] * 1000

    enc = df[df["operation"] == "encrypt"]
    plt.figure()
    for alg in enc["algorithm"].unique():
        sub = enc[enc["algorithm"] == alg]
        plt.plot(sub["key_bits"], sub["time_ms"], marker="o", label=alg)

    plt.xlabel("Key size (bits)")
    plt.ylabel("Time (ms)")
    plt.title("Symmetric Encryption (AES & ChaCha20)")
    plt.grid(True, linestyle="--")
    plt.legend()
    save_fig("plot_symmetric_enc.png")

    dec = df[df["operation"] == "decrypt"]
    plt.figure()
    for alg in dec["algorithm"].unique():
        sub = dec[dec["algorithm"] == alg]
        plt.plot(sub["key_bits"], sub["time_ms"], marker="o", label=alg)

    plt.xlabel("Key size (bits)")
    plt.ylabel("Time (ms)")
    plt.title("Symmetric Decryption (AES & ChaCha20)")
    plt.grid(True, linestyle="--")
    plt.legend()
    save_fig("plot_symmetric_dec.png")

def plot_rsa_enc():
    df = load_csv("rsa_enc_results.csv")
    df = df.dropna(subset=["average_time"])
    df["time_ms"] = df["average_time"] * 1000

    enc = df[df["operation"] == "encrypt"]
    dec = df[df["operation"] == "decrypt"]

    plt.figure()
    plt.plot(enc["key_bits"], enc["time_ms"], marker="o", label="Encrypt")
    plt.plot(dec["key_bits"], dec["time_ms"], marker="s", label="Decrypt")

    plt.xlabel("RSA key size (bits)")
    plt.ylabel("Time (ms)")
    plt.title("RSA Encryption & Decryption")
    plt.grid(True, linestyle="--")
    plt.legend()
    save_fig("plot_rsa_enc_dec.png")

def plot_signatures():
    df = load_csv("signature_results.csv")
    df = df.dropna(subset=["average_time"])
    df["time_ms"] = df["average_time"] * 1000

    df = df.sort_values(by=["algorithm", "param"])

    for op in ["sign", "verify"]:
        sub = df[df["operation"] == op]

        plt.figure()
        for alg in sub["algorithm"].unique():
            means = sub[sub["algorithm"] == alg]
            plt.plot(means["param"], means["time_ms"], marker="o", label=alg)

        plt.xlabel("Security level (param)")
        plt.ylabel("Time (ms)")
        plt.title(f"Digital Signatures — {op.capitalize()}")
        plt.grid(True, linestyle="--")
        plt.legend()
        save_fig(f"plot_signatures_{op}.png")


# ======================== MAIN ========================

def main():
    print("==== Key Generation Benchmarks ====")
    bench_keygen()

    print("\n==== Symmetric Cipher Benchmarks ====")
    bench_symmetric()

    print("\n==== RSA Encryption Benchmarks ====")
    bench_rsa_encryption()

    print("\n==== Digital Signature Benchmarks ====")
    bench_signatures()

    print("\n==== Benchmarking complete! Data saved to 'results/' ====\n")

    print("Generating plots...")
    plot_keygen()
    plot_symmetric()
    plot_rsa_enc()
    plot_signatures()
    print("All plots generated successfully!")


if __name__ == "__main__":
    main()

