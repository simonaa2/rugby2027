# 🏉 2027 Rugby World Cup — Multifactor Synergy Model & Salary Arbitrage (v3.0)

[![Data Source: World Rugby API](https://img.shields.io/badge/Data_Source-World_Rugby_API-green.svg)](https://www.world.rugby/rankings)
[![License: MIT](https://img.shields.io/badge/License-MIT-gold.svg)](LICENSE)
[![Status: Live Dashboard](https://img.shields.io/badge/Dashboard-Firebase_Hosting-blue.svg)](https://maths-f3c6d.web.app/rugby.html)

A 6-factor sports analytics model quantifying **team synergy, squad depth, forward pack cohesion, and player economic migration** across all 21 qualified nations for the 2027 Rugby World Cup in Australia.

- Live Interactive Dashboard: **[https://maths-f3c6d.web.app/rugby.html](https://maths-f3c6d.web.app/rugby.html)**
- Live Salary & Migration Simulator: **[https://maths-f3c6d.web.app/salary.html](https://maths-f3c6d.web.app/salary.html)**

---

## 📊 Raw Open-Source CSV Datasets

All raw data powering the models and web applications is published transparently in the [`data/`](data/) directory:

| Dataset | CSV File Path | Description |
|---|---|---|
| 🏆 **Full Calculated Synergy Standings** | [`data/full_synergy_standings.csv`](data/full_synergy_standings.csv) | Final 6-factor synergy ratings, World Rugby rankings, points, and chemistry profiles for all 21 nations. |
| 👨‍💼 **Squad & Coaching Metadata** | [`data/squad_coaching_data.csv`](data/squad_coaching_data.csv) | Head coach names, tenure years, starter caps, combination status, tactical style categories, and depth scores. |
| 🏋️ **Front Pack Club Registrations** | [`data/fp_data_raw.csv`](data/fp_data_raw.csv) | Raw front row (loosehead, hooker, tighthead) and lock (second row) club registrations per nation. |
| 💱 **Nations Championship Match Fees** | [`data/nations_championship_match_fees.csv`](data/nations_championship_match_fees.csv) | Per-game Test match fee allowances and 12-match estimated test earnings across the 12 Nations Championship teams. |
| 💵 **Currency Arbitrage & PPP Index** | [`data/currency_exchange_arbitrage.csv`](data/currency_exchange_arbitrage.csv) | Exchange rates (ZAR, NZD, AUD, FJD vs GBP, EUR, JPY) and Purchasing Power Parity (PPP) cost-of-living indices. |
| 📋 **Player-Level Roster Database** | [`data/player_database.csv`](data/player_database.csv) | Detailed tight five rosters (props, hookers, locks) containing actual names, clubs, caps, and starter vs. rotation roles for Tier 1 nations. |

---

## 🧬 Roster Redundancy & Workload Rotation Hypothesis ($H_1$)

Modern rugby union's high physical contact load makes **workload management** a critical predictor of soft-tissue injuries and late-tournament performance decay. This model integrates principles of **Roster Redundancy** from baseball sabermetrics (such as *Wins Above Replacement* [WAR] and backup plate appearance value) to analyze squad performance:

### The Hypothesis ($H_1$):
$$\text{Knockout Performance Decay} \propto \frac{T_i}{\text{Roster Redundancy} \cdot S_d}$$

> *"Nations with a flat talent distribution between starting and backup Tight Five players (high Squad Depth $S_d$) experience fewer soft-tissue injuries and lower late-tournament performance decay compared to nations with high starting-XV talent but steep drop-offs to their reserves (high starting talent $T_i$ but low depth $S_d$)."*

### Sabermetric & Sports Medicine Proof:
1. **Acute:Chronic Workload Ratio (Gabbett, 2016):** When a starting player's weekly load exceeds 1.5x their historical chronic average due to lack of squad rotation (thin depth), their injury probability increases by 300%.
2. **Replacement-Level Redundancy:** Teams like South Africa (the **Bomb Squad** profile) maintain high redundancy by roster-sharing (e.g. Nché/Kitshoff/Steenekamp at loosehead; Malherbe/Koch/du Toit at tighthead). When a starter rests, the replacement WAR drop-off is near zero, allowing workload caps of ~1,400 minutes/year.
3. **The "Too-Much-Talent" Constraint:** High starting talent $T_i$ without backup redundancy (e.g., Ireland's reliance on Sheehan/Porter/Furlong) leads to late-stage tournament fatigue, as seen in RWC Quarter-Final execution errors.

---

## 📐 Mathematical Model & Formula (v3.0)

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

## 📁 Repository Structure

```
rugby2027/
├── README.md                                 <- Model specification & dataset index
├── calc_rugby_synergy.R                      <- R pipeline calculating v3.0 scores & outputting JSON/CSVs
├── fp_data.csv                               <- Front pack (props, hooker, locks) club registrations
├── rugby_teams.json                          <- Exported dataset consumed by web frontend
├── rugby.html                                <- Interactive Rugby Synergy Dashboard
├── salary.html                               <- Interactive Salary Arbitrage & Player Migration Simulator
└── data/
    ├── full_synergy_standings.csv            <- Final 6-factor ratings & rankings (CSV)
    ├── squad_coaching_data.csv               <- Coaching tenure, starter caps & tactical styles (CSV)
    ├── fp_data_raw.csv                       <- Front row/lock club registration raw data (CSV)
    ├── nations_championship_match_fees.csv   <- Test match fee comparison table (CSV)
    ├── currency_exchange_arbitrage.csv       <- Exchange rates & purchasing power indices (CSV)
    └── player_database.csv                   <- Player-level rosters, clubs, and caps (CSV)
```

---

## 🔬 Key Academic & Analytics Citations

1. **GAIN LINE Analytics (2023):** Team cohesion and shared experience account for up to 40% of on-field performance variance in international rugby union.
2. **McCarthy & Collins (2022):** *High Performance Sport:* Shared tactical understanding requires an average of 2.8 seasons of continuous elite competition.
3. **DataTrends Research:** *$195,000 Median Salary Tipping Point in South African Rugby Labor Migration* (DataTrends.com.au).
4. **Swaab et al. (2014):** *Psychological Science:* "The Too-Much-Talent Effect" in interdependent sports — raw individual talent yields diminishing returns without structured team cohesion.
5. **Gabbett (2016):** *British Journal of Sports Medicine:* The training-injury prevention paradox: should players be training smarter and harder? (Acute:chronic workload ratio).

---

## 🚀 How to Reproduce & Run Locally

### Requirements
- R 4.0+
- R packages: `jsonlite`, `dplyr`

```bash
# Run calculation pipeline in R to generate JSON and CSV datasets
Rscript calc_rugby_synergy.R
```

---

## 📜 License

MIT License — feel free to use, modify, and build upon this model for academic, broadcast, or analytical research.
