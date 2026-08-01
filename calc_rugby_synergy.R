# ============================================================
# calc_rugby_synergy.R  —  RWC 2027 Rugby Union Synergy Model v3.0
# Formula: S = (Ti×0.15 + Cd×0.25 + Fp×0.20 + Pc×0.15 + Ts×0.10 + Sd×0.15) × 10
# 6 Factors:
#   Ti: Individual Talent Baseline
#   Cd: Club / Franchise Cohesion Index
#   Fp: Forward Pack Cohesion (Rugby-unique set piece unit)
#   Pc: Playing Combination Index (National XV stability + Caps + Coaching)
#   Ts: Tactical Style Cohesion (Style clarity + category)
#   Sd: Squad Depth Index (23-man matchday bench quality & drop-off)
# Benchmark:
#   win_pct_top10: Win % vs Top 10 Nations (last 24 months)
# ============================================================

library(jsonlite)
library(dplyr)

OUT_DIR <- "C:/Users/simon/.gemini/antigravity/scratch/personal-qualities-audit/rugby_pipeline"

cat("=======================================================\n")
cat("  RUGBY UNION MULTIFACTOR SYNERGY MODEL v3.0 — RWC 2027\n")
cat("=======================================================\n\n")

# ── 1. WORLD RUGBY RANKINGS ─────────────────────────────────
cat("⏳ Fetching World Rugby official rankings...\n")
wr_ranks <- tryCatch({
  d <- fromJSON("https://api.wr-rims-prod.pulselive.com/rugby/v3/rankings/mru?language=en")
  entries <- d[["entries"]]
  teams   <- entries[["team"]]
  data.frame(
    team    = unlist(teams[["name"]]),
    wr_rank = as.integer(unlist(entries[["pos"]])),
    wr_pts  = as.numeric(unlist(entries[["pts"]])),
    stringsAsFactors = FALSE
  )
}, error = function(e) {
  cat("  ⚠️  WR API unavailable — using fallback\n")
  data.frame(
    team=c("South Africa","New Zealand","Ireland","France","England",
           "Scotland","Argentina","Australia","Fiji","Japan","Wales",
           "Italy","Georgia","USA","Portugal","Chile","Spain","Uruguay",
           "Tonga","Romania","Canada"),
    wr_rank=1:21, wr_pts=seq(94,55, length.out=21), stringsAsFactors=FALSE)
})
cat(sprintf("  ✅ WR rankings fetched — %d teams\n\n", nrow(wr_ranks)))

# ── 2. FRONT PACK DATA (Fp) ─────────────────────────────────
cat("⏳ Loading front pack data...\n")
fp_raw <- read.csv(file.path(OUT_DIR, "fp_data.csv"), stringsAsFactors = FALSE)

club_tier <- function(club) {
  top    <- c("Leinster","Munster","Ulster","Connacht",
              "Toulouse","La Rochelle","Bordeaux","Montpellier","Clermont",
              "Stade Francais","Toulon","Castres","Racing 92","Lyon","Pau","Agen",
              "Saracens","Leicester","Harlequins","Exeter","Bristol","Northampton",
              "Bath","Sale Sharks","Gloucester",
              "Crusaders","Blues","Chiefs","Hurricanes","Highlanders",
              "Brumbies","Waratahs","Reds","Western Force","Moana Pasifika",
              "Bulls","Stormers","Sharks","Lions","Cheetahs",
              "Edinburgh","Glasgow","Cardiff","Ospreys","Scarlets","Dragons",
              "Zebre","Benetton","Llanelli","Connacht")
  mid    <- c("Toyota","Kubota","NTT","Suntory","Honda Heat","Panasonic","Kobelco",
              "Old Glory DC","Seattle Seawolves","New England Free Jacks",
              "NOLA Gold","Chicago Hounds","Toronto Arrows","Anthem RC",
              "San Diego Legion","RFC Los Angeles","California Legion",
              "Stade Aurillac","Pro D2","Divisao de Honra","Bath")
  if (club %in% top) return(1.00)
  if (club %in% mid) return(0.55)
  return(0.30)
}

