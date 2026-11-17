#!/usr/bin/env python3
"""Yexun Ch.2-6 audio synthesis — debt clearance, same local synth grammar as
synth_audio.py (Ch.1). No copyrighted material, no downloads, no voice lines
(crowd layers are unintelligible murmur textures only).
Output: 22050 Hz mono 16-bit WAV. Ambience loops 24.0s seamless (peak 0.62),
FX peak 0.8 unless a softer design peak is noted per file.
Run: python3 synth_audio_ch2_6.py [out_dir]
"""
import sys
from pathlib import Path
import numpy as np
from scipy import signal
from scipy.io import wavfile

SR = 22050
rng = np.random.default_rng(20261117)
OUT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent

def save(name, x, peak=0.8):
    x = np.asarray(x, dtype=np.float64)
    m = np.max(np.abs(x)) if x.size else 0.0
    if m > 1e-9 and m > peak:
        x = x * (peak / m)
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

def bell_tone(dur, f0, partials, gains, tau, gain=1.0, attack=0.004):
    t = t_of(dur)
    e = env_ad(dur, attack, tau)
    y = np.zeros_like(t)
    for p, g in zip(partials, gains):
        y += g * np.sin(2 * np.pi * f0 * p * t)
    return y * e * gain

def gong_tone(dur, f0, tau=0.55, gain=1.0, attack=0.003, bright=3000.0):
    """Gong: inharmonic partials with detuned beating pairs + strike burst."""
    t = t_of(dur)
    e = env_ad(dur, attack, tau)
    y = np.zeros_like(t)
    for p, g in zip([1.0, 1.483, 2.086, 2.936, 3.421, 4.18],
                    [0.42, 0.30, 0.24, 0.16, 0.10, 0.06]):
        y += g * np.sin(2 * np.pi * f0 * p * t)
        y += g * 0.55 * np.sin(2 * np.pi * f0 * p * 1.004 * t)  # shimmer pair
    burst = bp(noise(0.06), 700, bright) * np.exp(-t_of(0.06) / 0.012) * 0.5
    y[:len(burst)] += burst
    return y * e * gain

def drum_hit(dur, f_hi=170.0, f_lo=68.0, tau=0.22, gain=1.0):
    t = t_of(dur)
    f = f_lo + (f_hi - f_lo) * np.exp(-t / 0.05)
    ph = np.cumsum(f) / SR * 2 * np.pi
    e = env_ad(dur, 0.004, tau)
    thump = lp(noise(0.05), 500) * np.exp(-t_of(0.05) / 0.015) * 0.6
    y = np.sin(ph) * e * gain
    y[:len(thump)] += thump * gain
    return y

def wood_knock(dur=0.25, f0=620.0, tau=0.05, gain=1.0, band=(800, 1600)):
    t = t_of(dur)
    body = np.sin(2 * np.pi * f0 * t) * np.exp(-t / tau)
    skin = bp(noise(dur), band[0], band[1]) * np.exp(-t / (tau * 0.6))
    return (body * 0.7 + skin * 0.5) * gain

def murmur(dur, lo, hi, gain, seed_off=0.0):
    """Unintelligible crowd texture: band noise with slow syllabic AM.
    No formant melody, no words — atmosphere only."""
    n = int(dur * SR)
    x = bp(rng.standard_normal(n), lo, hi)
    am = np.abs(lp(rng.standard_normal(n), 2.6 + seed_off))
    am /= (np.max(am) + 1e-9)
    am2 = np.abs(lp(rng.standard_normal(n), 0.7))
    am2 /= (np.max(am2) + 1e-9)
    return x * (0.35 + 0.65 * am) * am2 * gain

def make_loop(x, loop_len, xf):
    y = x[:loop_len].copy()
    tail = x[loop_len:loop_len + xf]
    ramp = np.linspace(0.0, 1.0, xf)
    y[:xf] = y[:xf] * ramp + tail * (1.0 - ramp)
    return y

LOOP_S = 24.0
XF_S = 2.5

def rain_layer(total, body_f=900, amt=0.5, drops=True):
    n = int(total * SR)
    t = np.arange(n) / SR
    rain = lp(noise(total), body_f) * 1.6 + bp(noise(total), 2200, 5200) * 0.35
    swell = 0.75 + 0.25 * np.sin(2 * np.pi * 0.07 * t + 1.3) * np.sin(2 * np.pi * 0.043 * t)
    y = rain * swell * amt
    if drops:
        d = np.zeros(n)
        tt = 0.4
        while tt < total - 0.3:
            f = rng.uniform(1700, 3300)
            ln = int(rng.uniform(0.05, 0.1) * SR)
            s = int(tt * SR)
            seg = np.sin(2 * np.pi * f * np.arange(ln) / SR) * np.exp(-np.arange(ln) / (0.018 * SR))
            d[s:s + ln] += seg * rng.uniform(0.05, 0.16)
            tt += rng.uniform(0.25, 1.4)
        y = y + d
    return y

def spirit_base(total, wind_f=340):
    n = int(total * SR)
    t = np.arange(n) / SR
    wind = lp(noise(total), wind_f) * 2.2
    swell = 0.55 + 0.45 * np.sin(2 * np.pi * 0.06 * t) * np.sin(2 * np.pi * 0.037 * t + 2.0)
    wind *= np.clip(swell, 0.05, 1.0)
    drone = (0.055 * np.sin(2 * np.pi * 55 * t) + 0.03 * np.sin(2 * np.pi * 82.5 * t)) \
        * (0.8 + 0.2 * np.sin(2 * np.pi * 0.11 * t))
    return wind * 0.42 + drone

