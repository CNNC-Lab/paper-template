#!/usr/bin/env python3
"""Generate the example figure used in sections/results.tex.

Regenerate with:  python3 scripts/make-example-figure.py
Produces figures/example-figure.pdf (a placeholder; replace with your own).
"""

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np

t = np.linspace(0, 1, 500)
fig, ax = plt.subplots(figsize=(4.2, 2.6))
for tau, label in [(0.05, r"$\tau=50$ ms"), (0.15, r"$\tau=150$ ms")]:
    ax.plot(t, np.exp(-t / tau), label=label, lw=1.8)
ax.set_xlabel("time (s)")
ax.set_ylabel("normalized response")
ax.legend(frameon=False, fontsize=8)
ax.spines[["top", "right"]].set_visible(False)
fig.tight_layout()

out = Path(__file__).resolve().parent.parent / "figures" / "example-figure.pdf"
fig.savefig(out)
print(f"wrote {out}")