fp_score_raw <- function(p1, p2, p3, l1, l2) {
  clubs <- c(p1, p2, p3, l1, l2)
  clubs <- clubs[clubs != "" & !is.na(clubs)]
  if (length(clubs) == 0) return(list(score=2.0, dominant="Unknown", max_same=1))
  tbl <- sort(table(clubs), decreasing = TRUE)
  max_same <- as.integer(tbl[1])
  dom_club <- names(tbl)[1]
  raw <- c("1"=2.0,"2"=4.5,"3"=6.5,"4"=8.0,"5"=10.0)[as.character(min(max_same, 5))]
  list(score=as.numeric(raw), dominant=dom_club, max_same=max_same)
}

fp_df <- fp_raw %>% rowwise() %>% mutate(
  fp_info      = list(fp_score_raw(prop_L, hooker, prop_R, lock1, lock2)),
  fp_raw_score = fp_info$score,
  dominant_club = fp_info$dominant,
  fp_max_same  = fp_info$max_same,
  tier_mult    = club_tier(dominant_club),
  Fp           = round(pmax(2.0, fp_raw_score * tier_mult + 2.0 * (1 - tier_mult)), 2),
  fp_display   = paste0(dominant_club, " (", fp_max_same, "/5)  ×", tier_mult)
) %>% ungroup() %>% select(-fp_info)