def drip_seq(total, f_lo=1300, f_hi=2100, gap=(2.6, 5.2), gain=0.2):
    n = int(total * SR)
    y = np.zeros(n)
    tt = 0.8
    while tt < total - 1.2:
        f = rng.uniform(f_lo, f_hi)
        for dt, g in [(0.0, 1.0), (0.37, 0.5), (0.74, 0.25)]:
            s = int((tt + dt) * SR)
            ln = int(0.09 * SR)
            if s + ln < n:
                seg = np.sin(2 * np.pi * f * np.arange(ln) / SR) * np.exp(-np.arange(ln) / (0.02 * SR))
                y[s:s + ln] += seg * g * gain
        tt += rng.uniform(*gap)
    return y

# ================================================================ CH2
def fx_gong():
    return gong_tone(1.8, 220.0, tau=0.55, gain=0.9)

def amb2_realm():
    total = LOOP_S + XF_S
    n = int(total * SR)
    y = rain_layer(total, amt=0.42)
    # far procession crowd: two unintelligible murmur layers + shuffle steps
    y += murmur(total, 300, 720, 0.085, 0.3)
    y += murmur(total, 520, 1150, 0.05, 1.1)
    steps = bp(noise(total), 300, 700)
    sam = np.abs(lp(rng.standard_normal(n), 1.8)); sam /= (np.max(sam) + 1e-9)
    y += steps * sam * 0.03
    # distant procession drum/gong, faint and periodic (texture, not cues)
    for st in [3.0, 7.2, 11.4, 15.6, 19.8, 24.0]:
        s = int(st * SR)
        seg = lp(drum_hit(0.5, 150, 70, tau=0.18, gain=0.05), 400)
        y[s:s + len(seg)] += seg[:max(0, n - s)]
    for st in [5.2, 17.0]:
        s = int(st * SR)
        seg = lp(gong_tone(1.6, 220.0, tau=0.6, gain=0.035), 900)
        y[s:s + len(seg)] += seg[:max(0, n - s)]
    return make_loop(y, int(LOOP_S * SR), int(XF_S * SR))

def amb2_spirit():
    total = LOOP_S + XF_S
    y = spirit_base(total)
    y += drip_seq(total)
    y += murmur(total, 280, 620, 0.022, 0.5)  # ghost of the crowd, far and muffled
    n = int(total * SR)
    for st in [6.0, 19.0]:
        s = int(st * SR)
        seg = lp(gong_tone(2.0, 196.0, tau=0.9, gain=0.03), 700)
        y[s:s + len(seg)] += seg[:max(0, n - s)]
    return make_loop(y, int(LOOP_S * SR), int(XF_S * SR))

# ================================================================ CH3
def leak_clock(total, period=3.0, gain=0.10):
    """Genglou water-clock: regular resonant drip + faint wooden tick."""
    n = int(total * SR)
    y = np.zeros(n)
    tt = 1.0
    while tt < total - 0.5:
        s = int(tt * SR)
        ln = int(0.14 * SR)
        seg = np.sin(2 * np.pi * 1180 * np.arange(ln) / SR) * np.exp(-np.arange(ln) / (0.03 * SR))
        seg += 0.4 * np.sin(2 * np.pi * 1770 * np.arange(ln) / SR) * np.exp(-np.arange(ln) / (0.02 * SR))
        y[s:s + ln] += seg * gain
        tk = wood_knock(0.08, 900, 0.02, gain * 0.35)
        s2 = s + int(0.16 * SR)
        y[s2:s2 + len(tk)] += tk[:max(0, n - s2)]
        tt += period
    return y

def amb3_realm():
    total = LOOP_S + XF_S
    n = int(total * SR)
    t = np.arange(n) / SR
    # indoor: rain muffled to a roof patter, room tone, incense pops
    y = lp(noise(total), 480) * 0.55 * (0.8 + 0.2 * np.sin(2 * np.pi * 0.05 * t))
    y += 0.012 * np.sin(2 * np.pi * 72 * t)
    y += leak_clock(total, 3.0, 0.085)
    pops = np.zeros(n)
    tt = 0.7
    while tt < total - 0.2:
        s = int(tt * SR)
        ln = int(rng.uniform(0.01, 0.03) * SR)
        pops[s:s + ln] += hp(rng.standard_normal(ln + 64), 5000)[:ln] * rng.uniform(0.02, 0.06)
        tt += rng.uniform(0.5, 2.2)
    y += pops
    for st, f0 in [(8.0, 147.0), (21.0, 196.0)]:
        s = int(st * SR)
        seg = bell_tone(6.0, f0, [1, 2.02, 2.74, 3.76], [0.5, 0.3, 0.18, 0.08], tau=2.4, gain=0.035)
        y[s:s + len(seg)] += seg[:max(0, n - s)]
    return make_loop(y, int(LOOP_S * SR), int(XF_S * SR))

def amb3_spirit():
    total = LOOP_S + XF_S
    y = spirit_base(total, wind_f=260) * 0.85
    y += leak_clock(total, 3.6, 0.06)
    y += drip_seq(total, gap=(3.4, 6.0), gain=0.13)
    return make_loop(y, int(LOOP_S * SR), int(XF_S * SR))

