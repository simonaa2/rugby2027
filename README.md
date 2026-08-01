# 🏉 2027 Rugby World Cup — Multifactor Synergy Model (v3.0)

[![Data Source: World Rugby API](https://img.shields.io/badge/Data_Source-World_Rugby_API-green.svg)](https://www.world.rugby/rankings)
[![License: MIT](https://img.shields.io/badge/License-MIT-gold.svg)](LICENSE)
[![Status: Live Dashboard](https://img.shields.io/badge/Dashboard-Firebase_Hosting-blue.svg)](https://maths-f3c6d.web.app/rugby.html)

A 6-factor sports analytics model quantifying **team synergy, squad depth, forward pack cohesion, and tactical alignment** across all 21 qualified nations for the 2027 Rugby World Cup in Australia.

Live Interactive Dashboard: **[https://maths-f3c6d.web.app/rugby.html](https://maths-f3c6d.web.app/rugby.html)**

---

## 📐 Mathematical Model & Formula

The Synergy Score $S \in [40, 95]$ is calculated using a weighted multi-dimensional linear index:

$$S = \left( T_i \cdot 0.15 + C_d \cdot 0.25 + F_p \cdot 0.20 + P_c \cdot 0.15 + T_s \cdot 0.10 + S_d \cdot 0.15 \right) \times 10$$

### Factors Breakdown

| Symbol | Factor Name | Weight | Description & Source |
|---|---|---|---|
| **$T_i$** | Individual Talent Baseline | **15%** | Competition tier of top 33 squad players (URC/Top14/Super Rugby = ~9; domestic = ~4). |
| **$C_d$** | Club Cohesion Index | **25%** | Herfindahl-Hirschman Index (HHI) of squad club concentration, weighted by franchise tier (Leinster $\times 1.00$; Japan League One $\times 0.55$). |
| **$F_p$** | Forward Pack Cohesion | **20%** | **Rugby-Unique.** Number of starting front 5 players (props, hooker, locks) playing for the same top-tier franchise. |
| **$P_c$** | Playing Combination Index | **15%** | National core XV stability + average starter test caps + Head Coach tenure modifier ($+1.5$ for $\ge 4$ yrs). |
| **$T_s$** | Tactical Style Cohesion | **10%** | Clarity & consistency of tactical execution (Set Piece, Running, Kicking, Physicality). |
| **$S_d$** | Squad Depth Index | **15%** | Quality drop-off between starters (1–15) and matchday bench (16–23) (e.g. South Africa's *Bomb Squad*). |

---

## 📊 Benchmark Metrics

- **World Rugby Official Ranking ($WR$):** Fetched directly from World Rugby REST API (`api.wr-rims-prod.pulselive.com`).
- **Top 10 Win % ($W_{10}$):** Test match win percentage vs Top 10 World Rugby ranked nations over the last 24 months.

---

## 📁 Repository Structure

```
rugby-synergy-model/
├── README.md               <- Model specification, formula & documentation
├── calc_rugby_synergy.R    <- R pipeline calculating v3.0 scores & outputting JSON
├── fp_data.csv             <- Front pack (props, hooker, locks) club registrations
├── rugby_teams.json        <- Exported dataset consumed by web frontend
└── rugby.html              <- Standalone web dashboard
```

---

## 🔬 Key Academic & Analytics Citations

1. **GAIN LINE Analytics (2023):** Team cohesion and shared experience account for up to 40% of on-field performance variance in international rugby union.
2. **McCarthy & Collins (2022):** *High Performance Sport:* Shared tactical understanding requires an average of 2.8 seasons of continuous elite competition.
3. **Swaab et al. (2014):** *Psychological Science:* "The Too-Much-Talent Effect" in interdependent sports — raw individual talent yields diminishing returns without structured team cohesion.

---

## 🚀 How to Reproduce & Run Locally

### Requirements
- R 4.0+
- R packages: `jsonlite`, `dplyr`

```bash
# Run calculation pipeline in R
Rscript calc_rugby_synergy.R
```

---

## 📜 License

MIT License — feel free to use, modify, and build upon this model for academic, broadcast, or analytical research.