# ── 3. SQUAD DATA v3.0 (Ti, Cd, Pc, Ts, Sd, Win Rate) ────────
squad_data_v3 <- data.frame(stringsAsFactors = FALSE,
  team = c(
    "South Africa","New Zealand","Ireland","France","England",
    "Scotland","Argentina","Australia","Fiji","Japan","Wales",
    "Italy","Georgia","USA","Portugal","Chile","Spain","Uruguay",
    "Tonga","Romania","Canada"
  ),
  Ti = c(
    9.8, 9.7, 9.5, 9.6, 9.4,
    8.8, 8.5, 8.3, 7.8, 7.5, 7.8,
    7.5, 6.5, 5.5, 5.5, 4.5, 4.5,
    4.8, 5.5, 4.2, 4.0
  ),
  Cd = c(
    5.8, 4.5, 8.5, 7.2, 5.0,
    5.5, 3.8, 4.8, 4.5, 5.5, 6.5,
    5.8, 4.2, 3.5, 3.8, 3.2, 4.0,
    5.0, 4.8, 4.5, 3.8
  ),
  avg_starter_caps = c(
    74, 62, 68, 56, 52,
    58, 64, 48, 42, 44, 38,
    36, 45, 32, 28, 22, 20,
    30, 35, 38, 24
  ),
  coach_name = c(
    "Rassie Erasmus","Dave Rennie","Andy Farrell","Fabien Galthié","Steve Borthwick",
    "Gregor Townsend","Felipe Contepomi","Joe Schmidt","Mick Byrne","Eddie Jones","Steve Tandy",
    "Gonzalo Quesada","Richard Cockerill","Scott Lawrence","Simon Mannix","Pablo Lemoine","Pablo Bouza",
    "Rodolfo Ambrosio","Tevita Tu'ifua","David Gérard","Kingsley Jones"
  ),
  coach_tenure_yrs = c(
    8.0, 0.5, 6.0, 6.0, 3.5,
    9.0, 2.0, 2.5, 2.0, 3.0, 1.0,
    2.5, 2.5, 2.5, 2.0, 6.0, 2.0,
    2.0, 2.0, 2.0, 7.0
  ),
  combination_status = c(
    "World Cup Champion Core (3+ yrs)","New World Cup Cycle Rebuild","Settled 6-Nations Champion Core","Settled Grand Slam Core","Rebuilt Post-2023 Unit",
    "Long-standing Core","Post-Cheika Transition","Schmidt Rebuilding Phase","Pacific Hybrid Combination","Eddie Jones Young Squad","Gatland Major Rebuild",
    "Quesada Evolving Unit","Set-Piece Heavy Core","MLR Hybrid Unit","European Professional Core","Super Rugby Americas Core","División de Honor Core",
    "Domestic Core Unit","Pacific Veteran Core","Eastern European Pack Unit","MLR Native Squad"
  ),
  style_category = c(
    "Set Piece & Bomb Squad","Running & Width","Set Piece & Lineout Drive","Expansive & Unpredictable","Kicking & Field Position",
    "Fast Attacking & Loose-Ball","Physicality & Breakdown","Kicking & Counter-Attack","Unstructured Running Rugby","High-Tempo & Passing",
    "Developing Direct Game","High-Tempo & Counter","Set Piece Warriors","Direct MLR Physicality","Fast & Offloading","URBA Direct Physicality",
    "Developing Identity","Physical Breakdown Game","Direct Pacific Power","Set Piece & Maul","Developing Identity"
  ),
  style_icon = c(
    "🛡️","⚡","🎯","🔥","👟",
    "💨","💥","👟","🏃","⚡",
    "🌱","💨","🛡️","💥","💨","💥",
    "🌱","💥","💥","🛡️","🌱"
  ),
  ts_score_raw = c(
    9.5, 8.8, 9.6, 8.8, 7.2,
    7.8, 8.2, 6.2, 8.0, 7.5, 5.8,
    6.8, 9.0, 5.5, 6.5, 6.0, 4.8,
    6.2, 6.5, 7.2, 4.5
  ),
  # --- NEW v3.0: Squad Depth Index (Sd) ---
  # Bench quality (players 16-23) & 23-man matchday drop-off
  Sd = c(
    9.8, # South Africa: Legendary Bomb Squad (unmatched 23-man depth)
    8.5, # New Zealand: Super Rugby franchise depth
    8.2, # Ireland: Leinster/Munster depth, slight tighthead prop gap
    9.2, # France: Massive Top 14 depth across 23
    7.8, # England: Solid Premiership bench
    6.8, # Scotland: Edinburgh/Glasgow depth thinner
    7.2, # Argentina: European pro bench depth
    6.5, # Australia: Rebuilding Brumbies/Reds depth
    6.2, # Fiji: Moana Pasifika / Top 14 bench
    6.0, # Japan: Japan League One bench
    5.5, # Wales: Regional depth challenges
    6.2, # Italy: Benetton/Zebre bench
    5.8, # Georgia: Pro D2 forward bench
    4.2, # USA: MLR bench
    4.8, # Portugal: European bench
    3.5, # Chile: Local amateur/semi-pro bench
    3.8, # Spain: División de Honor bench
    4.5, # Uruguay: Peñarol bench
    5.2, # Tonga: Pacific veteran bench
    4.0, # Romania: Domestic bench
    3.8  # Canada: MLR depth limited
  ),
  # --- NEW v3.0: Win % vs Top 10 Nations (last 24 months) ---
  win_pct_top10 = c(
    82, # South Africa
    72, # New Zealand
    80, # Ireland
    75, # France
    52, # England
    55, # Scotland
    50, # Argentina
    42, # Australia
    35, # Fiji
    30, # Japan
    25, # Wales
    40, # Italy
    20, # Georgia
    5,  # USA
    15, # Portugal
    0,  # Chile
    5,  # Spain
    10, # Uruguay
    10, # Tonga
    5,  # Romania
    0   # Canada
  ),
  n_players = c(
    480, 510, 520, 495, 490,
    360, 380, 420, 280, 290, 370,
    340, 180, 170, 140, 120, 90,
    100, 110, 95, 80
  ),
  data_source = "research_compiled_v3"
)

# Calculate Pc composite score
squad_data_v3 <- squad_data_v3 %>%
  rowwise() %>%
  mutate(
    caps_score = min(10.0, max(2.0, (avg_starter_caps / 75.0) * 10.0)),
    coach_mod  = if (coach_tenure_yrs >= 4.0) 1.5 else if (coach_tenure_yrs >= 2.0) 0.5 else -1.0,
    base_comb  = if (grepl("3\\+|Settled|Long-standing", combination_status)) 9.0 else if (grepl("Core|Transition|Evolving", combination_status)) 7.0 else 5.0,
    Pc         = round(min(10.0, max(2.0, (base_comb * 0.5 + caps_score * 0.3 + 5.0 * 0.2) + coach_mod)), 2),
    Ts         = round(ts_score_raw, 2)
  ) %>%
  ungroup()