def amb3_store():
    total = LOOP_S + XF_S
    n = int(total * SR)
    # dark storeroom: dust-still air, paper-friction rustle bed, wood creaks
    y = lp(noise(total), 300) * 0.35
    rustle = bp(noise(total), 1300, 3600)
    ram = np.abs(lp(rng.standard_normal(n), 0.9)); ram /= (np.max(ram) + 1e-9)
    gate = (ram > 0.45).astype(np.float64)
    gate = lp(gate, 6.0); gate /= (np.max(gate) + 1e-9)
    y += rustle * gate * 0.055
    fine = hp(noise(total), 4200) * 0.012
    y += fine * (0.5 + 0.5 * np.sin(2 * np.pi * 0.11 * np.arange(n) / SR))
    for st, f0 in [(4.5, 130.0), (13.0, 105.0), (20.5, 150.0)]:
        s = int(st * SR)
        ln = int(0.5 * SR)
        tt = np.arange(ln) / SR
        creak = np.sin(2 * np.pi * (f0 + 18 * np.sin(2 * np.pi * 3 * tt)) * tt) \
            * np.exp(-tt / 0.18) * 0.028
        y[s:s + ln] += creak[:max(0, n - s)]
    y += drip_seq(total, gap=(4.5, 7.5), gain=0.07)
    return make_loop(y, int(LOOP_S * SR), int(XF_S * SR))

# ================================================================ CH4
def amb4_realm():
    total = LOOP_S + XF_S
    n = int(total * SR)
    t = np.arange(n) / SR
    # river: broadband water body with slow surges + bank lapping
    water = bp(noise(total), 300, 1400) * 0.5 + lp(noise(total), 500) * 0.7
    surge = 0.7 + 0.3 * np.sin(2 * np.pi * 0.09 * t + 0.7) * np.sin(2 * np.pi * 0.031 * t)
    y = water * surge * 0.4
    lap = lp(noise(total), 700)
    lam = (0.5 + 0.5 * np.sin(2 * np.pi * 0.45 * t)) ** 3
    y += lap * lam * 0.10
    y += rain_layer(total, body_f=700, amt=0.16, drops=False)
    # distant oar strokes: dip + creak, sparse
    tt = 2.0
    while tt < total - 1.0:
        s = int(tt * SR)
        ln = int(0.3 * SR)
        dip = bp(rng.standard_normal(ln + 64), 500, 1500)[:ln] * np.exp(-np.arange(ln) / (0.07 * SR)) * 0.05
        y[s:s + ln] += dip[:max(0, n - s)]
        tt += rng.uniform(3.5, 6.5)
    return make_loop(y, int(LOOP_S * SR), int(XF_S * SR))

def amb4_spirit():
    total = LOOP_S + XF_S
    n = int(total * SR)
    t = np.arange(n) / SR
    y = spirit_base(total, wind_f=300)
    water = bp(noise(total), 240, 900) * (0.6 + 0.4 * np.sin(2 * np.pi * 0.05 * t))
    y += water * 0.16
    y += drip_seq(total, gap=(3.0, 5.5), gain=0.15)
    return make_loop(y, int(LOOP_S * SR), int(XF_S * SR))

def fx_shrine():
    dur = 0.9
    y = bell_tone(dur, 1568.0, [1, 1.34, 1.68], [0.4, 0.25, 0.12], tau=0.2, gain=0.35)
    hiss = hp(noise(0.22), 6000) * np.exp(-t_of(0.22) / 0.06) * 0.10
    y[:len(hiss)] += hiss
    knock = wood_knock(0.2, 300, 0.06, 0.4, band=(300, 700))
    y[:len(knock)] += knock * 0.5
    return y

def fx_bridgebell():
    dur = 1.4
    y = bell_tone(dur, 880.0, [1, 2.02, 2.74, 3.76, 5.4], [0.5, 0.3, 0.18, 0.08, 0.04], tau=0.5, gain=0.75)
    t = t_of(0.35)
    creak = lp(noise(0.35), 300) * np.exp(-t / 0.12) * 0.12
    y[:len(creak)] += creak
    return y

def fx_bridgerope():
    dur = 1.0
    t = t_of(dur)
    f = 95 + 45 * np.clip(t / 0.6, 0, 1) + 12 * np.sin(2 * np.pi * 7 * t)
    creak = np.sin(2 * np.pi * f * t) * np.clip(t / 0.05, 0, 1) * np.exp(-np.maximum(t - 0.1, 0) / 0.4)
    rough = lp(rng.standard_normal(len(t)), 40.0); rough /= (np.max(np.abs(rough)) + 1e-9)
    y = creak * (0.7 + 0.3 * rough) * 0.5
    for st in [0.22, 0.47, 0.63]:
        s = int(st * SR)
        ln = int(0.03 * SR)
        snap = bp(rng.standard_normal(ln + 64), 1800, 3200)[:ln] * np.exp(-np.arange(ln) / (0.006 * SR)) * 0.35
        y[s:s + ln] += snap[:max(0, len(y) - s)]
    return y

def fx_sedanrope():
    dur = 0.9
    t = t_of(dur)
    y = wood_knock(0.3, 210, 0.09, 0.55, band=(250, 600))
    f = 160 - 40 * np.clip(t / 0.5, 0, 1)
    creak = np.sin(2 * np.pi * f * t + 0.4 * np.sin(2 * np.pi * 5 * t)) \
        * np.clip((t - 0.08) / 0.05, 0, 1) * np.exp(-np.maximum(t - 0.12, 0) / 0.3) * 0.22
    y = np.pad(y, (0, len(t) - len(y))) + creak
    sq = bp(noise(0.3), 600, 950) * np.exp(-t_of(0.3) / 0.1) * 0.08
    y[:len(sq)] += sq
    return y

