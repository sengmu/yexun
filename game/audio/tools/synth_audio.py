#!/usr/bin/env python3
"""Yexun Ch.1 audio synthesis — all sounds generated locally (numpy/scipy).
No copyrighted material, no downloads. Output: 22050 Hz mono 16-bit WAV,
matching the existing bell/drum/crackers/boom files.
Run: python3 synth_audio.py [out_dir]
"""
import sys
from pathlib import Path
import numpy as np
from scipy import signal
from scipy.io import wavfile

SR = 22050
rng = np.random.default_rng(20261116)
OUT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent


def save(name, x, peak=0.8):
    x = np.asarray(x, dtype=np.float64)
    m = np.max(np.abs(x)) if x.size else 0.0
    if m > 1e-9:
        x = x * (peak / m) if m > peak else x
    wavfile.write(OUT / name, SR, (np.clip(x, -1, 1) * 32767).astype(np.int16))
    print(f"{name}: {len(x)/SR:.2f}s peak={np.max(np.abs(x)):.3f}")


def t_of(dur):
    return np.arange(int(dur * SR)) / SR


def env_ad(dur, attack=0.005, tau=0.2):
    t = t_of(dur)
    e = np.exp(-np.maximum(t - attack, 0) / tau)
    e[t < attack] = t[t < attack] / max(attack, 1e-6)
    return e


def bp(x, lo, hi, order=3):
    sos = signal.butter(order, [lo, hi], btype="band", fs=SR, output="sos")
    return signal.sosfilt(sos, x)


def lp(x, f, order=3):
    sos = signal.butter(order, f, btype="low", fs=SR, output="sos")
    return signal.sosfilt(sos, x)


def hp(x, f, order=2):
    sos = signal.butter(order, f, btype="high", fs=SR, output="sos")
    return signal.sosfilt(sos, x)


def noise(dur):
    return rng.standard_normal(int(dur * SR))