# ── 4. MERGE & CALCULATE SYNERGY v3.0 ────────────────────────
cat("\n⏳ Merging and calculating v3.0 synergy scores...\n")

all_data <- squad_data_v3 %>%
  left_join(fp_df %>% select(team, Fp, dominant_club, fp_display, fp_max_same), by="team") %>%
  left_join(wr_ranks %>% select(team, wr_rank, wr_pts), by="team")

all_data$Fp[is.na(all_data$Fp)] <- 2.0
all_data$dominant_club[is.na(all_data$dominant_club)] <- "Domestic clubs"

classify_profile <- function(Cd, Fp, Ti, Pc, Sd) {
  if (Sd >= 9.0 & Fp >= 4.5)    return("Bomb Squad Depth")
  if (Cd >= 6.5 & Fp >= 6.0)   return("Franchise Fortress")
  if (Cd < 5.0 & Ti >= 8.0)    return("Distributed Elite")
  if (Pc >= 7.8)               return("Cap-Rich Veterans")
  return("Rising Challenger")
}

# Formula v3.0: S = (Ti×0.15 + Cd×0.25 + Fp×0.20 + Pc×0.15 + Ts×0.10 + Sd×0.15) × 10
all_data <- all_data %>%
  rowwise() %>%
  mutate(
    profile   = classify_profile(Cd, Fp, Ti, Pc, Sd),
    raw_score = Ti*0.15 + Cd*0.25 + Fp*0.20 + Pc*0.15 + Ts*0.10 + Sd*0.15
  ) %>%
  ungroup()

s_min <- min(all_data$raw_score)
s_max <- max(all_data$raw_score)
all_data$synergy <- round(40 + (all_data$raw_score - s_min)/(s_max - s_min) * 55, 1)
all_data <- all_data %>% arrange(desc(synergy)) %>% mutate(rank = row_number())

# ── 5. PRINT RESULTS ─────────────────────────────────────────
cat("\n=== FULL SYNERGY STANDINGS v3.0 ===\n")
print(as.data.frame(all_data %>%
  select(rank, team, wr_rank, synergy, Ti, Cd, Fp, Pc, Ts, Sd, win_pct_top10, profile)))

# ── 6. EXPORT JSON ───────────────────────────────────────────
teams_list <- lapply(seq_len(nrow(all_data)), function(i) {
  r <- all_data[i, ]
  list(
    rank               = as.integer(r$rank),
    wr_rank            = as.integer(r$wr_rank),
    team               = r$team,
    synergy            = r$synergy,
    Ti                 = round(r$Ti, 2),
    Cd                 = round(r$Cd, 2),
    Fp                 = round(r$Fp, 2),
    Pc                 = round(r$Pc, 2),
    Ts                 = round(r$Ts, 2),
    Sd                 = round(r$Sd, 2),
    Xp                 = round(r$Pc, 2), # Fallback for legacy cached HTML
    win_pct_top10      = as.integer(r$win_pct_top10),
    profile            = r$profile,
    dominant_club      = r$dominant_club,
    fp_display         = if (!is.null(r$fp_display) && !is.na(r$fp_display)) r$fp_display else "—",
    n_players          = as.integer(r$n_players),
    data_source        = r$data_source,
    wr_pts             = round(r$wr_pts, 2),
    coach_name         = r$coach_name,
    coach_tenure_yrs   = r$coach_tenure_yrs,
    avg_starter_caps   = r$avg_starter_caps,
    combination_status = r$combination_status,
    style_category     = r$style_category,
    style_icon         = r$style_icon
  )
})

out_json <- list(
  generated_at  = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz="UTC"),
  model_version = "rugby_v3.0",
  tournament    = "RWC 2027 Australia",
  total_teams   = nrow(all_data),
  formula       = "S = (Ti×0.15 + Cd×0.25 + Fp×0.20 + Pc×0.15 + Ts×0.10 + Sd×0.15)×10, normalised 40-95",
  teams         = teams_list
)

out_path <- file.path(OUT_DIR, "rugby_teams.json")
write(toJSON(out_json, auto_unbox=TRUE, pretty=TRUE), out_path)
cat(sprintf("\n🏉 JSON v3.0 written: %s\n   Teams: %d\n", out_path, nrow(all_data)))
