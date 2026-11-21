# Music, effects, and beat sync

Read this when the brief says `Music: yes` or `SFX: yes`. The scout sources licensed audio, the designer detects beats offline and cuts to them, and QA checks the licence and the sync. Reels never carry a voice: no narration, no synthetic voice, no transcription.

## Source music and effects

Scout only. Use the Openverse API and nothing else:

- `GET https://api.openverse.org/v1/audio/?q=<mood terms>&license=cc0,pdm,by&category=music&page_size=20`; use `category=sound_effect` for effects.
- Keep results whose `duration` (in milliseconds) covers the reel. Make at most 10 requests. Never put personal data in a query.
- Download at most 3 music files and 5 effect files from `url` to `scout-refs/audio-01.<ext>` onward, each at most 15 MB.
- Licences `sa`, `nc`, and `nd` are never used, whatever the media policy says.
- If few permissive results appear, broaden the mood terms, then fall back to effects only or silence.

## Record the licence

In `scout.md`, add `## Audio candidates` with one row per file: Openverse `id`, `title`, `creator`, `license`, `license_version`, `license_url`, `foreign_landing_url`, `source`, duration in seconds, the `attribution` text verbatim as the credit line, the date read, and class `candidate-asset`. The main session resolves the class `stock-audio` and copies the allowed rows to `assets.md`. Openverse and provider tags do not exclude vocals. The user auditions the chosen track at the review gate; record the answer as `approvals.audioAudition` (`no vocals` or `has vocals`), and until it exists the no-voice part of QA check 8 is `limited` with the reason `vocals not auditioned`. A track with vocals is replaced or the piece goes effects-only. Prefer `cc0` when two candidates fit: a CC BY track re-uploaded by others can trigger a Content ID claim.

## Detect beats

Designer. Pick one allowed track and an excerpt offset, then convert the excerpt to mono WAV, which also fixes the time origin:

`ffmpeg -y -ss <offset> -t <duration> -i <track> -ac 1 -ar 22050 code/<piece>/audio/beats-input.wav`

Use the Python named in the tool preferences if it imports librosa. Otherwise create a venv with `py -3 -m venv code/.venv` (`python3` off Windows) and run `pip install "librosa>=1.0,<2"`. If that fails, retry with `py -3.12`. If both fail, use the fallback below. Save the script below as `code/<piece>/audio/beats.py` and run it with `beats.py <wav> out/<piece>/audio/beats.json --fps <n>`.

## Beat script

```python
import argparse, hashlib, json, sys

try:
    import librosa
    import numpy as np
except ImportError:
    sys.exit("librosa is not importable: no beat sync")

ap = argparse.ArgumentParser()
ap.add_argument("wav")
ap.add_argument("out")
ap.add_argument("--fps", type=int, required=True)
a = ap.parse_args()

try:
    y, sr = librosa.load(a.wav, sr=22050, mono=True)
except Exception as e:
    sys.exit("cannot read %s: %s" % (a.wav, e))
HOP = 256
env = librosa.onset.onset_strength(y=y, sr=sr, hop_length=HOP)
tempo, idx = librosa.beat.beat_track(onset_envelope=env, sr=sr, hop_length=HOP)
times = librosa.frames_to_time(idx, sr=sr, hop_length=HOP)
gaps = np.diff(times)
bpm = 60.0 / float(np.median(gaps)) if len(gaps) else float(np.atleast_1d(tempo)[0]) if len(idx) else 0.0
s = np.asarray(env, dtype=float)[idx] if len(idx) else np.zeros(0)
s = (s - s.min()) / (s.max() - s.min()) if len(s) and s.max() > s.min() else np.zeros(len(s))
beats = [{"i": n, "t": round(float(t), 3), "frame": int(round(round(float(t), 3) * a.fps)),
          "strength": round(float(v), 3)} for n, (t, v) in enumerate(zip(times, s))]
cut = float(np.percentile(s, 75)) if len(s) else 0.0
out = {
    "source": a.wav,
    "sha256": hashlib.sha256(open(a.wav, "rb").read()).hexdigest(),
    "sampleRate": int(sr),
    "fps": a.fps,
    "tempoBpm": round(bpm, 2),
    "beats": beats,
    "strong": [b["i"] for b in beats if b["strength"] >= cut],
    "librosa": librosa.__version__,
    "numpy": np.__version__,
}
with open(a.out, "w") as f:
    json.dump(out, f, sort_keys=True, indent=2)
```

## Use the beats

In a single-piece spec the Beats section are `##`; in a multi-piece spec each is `###` under the piece's heading (for example `## Reel` then `### Beats`). Add `## Beats` to the spec: `Event | Kind (cut, land, sfx) | Beat index | Time s | Frame | on-beat`. Put every scene cut and the hook landing on a beat frame, prefer `strong` beats for cuts, and mark each such event `on-beat`. Add each on-beat time to `## Checkpoints`. The tolerance is 1 frame.

## Mix and encode

Build one `filter_complex` from the original track with the same `-ss` offset as the analysis:

- `afade` in over 0.3 s and out over 0.8 s.
- Effects through `adelay`, combined with `amix=inputs=<n>:normalize=0`.
- Then `loudnorm=I=-14:TP=-1.5:LRA=11` and `aresample=48000`, written to `out/<piece>/audio/mix.wav`.

Encode as `video-pipeline.md` says with `-i out/<piece>/audio/mix.wav -c:a aac -b:a 192k -t <duration>`. Never add a voice.

## Fallback

If librosa is missing, no allowed track was found, or Openverse is unreachable, render silent or with effects only, write `Beats: none (<reason>)` in the spec, and report the gap. QA marks the sync part of check 8 `limited`.