def fx_papercargo():
    dur = 1.1
    y = np.zeros(int(dur * SR))
    for st, ln_s, g in [(0.0, 0.28, 0.5), (0.2, 0.34, 0.65), (0.48, 0.3, 0.45), (0.72, 0.26, 0.35)]:
        s = int(st * SR)
        ln = int(ln_s * SR)
        seg = bp(rng.standard_normal(ln + 64), 1500, 4600)[:ln]
        env = np.sin(np.pi * np.arange(ln) / ln) ** 1.5
        y[s:s + ln] += seg * env * g * 0.5
    return y

def fx_riverlamp():
    dur = 0.95
    y = bell_tone(dur, 2093.0, [1, 1.5, 2.1], [0.3, 0.16, 0.07], tau=0.25, gain=0.4)
    whoosh = bp(noise(0.5), 420, 950) * np.clip(t_of(0.5) / 0.08, 0, 1) * np.exp(-t_of(0.5) / 0.2) * 0.16
    s = int(0.1 * SR)
    y[s:s + len(whoosh)] += whoosh[:max(0, len(y) - s)]
    for st in [0.02, 0.07]:
        ss = int(st * SR)
        ln = int(0.02 * SR)
        click = hp(rng.standard_normal(ln + 64), 4200)[:ln] * np.exp(-np.arange(ln) / (0.004 * SR)) * 0.3
        y[ss:ss + ln] += click[:max(0, len(y) - ss)]
    return y

def fx_boat():
    dur = 1.3
    t = t_of(dur)
    lap = lp(noise(dur), 650) * (0.5 + 0.5 * np.sin(2 * np.pi * 1.4 * t)) * 0.22
    y = lap
    s = int(0.25 * SR)
    ln = int(0.35 * SR)
    dip = bp(rng.standard_normal(ln + 64), 480, 1400)[:ln] * np.sin(np.pi * np.arange(ln) / ln) * 0.4
    y[s:s + ln] += dip[:max(0, len(y) - s)]
    knock = wood_knock(0.25, 240, 0.08, 0.5, band=(220, 550))
    s2 = int(0.62 * SR)
    y[s2:s2 + len(knock)] += knock[:max(0, len(y) - s2)]
    return y

def fx_borrowmouth():
    """Paper-friction pseudo-syllables: segmented band noise with wandering
    formant centre — cadence of speech, no words, nothing intelligible."""
    dur = 1.7
    y = np.zeros(int(dur * SR))
    bursts = [(0.05, 0.16, 760), (0.27, 0.11, 1050), (0.44, 0.19, 640),
              (0.72, 0.13, 920), (0.92, 0.22, 560), (1.24, 0.15, 830), (1.45, 0.18, 690)]
    for st, ln_s, fc in bursts:
        s = int(st * SR)
        ln = int(ln_s * SR)
        seg = bp(rng.standard_normal(ln + 64), fc * 0.75, fc * 1.5)[:ln]
        env = np.sin(np.pi * np.arange(ln) / ln) ** 1.2
        y[s:s + ln] += seg * env * 0.55
        tt = np.arange(ln) / SR
        glide = np.sin(2 * np.pi * (fc * 0.5 + 60 * np.sin(2 * np.pi * 3 * tt)) * tt) * env * 0.05
        y[s:s + ln] += glide[:max(0, len(y) - s)]
    # papery body underneath + a breath of wet mist
    body = bp(noise(dur), 900, 3000) * 0.05 * (0.6 + 0.4 * np.sin(2 * np.pi * 2.2 * t_of(dur)))
    y += body
    # cheap paper-room: two short feedback echoes
    for d_s, g in [(0.09, 0.12), (0.19, 0.06)]:
        d = int(d_s * SR)
        y[d:] += y[:-d] * g
    return y

def fx_answer_bell():
    return bell_tone(2.0, 784.0, [1, 2.02, 2.74, 3.76], [0.5, 0.3, 0.17, 0.07], tau=0.95, gain=0.62, attack=0.01)

def fx_answer_gong():
    return gong_tone(2.4, 196.0, tau=1.1, gain=0.55, attack=0.012)

def fx_answer_drum():
    return drum_hit(1.6, 150.0, 62.0, tau=0.62, gain=0.6)

# ================================================================ CH5
def fx_everlamp():
    dur = 1.0
    t = t_of(dur)
    flick = bp(noise(dur), 480, 1250) * (0.65 + 0.35 * np.sin(2 * np.pi * 9 * t + 1.2 * np.sin(2 * np.pi * 2.3 * t))) * 0.10
    e = np.clip(t / 0.06, 0, 1) * np.exp(-np.maximum(t - 0.1, 0) / 0.35)
    y = flick * e * 3.0
    ring = bell_tone(dur, 2349.0, [1, 1.5], [0.2, 0.08], tau=0.3, gain=0.14)
    pop = hp(rng.standard_normal(int(0.02 * SR) + 64), 5500)[:int(0.02 * SR)] * 0.12
    s = int(0.3 * SR)
    y = y + ring
    y[s:s + len(pop)] += pop[:max(0, len(y) - s)]
    return y