def swept_band_noise(dur, f0, f1, width=0.6):
    """Noise through a bandpass whose centre sweeps f0->f1 (segmented OLA)."""
    n = int(dur * SR)
    x = rng.standard_normal(n + SR // 2)
    seg = SR // 20
    out = np.zeros(n + SR // 2)
    win = np.hanning(seg * 2)
    pos = 0
    i = 0
    while pos < n:
        frac = pos / max(n, 1)
        fc = f0 * (f1 / f0) ** frac
        lo = max(40.0, fc * (1 - width / 2))
        hi = min(SR / 2 - 100, fc * (1 + width / 2))
        chunk = x[pos:pos + seg * 2]
        if len(chunk) < seg:
            break
        out[pos:pos + len(chunk)] += bp(chunk, lo, hi) * win[:len(chunk)]
        pos += seg
        i += 1
    return out[:n]


def bell_tone(dur, f0, partials, gains, tau, gain=1.0, attack=0.004):
    t = t_of(dur)
    e = env_ad(dur, attack, tau)
    y = np.zeros_like(t)
    for p, g in zip(partials, gains):
        y += g * np.sin(2 * np.pi * f0 * p * t)
    return y * e * gain


def make_loop(x, loop_len, xf):
    """x must be >= loop_len+xf samples; wrap tail into head for a seamless loop."""
    y = x[:loop_len].copy()
    tail = x[loop_len:loop_len + xf]
    ramp = np.linspace(0.0, 1.0, xf)
    y[:xf] = y[:xf] * ramp + tail * (1.0 - ramp)
    return y


LOOP_S = 24.0
XF_S = 2.5

# ---------------------------------------------------------------- ambience: realm
def amb_realm():
    total = LOOP_S + XF_S
    n = int(total * SR)
    t = np.arange(n) / SR
    # rain body: filtered noise, slow swells
    rain = lp(noise(total), 900) * 1.6 + bp(noise(total), 2200, 5200) * 0.35
    swell = 0.75 + 0.25 * np.sin(2 * np.pi * 0.07 * t + 1.3) * np.sin(2 * np.pi * 0.043 * t)
    rain *= swell
    # sparse droplets: short sine pings
    drops = np.zeros(n)
    tt = 0.4
    while tt < total - 0.3:
        f = rng.uniform(1700, 3300)
        d = int(rng.uniform(0.05, 0.1) * SR)
        s = int(tt * SR)
        seg = np.sin(2 * np.pi * f * np.arange(d) / SR) * np.exp(-np.arange(d) / (0.018 * SR))
        drops[s:s + d] += seg * rng.uniform(0.05, 0.16)
        tt += rng.uniform(0.25, 1.4)
    # distant temple hum + very soft sparse bell strikes (no melody: two roots only)
    hum = 0.018 * np.sin(2 * np.pi * 98 * t) * (0.7 + 0.3 * np.sin(2 * np.pi * 0.09 * t))
    bells = np.zeros(n)
    for st, f0 in [(2.0, 196.0), (10.5, 147.0), (18.0, 196.0)]:
        s = int(st * SR)
        seg = bell_tone(6.0, f0, [1, 2.02, 2.74, 3.76], [0.5, 0.3, 0.18, 0.08], tau=2.2, gain=0.05)
        bells[s:s + len(seg)] += seg[:max(0, n - s)]
    # faint crowd murmur: band noise with syllabic AM
    mur = bp(noise(total), 380, 850)
    am = np.abs(lp(rng.standard_normal(n), 3.0))
    am /= (np.max(am) + 1e-9)
    mur *= am * 0.05
    y = rain * 0.5 + drops + hum + bells + mur
    return make_loop(y, int(LOOP_S * SR), int(XF_S * SR))


# ---------------------------------------------------------------- ambience: spirit
def amb_spirit():
    total = LOOP_S + XF_S
    n = int(total * SR)
    t = np.arange(n) / SR
    wind = lp(noise(total), 340) * 2.2
    swell = 0.55 + 0.45 * np.sin(2 * np.pi * 0.06 * t) * np.sin(2 * np.pi * 0.037 * t + 2.0)
    wind *= np.clip(swell, 0.05, 1.0)
    drone = (0.055 * np.sin(2 * np.pi * 55 * t) + 0.03 * np.sin(2 * np.pi * 82.5 * t)) \
        * (0.8 + 0.2 * np.sin(2 * np.pi * 0.11 * t))
    drips = np.zeros(n)
    tt = 0.8
    while tt < total - 1.2:
        f = rng.uniform(1300, 2100)
        for k, (dt, g) in enumerate([(0.0, 0.20), (0.37, 0.10), (0.74, 0.05)]):
            s = int((tt + dt) * SR)
            d = int(0.09 * SR)
            if s + d < n:
                seg = np.sin(2 * np.pi * f * np.arange(d) / SR) * np.exp(-np.arange(d) / (0.02 * SR))
                drips[s:s + d] += seg * g
        tt += rng.uniform(2.6, 5.2)
    y = wind * 0.42 + drone + drips
    return make_loop(y, int(LOOP_S * SR), int(XF_S * SR))


# ---------------------------------------------------------------- short FX
def fx_jump():
    dur = 0.4
    y = swept_band_noise(dur, 500, 2600, width=0.9)
    t = t_of(dur)
    e = np.sin(np.pi * np.clip(t / dur, 0, 1)) ** 1.5
    return y * e * 0.8


def fx_land():
    return bell_tone(0.6, 1568.0, [1, 1.335, 1.683, 2.0], [0.5, 0.32, 0.18, 0.1], tau=0.16, gain=0.5)


def fx_sticks():
    dur = 0.85
    y = np.zeros(int(dur * SR))
    for _ in range(15):
        s = int(rng.uniform(0, 0.42) * SR)
        d = int(rng.uniform(0.008, 0.02) * SR)
        click = bp(rng.standard_normal(d + 64), 2600, 4300)[:d] * np.exp(-np.arange(d) / (0.004 * SR))
        y[s:s + d] += click * rng.uniform(0.3, 0.8)
    s = int(0.52 * SR)
    d = int(0.05 * SR)
    clack = bp(rng.standard_normal(d + 64), 1500, 2600)[:d] * np.exp(-np.arange(d) / (0.012 * SR))
    y[s:s + d] += clack * 0.9
    tail = bp(noise(0.2), 3000, 5000) * np.exp(-t_of(0.2) / 0.05) * 0.2
    y[int(0.58 * SR):int(0.58 * SR) + len(tail)] += tail
    return y


def fx_candle():
    dur = 0.55
    y = swept_band_noise(dur, 2800, 420, width=1.1)
    t = t_of(dur)
    e = (1 - np.exp(-t / 0.03)) * np.exp(-t / 0.22)
    return y * e * 0.9 + 0.05 * np.sin(2 * np.pi * 200 * t) * e


def fx_lantern():
    dur = 0.95
    y = np.zeros(int(dur * SR))
    for st in [0.0, 0.09, 0.2]:
        s = int(st * SR)
        d = int(0.05 * SR)
        cr = hp(rng.standard_normal(d + 64), 4500)[:d] * np.exp(-np.arange(d) / (0.012 * SR))
        y[s:s + d] += cr * 0.35
    t = t_of(dur)
    glow = np.sin(2 * np.pi * (660 + 330 * np.clip((t - 0.15) / 0.5, 0, 1)) * t)
    ge = np.clip((t - 0.15) / 0.1, 0, 1) * np.exp(-np.maximum(t - 0.15, 0) / 0.45)
    y += glow * ge * (0.75 + 0.25 * np.sin(2 * np.pi * 12 * t)) * 0.10
    return y


def fx_flag():
    dur = 0.65
    t = t_of(dur)
    base = bp(noise(dur), 450, 950)
    flutter = (0.45 + 0.55 * np.abs(np.sin(2 * np.pi * 5.5 * t + 0.6 * np.sin(2 * np.pi * 1.7 * t))))
    e = np.clip(t / 0.03, 0, 1) * np.exp(-np.maximum(t - 0.1, 0) / 0.25)
    snap = bp(rng.standard_normal(int(0.03 * SR) + 64), 800, 3000)[:int(0.03 * SR)] * 0.8
    y = base * flutter * e * 0.9
    y[:len(snap)] += snap * np.exp(-np.arange(len(snap)) / (0.008 * SR))
    return y


def fx_loudspeaker():
    dur = 1.35
    t = t_of(dur)
    y = np.zeros(int(dur * SR))
    fb = np.sin(2 * np.pi * (1500 + 700 * np.clip(t / 0.28, 0, 1)) * t + 0.4 * np.sin(2 * np.pi * 27 * t))
    fe = np.clip(t / 0.02, 0, 1) * np.clip((0.3 - t) / 0.08, 0, 1)
    y += np.tanh(fb * 2.0) * fe * 0.13
    tt = t - 0.32
    voice = np.zeros_like(t)
    for h in range(1, 7):
        voice += (1.0 / h) * np.sin(2 * np.pi * 112 * h * t)
    voice = lp(bp(voice, 300, 1300) * 2.0, 1150)
    am = np.abs(lp(rng.standard_normal(len(t)), 4.0))
    am /= (np.max(am) + 1e-9)
    ve = np.clip(tt / 0.05, 0, 1) * np.exp(-np.maximum(tt - 0.1, 0) / 0.4)
    y += voice * am * ve * 0.5
    return y


def fx_horse():
    dur = 0.8
    y = np.zeros(int(dur * SR))
    for _ in range(22):
        s = int(rng.uniform(0, 0.38) * SR)
        d = int(rng.uniform(0.006, 0.016) * SR)
        cr = hp(rng.standard_normal(d + 64), 3800)[:d] * np.exp(-np.arange(d) / (0.003 * SR))
        y[s:s + d] += cr * rng.uniform(0.15, 0.45)
    t = t_of(dur)
    axle = np.sin(2 * np.pi * (235 - 85 * np.clip((t - 0.15) / 0.5, 0, 1)) * t)
    ae = np.clip((t - 0.15) / 0.05, 0, 1) * np.exp(-np.maximum(t - 0.2, 0) / 0.3)
    y += axle * ae * (0.7 + 0.3 * np.sin(2 * np.pi * 9 * t)) * 0.22
    return y


def fx_umbrella():
    dur = 0.6
    y = swept_band_noise(dur, 380, 1900, width=1.0)
    t = t_of(dur)
    e = np.clip(t / 0.16, 0, 1) ** 2 * np.exp(-np.maximum(t - 0.16, 0) / 0.16)
    y = y * e * 0.9
    for st in [0.17, 0.21, 0.26]:
        s = int(st * SR)
        d = int(0.015 * SR)
        click = bp(rng.standard_normal(d + 64), 2000, 3400)[:d] * np.exp(-np.arange(d) / (0.004 * SR))
        y[s:s + d] += click * 0.5
    return y


def fx_palanquin():
    dur = 1.05
    t = t_of(dur)
    bend = 150 - 45 * np.sin(np.pi * np.clip(t / 0.65, 0, 1)) + 25 * np.sin(2 * np.pi * np.clip(t / 0.65, 0, 1))
    creak = np.sin(2 * np.pi * bend * t + 0.5 * np.sin(2 * np.pi * 6.5 * t))
    ce = np.clip(t / 0.06, 0, 1) * np.exp(-np.maximum(t - 0.1, 0) / 0.35)
    rough = 0.75 + 0.25 * lp(rng.standard_normal(len(t)), 30.0) / (np.max(np.abs(lp(rng.standard_normal(len(t)), 30.0))) + 1e-9)
    y = creak * ce * rough * 0.30
    for st, f0, g in [(0.08, 1568.0, 0.20), (0.34, 1760.0, 0.16), (0.60, 1568.0, 0.13)]:
        s = int(st * SR)
        seg = bell_tone(0.4, f0, [1, 1.34, 1.68], [0.5, 0.3, 0.15], tau=0.11, gain=g)
        y[s:s + len(seg)] += seg[:max(0, len(y) - s)]
    return y


def fx_incense():
    dur = 0.9
    t = t_of(dur)
    hiss = hp(rng.standard_normal(int(0.22 * SR)), 6000) * np.exp(-t_of(0.22) / 0.07) * 0.12
    y = bell_tone(dur, 2093.0, [1, 1.415, 1.68, 2.12], [0.45, 0.28, 0.16, 0.08], tau=0.3, gain=0.4)
    y[:len(hiss)] += hiss
    return y


def fx_beam():
    dur = 0.9
    t = t_of(dur)
    sweep = np.sin(2 * np.pi * (315 - 125 * np.clip(t / 0.62, 0, 1)) * t + 0.7 * np.sin(2 * np.pi * 7 * t))
    roughn = lp(rng.standard_normal(len(t)), 24.0)
    roughn /= (np.max(np.abs(roughn)) + 1e-9)
    e = np.clip(t / 0.05, 0, 1) * np.exp(-np.maximum(t - 0.08, 0) / 0.34)
    y = sweep * (0.72 + 0.28 * roughn) * e * 0.5
    for st in [0.04, 0.44]:
        s = int(st * SR)
        d = int(0.07 * SR)
        knock = lp(rng.standard_normal(d + 64), 320)[:d] * np.exp(-np.arange(d) / (0.02 * SR))
        y[s:s + d] += knock * 0.7
    return y


def fx_fate():
    dur = 2.1
    t = t_of(dur)
    swell = (1 - np.cos(np.pi * np.clip(t / 0.75, 0, 1))) / 2
    dec = np.exp(-np.maximum(t - 0.75, 0) / 0.75)
    e = swell * dec
    y = np.zeros_like(t)
    for p, g in zip([1, 2.005, 3.01, 4.02, 5.34], [0.5, 0.34, 0.2, 0.11, 0.05]):
        y += g * np.sin(2 * np.pi * 98 * p * t)
    y *= e * 0.85
    shim = np.zeros_like(t)
    for p, g in zip([1, 1.5], [0.16, 0.08]):
        shim += g * np.sin(2 * np.pi * 1568 * p * t)
    y += shim * e * 0.5
    return y


def fx_rewind():
    dur = 1.15
    t = t_of(dur)
    siz = hp(rng.standard_normal(int(0.5 * SR)), 5500)
    crackle = 0.6 + 0.4 * (np.abs(lp(rng.standard_normal(int(0.5 * SR)), 900.0)) > 0.4)
    y = np.zeros(int(dur * SR))
    y[:len(siz)] += siz * crackle * np.exp(-t_of(0.5) / 0.3) * 0.16
    glide = np.sin(2 * np.pi * (880 - 700 * np.clip(t / 0.95, 0, 1)) * t)
    ge = np.clip(t / 0.04, 0, 1) * np.exp(-np.maximum(t - 0.1, 0) / 0.5)
    y += glide * ge * 0.22
    d = int(0.13 * SR)
    y[d:] += glide[:-d] * ge[:-d] * 0.08
    return y


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    save("amb_realm.wav", amb_realm(), peak=0.62)
    save("amb_spirit.wav", amb_spirit(), peak=0.62)
    save("jump.wav", fx_jump())
    save("land.wav", fx_land())
    save("sticks.wav", fx_sticks())
    save("candle.wav", fx_candle())
    save("lantern.wav", fx_lantern())
    save("flag.wav", fx_flag())
    save("loudspeaker.wav", fx_loudspeaker())
    save("horse.wav", fx_horse())
    save("umbrella.wav", fx_umbrella())
    save("palanquin.wav", fx_palanquin())
    save("incense.wav", fx_incense())
    save("beam.wav", fx_beam())
    save("fate.wav", fx_fate())
    save("rewind.wav", fx_rewind())
    print("done ->", OUT)