def fx_oilpot():
    dur = 1.0
    y = np.zeros(int(dur * SR))
    for st, f0, g in [(0.0, 2637.0, 0.30), (0.075, 2093.0, 0.22)]:
        s = int(st * SR)
        seg = bell_tone(0.35, f0, [1, 1.42, 1.9], [0.5, 0.26, 0.1], tau=0.1, gain=g)
        y[s:s + len(seg)] += seg[:max(0, len(y) - s)]
    s = int(0.3 * SR)
    ln = int(0.45 * SR)
    tt = np.arange(ln) / SR
    pour = bp(rng.standard_normal(ln + 64), 2100, 3600)[:ln] * (0.6 + 0.4 * np.sin(2 * np.pi * 6 * tt)) \
        * np.sin(np.pi * np.arange(ln) / ln) * 0.16
    y[s:s + ln] += pour[:max(0, len(y) - s)]
    return y

def fx_porridge():
    dur = 1.2
    n = int(dur * SR)
    y = lp(noise(dur), 420) * 0.20
    tt = 0.05
    while tt < dur - 0.15:
        s = int(tt * SR)
        ln = int(0.07 * SR)
        f = rng.uniform(240, 420)
        seg = np.sin(2 * np.pi * (f - 120 * np.arange(ln) / ln) * np.arange(ln) / SR) \
            * np.sin(np.pi * np.arange(ln) / ln) * rng.uniform(0.06, 0.14)
        y[s:s + ln] += seg[:max(0, n - s)]
        tt += rng.uniform(0.06, 0.2)
    s = int(0.55 * SR)
    ln = int(0.3 * SR)
    scrape = bp(rng.standard_normal(ln + 64), 900, 2400)[:ln] * np.sin(np.pi * np.arange(ln) / ln) * 0.12
    y[s:s + ln] += scrape[:max(0, n - s)]
    steam = hp(noise(0.4), 5000) * np.exp(-t_of(0.4) / 0.15) * 0.05
    y[:len(steam)] += steam
    return y

def fx_kueh():
    dur = 0.8
    y = bell_tone(dur, 1976.0, [1, 1.42, 1.9], [0.4, 0.2, 0.08], tau=0.16, gain=0.4)
    for st, g in [(0.18, 0.30), (0.34, 0.24), (0.5, 0.18)]:
        s = int(st * SR)
        ln = int(0.09 * SR)
        tt = np.arange(ln) / SR
        thud = np.sin(2 * np.pi * (210 - 90 * tt / 0.09) * tt) * np.exp(-tt / 0.03) * g
        y[s:s + ln] += thud[:max(0, len(y) - s)]
    return y

def fx_bang():
    """Watchman's clapper: one knock, a breath, two knocks (slow-fast)."""
    dur = 1.15
    y = np.zeros(int(dur * SR))
    for st, g in [(0.0, 0.85), (0.52, 0.7), (0.72, 0.8)]:
        s = int(st * SR)
        seg = wood_knock(0.3, 590, 0.045, g, band=(850, 1500))
        y[s:s + len(seg)] += seg[:max(0, len(y) - s)]
    return y

def fx_waitstill():
    dur = 1.5
    t = t_of(dur)
    sink = np.sin(2 * np.pi * (300 - 120 * np.clip(t / 1.0, 0, 1)) * t) \
        * np.clip(t / 0.1, 0, 1) * np.exp(-np.maximum(t - 0.15, 0) / 0.5) * 0.20
    shim = bell_tone(dur, 523.0, [1, 2.76], [0.3, 0.12], tau=0.7, gain=0.3, attack=0.03)
    shim *= (0.75 + 0.25 * np.sin(2 * np.pi * 4.5 * t))
    mist = lp(noise(dur), 500) * np.sin(np.pi * np.clip(t / dur, 0, 1)) * 0.12
    return sink + shim + mist

def fx_trade():
    """Solemn report-as-price: soft drum root, long bell, gong swell entering late."""
    dur = 2.6
    y = drum_hit(dur, 130.0, 55.0, tau=0.9, gain=0.4)
    bell = bell_tone(dur, 784.0, [1, 2.02, 2.74, 3.76], [0.5, 0.3, 0.17, 0.07], tau=1.15, gain=0.5, attack=0.012)
    y += bell
    s = int(0.35 * SR)
    g = gong_tone(2.1, 196.0, tau=1.2, gain=0.4, attack=0.05)
    y[s:s + len(g)] += g[:max(0, len(y) - s)]
    root = np.sin(2 * np.pi * 98 * t_of(dur)) * np.clip(t_of(dur) / 0.4, 0, 1) \
        * np.exp(-np.maximum(t_of(dur) - 0.4, 0) / 0.9) * 0.12
    return y + root

def fx_yieldcue():
    dur = 1.4
    t = t_of(dur)
    n = len(t)
    # fog parting: band centre opens upward, then settles
    seg_len = SR // 20
    src = rng.standard_normal(n + SR // 2)
    out = np.zeros(n + SR // 2)
    win = np.hanning(seg_len * 2)
    pos = 0
    while pos < n:
        frac = pos / max(n, 1)
        fc = 320 * (1150 / 320) ** min(frac * 1.6, 1.0)
        chunk = src[pos:pos + seg_len * 2]
        if len(chunk) < seg_len:
            break
        out[pos:pos + len(chunk)] += bp(chunk, max(60.0, fc * 0.7), fc * 1.4) * win[:len(chunk)]
        pos += seg_len
    part = out[:n] * np.sin(np.pi * np.clip(t / dur, 0, 1)) * 0.20
    bell = bell_tone(dur, 784.0, [1, 2.02, 2.74], [0.4, 0.22, 0.1], tau=0.8, gain=0.3, attack=0.02)
    s = int(0.45 * SR)
    y = part
    y[s:s + len(bell)] += bell[:max(0, n - s)] * 0  # placeholder replaced below
    y = part.copy()
    seg = bell_tone(dur - 0.45, 784.0, [1, 2.02, 2.74], [0.4, 0.22, 0.1], tau=0.8, gain=0.3, attack=0.02)
    y[s:s + len(seg)] += seg[:max(0, n - s)]
    return y

def candle_pops(total, gain=0.05, gap=(0.8, 3.0)):
    n = int(total * SR)
    y = np.zeros(n)
    tt = 0.9
    while tt < total - 0.3:
        s = int(tt * SR)
        ln = int(rng.uniform(0.008, 0.025) * SR)
        y[s:s + ln] += hp(rng.standard_normal(ln + 64), 5200)[:ln] * rng.uniform(0.4, 1.0) * gain
        tt += rng.uniform(*gap)
    return y

def watch_knocks(total, gain=0.05):
    n = int(total * SR)
    y = np.zeros(n)
    for base in [5.0, 17.5]:
        for k, dt in enumerate([0.0, 0.55, 0.78]):
            s = int((base + dt) * SR)
            seg = wood_knock(0.25, 590, 0.05, gain * (1.0 if k == 0 else 0.8), band=(850, 1500))
            y[s:s + len(seg)] += seg[:max(0, n - s)]
    return y

def amb5_realm():
    total = LOOP_S + XF_S
    n = int(total * SR)
    t = np.arange(n) / SR
    # after-rain night: eave drips, faint wind, candle pops, distant watch
    y = lp(noise(total), 420) * 0.30 * (0.8 + 0.2 * np.sin(2 * np.pi * 0.04 * t))
    y += drip_seq(total, gap=(1.8, 3.6), gain=0.10)
    y += candle_pops(total, 0.045)
    y += watch_knocks(total, 0.05)
    y += 0.010 * np.sin(2 * np.pi * 98 * t) * (0.7 + 0.3 * np.sin(2 * np.pi * 0.07 * t))
    return make_loop(y, int(LOOP_S * SR), int(XF_S * SR))

def amb5_spirit():
    total = LOOP_S + XF_S
    y = spirit_base(total, wind_f=300) * 0.9
    y += candle_pops(total, 0.028, gap=(1.6, 4.2))
    y += watch_knocks(total, 0.026)
    y += drip_seq(total, gap=(3.2, 5.8), gain=0.12)
    return make_loop(y, int(LOOP_S * SR), int(XF_S * SR))

# ================================================================ CH6
def fx_deepgong():
    """Deep-wave gong: low root, slow beating waves, long swell-decay."""
    dur = 3.0
    t = t_of(dur)
    y = np.zeros_like(t)
    e = np.clip(t / 0.01, 0, 1) * np.exp(-np.maximum(t - 0.01, 0) / 1.35)
    for p, g in zip([1.0, 1.504, 2.0, 2.44, 3.36], [0.46, 0.3, 0.22, 0.13, 0.07]):
        y += g * np.sin(2 * np.pi * 82.4 * p * t)
        y += g * 0.7 * np.sin(2 * np.pi * 82.4 * p * 1.0022 * t)  # slow wave beating
    burst = lp(noise(0.05), 420) * np.exp(-t_of(0.05) / 0.014) * 0.5
    y[:len(burst)] += burst
    return y * e * 0.95

def fx_sugong():
    """Su gong: pitch bends upward after the strike, bright and vocal."""
    dur = 2.2
    t = t_of(dur)
    f0 = 300 + 85 * (1 - np.exp(-t / 0.35))
    y = np.zeros_like(t)
    for p, g in zip([1.0, 1.49, 2.1, 2.98, 3.9], [0.4, 0.28, 0.2, 0.11, 0.05]):
        ph = np.cumsum(f0 * p) / SR * 2 * np.pi
        y += g * np.sin(ph)
        y += g * 0.5 * np.sin(ph * 1.004)
    e = env_ad(dur, 0.004, 0.8)
    burst = bp(noise(0.05), 900, 3800) * np.exp(-t_of(0.05) / 0.01) * 0.4
    y[:len(burst)] += burst
    return y * e * 0.9

def suona_phrase(dur=2.4, gain=1.0):
    """Original ceremonial call: three rising reed notes, last held with
    vibrato. Generic intervals only — not any existing tune."""
    notes = [(0.0, 0.42, 587.3), (0.46, 0.42, 698.5), (0.92, 1.4, 880.0)]
    y = np.zeros(int(dur * SR))
    for st, ln_s, f0 in notes:
        s = int(st * SR)
        ln = int(ln_s * SR)
        tt = np.arange(ln) / SR
        vib = 1 + 0.006 * np.sin(2 * np.pi * 5.5 * tt) * np.clip(tt / 0.25, 0, 1)
        ph = np.cumsum(f0 * vib) / SR * 2 * np.pi
        tone = np.zeros(ln)
        for h in range(1, 9):
            tone += (1.0 / h ** 0.7) * np.sin(ph * h)
        tone = bp(tone, 500, 4200)
        env = np.clip(tt / 0.03, 0, 1) * np.exp(-np.maximum(tt - ln_s + 0.25, 0) / 0.18) \
            * np.clip((ln_s - tt) / 0.06, 0, 1) ** 0.3
        breath = bp(rng.standard_normal(ln + 64), 1000, 3000)[:ln] * 0.05
        y[s:s + ln] += (tone * 0.5 + breath) * env * gain
    return y

def fx_suona():
    return suona_phrase(2.4, 1.0)

def fx_templebell():
    dur = 1.6
    y = bell_tone(dur, 1047.0, [1, 2.02, 2.74, 3.76], [0.5, 0.3, 0.17, 0.07], tau=0.7, gain=0.7)
    s = int(0.52 * SR)
    seg = bell_tone(1.0, 1047.0, [1, 2.02, 2.74], [0.4, 0.22, 0.1], tau=0.6, gain=0.22)
    y[s:s + len(seg)] += seg[:max(0, len(y) - s)]
    return y

def fx_doorring_rust():
    dur = 0.7
    y = wood_knock(0.3, 260, 0.07, 0.6, band=(240, 600))
    ln = int(0.16 * SR)
    squeak = bp(rng.standard_normal(ln + 64), 2400, 3900)[:ln] * np.sin(np.pi * np.arange(ln) / ln) * 0.10
    s = int(0.05 * SR)
    y = np.pad(y, (0, int(dur * SR) - len(y)))
    y[s:s + ln] += squeak[:max(0, len(y) - s)]
    ring = bell_tone(0.5, 1568.0, [1, 1.34], [0.3, 0.14], tau=0.13, gain=0.22)
    y[:len(ring)] += ring
    return y

def fx_doorring_clear():
    dur = 0.9
    y = wood_knock(0.3, 300, 0.06, 0.55, band=(280, 650))
    y = np.pad(y, (0, int(dur * SR) - len(y)))
    ring = bell_tone(dur, 1760.0, [1, 1.34, 1.68], [0.45, 0.24, 0.1], tau=0.42, gain=0.5)
    y += ring
    s = int(0.3 * SR)
    seg = bell_tone(0.5, 1760.0, [1, 1.34], [0.35, 0.16], tau=0.35, gain=0.2)
    y[s:s + len(seg)] += seg[:max(0, len(y) - s)]
    return y

def fx_sign():
    dur = 1.2
    t = t_of(dur)
    y = wood_knock(0.25, 700, 0.04, 0.5, band=(1000, 1700))
    y = np.pad(y, (0, int(dur * SR) - len(y)))
    shim = np.sin(2 * np.pi * 3136 * t) * (0.7 + 0.3 * np.sin(2 * np.pi * 3.2 * t)) \
        * np.clip((t - 0.1) / 0.2, 0, 1) * np.exp(-np.maximum(t - 0.15, 0) / 0.4) * 0.05
    mist = bp(noise(dur), 2000, 4200) * np.sin(np.pi * np.clip(t / dur, 0, 1)) * 0.05
    return y + shim + mist

def small_gong(dur, f0, tau, gain):
    return gong_tone(dur, f0, tau=tau, gain=gain, bright=2600.0)

def report_pattern(full=True):
    """Chaozhou-style luogu pattern, original arrangement: drum drives,
    gongs punctuate; full set adds deep/su gongs, sedan bell and suona."""
    dur = 7.5 if full else 4.6
    y = np.zeros(int(dur * SR))
    def add(seg, st, g=1.0):
        s = int(st * SR)
        y[s:s + len(seg)] += seg[:max(0, len(y) - s)] * g
    # drum drive: accelerating then steady cadence (original pattern)
    beats = [0.0, 0.5, 1.0, 1.38, 1.76, 2.14, 2.52, 2.9, 3.28, 3.66, 4.04, 4.42, 4.8, 5.3, 5.9] if full \
        else [0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5]
    for b in beats:
        if b < dur - 0.3:
            add(drum_hit(0.55, 175, 70, tau=0.2, gain=0.55), b)
    for b in ([0.5, 1.76, 2.9, 4.04, 5.3] if full else [0.5, 1.5, 2.5, 3.5]):
        add(gong_tone(1.4, 220.0, tau=0.5, gain=0.4), b)
    # sedan bell shakes on off-beats
    for b in ([0.25, 1.25, 2.4, 3.5, 4.7, 5.7] if full else [0.25, 1.25, 2.25, 3.25]):
        add(bell_tone(0.5, 1568.0, [1, 1.34, 1.68], [0.4, 0.22, 0.1], tau=0.14, gain=0.16), b)
    if full:
        add(fx_deepgong(), 1.0, 0.55)
        add(fx_deepgong(), 4.42, 0.6)
        add(fx_sugong(), 2.14, 0.5)
        add(fx_sugong(), 5.3, 0.55)
        add(small_gong(0.8, 392.0, 0.25, 0.22), 1.38)   # dou gong colour
        add(small_gong(0.7, 523.0, 0.2, 0.18), 3.28)    # qin-zi colour
        add(suona_phrase(2.6, 0.85), 3.4)
    return y

def amb6_alley():
    total = LOOP_S + XF_S
    n = int(total * SR)
    t = np.arange(n) / SR
    # narrow-alley wind: band centre wanders, gusts funnelled
    seg_len = SR // 10
    src = rng.standard_normal(n + SR)
    out = np.zeros(n + SR)
    win = np.hanning(seg_len * 2)
    pos = 0
    while pos < n:
        tt = pos / SR
        fc = 480 + 260 * np.sin(2 * np.pi * 0.045 * tt + 1.0) + 120 * np.sin(2 * np.pi * 0.13 * tt)
        chunk = src[pos:pos + seg_len * 2]
        if len(chunk) < seg_len:
            break
        out[pos:pos + len(chunk)] += bp(chunk, max(80.0, fc * 0.62), fc * 1.55) * win[:len(chunk)]
        pos += seg_len
    y = out[:n] * 0.30
    y += drip_seq(total, gap=(1.4, 3.0), gain=0.13)
    y += murmur(total, 300, 650, 0.016, 0.9)
    for st in [9.0, 21.5]:
        s = int(st * SR)
        seg = lp(gong_tone(1.8, 220.0, tau=0.7, gain=0.028), 800)
        y[s:s + len(seg)] += seg[:max(0, n - s)]
    return make_loop(y, int(LOOP_S * SR), int(XF_S * SR))

def amb6_dawn():
    total = LOOP_S + XF_S
    n = int(total * SR)
    t = np.arange(n) / SR
    y = lp(noise(total), 380) * 0.22 * (0.8 + 0.2 * np.sin(2 * np.pi * 0.03 * t))
    y += drip_seq(total, gap=(3.5, 6.5), gain=0.07)
    # first birds: sparse soft sine chirps, each a short falling/rising glide
    chirps = np.zeros(n)
    tt = 2.5
    while tt < total - 1.0:
        f0 = rng.uniform(2300, 3100)
        f1 = f0 * rng.uniform(0.78, 1.25)
        ln = int(rng.uniform(0.09, 0.2) * SR)
        s = int(tt * SR)
        tt2 = np.arange(ln) / SR
        f = f0 + (f1 - f0) * (tt2 / (ln / SR))
        ph = np.cumsum(f) / SR * 2 * np.pi
        seg = np.sin(ph) * np.sin(np.pi * np.arange(ln) / ln) * rng.uniform(0.02, 0.045)
        chirps[s:s + ln] += seg[:max(0, n - s)]
        if rng.random() < 0.5:  # answering double-chirp
            s2 = s + ln + int(0.14 * SR)
            if s2 + ln < n:
                chirps[s2:s2 + ln] += seg * 0.7
        tt += rng.uniform(2.2, 5.0)
    y += chirps
    s = int(14.0 * SR)
    seg = bell_tone(6.0, 147.0, [1, 2.02, 2.74], [0.5, 0.28, 0.14], tau=2.6, gain=0.03)
    y[s:s + len(seg)] += seg[:max(0, n - s)]
    return make_loop(y, int(LOOP_S * SR), int(XF_S * SR))

if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    # CH2
    save("gong.wav", fx_gong())
    save("amb2_realm.wav", amb2_realm(), peak=0.62)
    save("amb2_spirit.wav", amb2_spirit(), peak=0.62)
    # CH3
    save("amb3_realm.wav", amb3_realm(), peak=0.62)
    save("amb3_spirit.wav", amb3_spirit(), peak=0.62)
    save("amb3_store.wav", amb3_store(), peak=0.62)
    # CH4
    save("amb4_realm.wav", amb4_realm(), peak=0.62)
    save("amb4_spirit.wav", amb4_spirit(), peak=0.62)
    save("shrine.wav", fx_shrine())
    save("bridgebell.wav", fx_bridgebell())
    save("bridgerope.wav", fx_bridgerope())
    save("sedanrope.wav", fx_sedanrope())
    save("papercargo.wav", fx_papercargo())
    save("riverlamp.wav", fx_riverlamp())
    save("boat.wav", fx_boat())
    save("borrowmouth.wav", fx_borrowmouth())
    save("answer_bell.wav", fx_answer_bell(), peak=0.62)
    save("answer_gong.wav", fx_answer_gong(), peak=0.62)
    save("answer_drum.wav", fx_answer_drum(), peak=0.62)
    # CH5
    save("amb5_realm.wav", amb5_realm(), peak=0.62)
    save("amb5_spirit.wav", amb5_spirit(), peak=0.62)
    save("everlamp.wav", fx_everlamp())
    save("oilpot.wav", fx_oilpot())
    save("porridge.wav", fx_porridge())
    save("kueh.wav", fx_kueh())
    save("bang.wav", fx_bang())
    save("waitstill.wav", fx_waitstill(), peak=0.55)
    save("trade.wav", fx_trade(), peak=0.7)
    save("yieldcue.wav", fx_yieldcue(), peak=0.6)
    # CH6
    save("deepgong.wav", fx_deepgong(), peak=0.85)
    save("sugong.wav", fx_sugong(), peak=0.85)
    save("suona.wav", fx_suona(), peak=0.85)
    save("templebell.wav", fx_templebell())
    save("doorring_rust.wav", fx_doorring_rust())
    save("doorring_clear.wav", fx_doorring_clear())
    save("sign.wav", fx_sign(), peak=0.6)
    save("report_half.wav", report_pattern(full=False), peak=0.8)
    save("report_full.wav", report_pattern(full=True), peak=0.85)
    save("amb6_alley.wav", amb6_alley(), peak=0.62)
    save("amb6_dawn.wav", amb6_dawn(), peak=0.62)
    print("done ->", OUT)
