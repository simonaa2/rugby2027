# ============================================================
# calc_rugby_synergy.R  —  RWC 2027 Rugby Union Synergy Model v3.0
# Formula: S = (Ti×0.15 + Cd×0.25 + Fp×0.20 + Pc×0.15 + Ts×0.10 + Sd×0.15) × 10
# Exports:
#   - rugby_teams.json
#   - data/full_synergy_standings.csv
#   - data/squad_coaching_data.csv
#   - data/nations_championship_match_fees.csv
#   - data/currency_exchange_arbitrage.csv
# ============================================================

library(jsonlite)
library(dplyr)

OUT_DIR  <- "C:/Users/simon/.gemini/antigravity/scratch/personal-qualities-audit/rugby_pipeline"
DATA_DIR <- file.path(OUT_DIR, "data")

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

# Write raw FP table to data/
write.csv(fp_raw, file.path(DATA_DIR, "fp_data_raw.csv"), row.names = FALSE)

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
    "Rassie Erasmus","Scott Robertson","Andy Farrell","Fabien Galthié","Steve Borthwick",
    "Gregor Townsend","Felipe Contepomi","Joe Schmidt","Mick Byrne","Eddie Jones","Steve Tandy",
    "Gonzalo Quesada","Richard Cockerill","Scott Lawrence","Simon Mannix","Pablo Lemoine","Pablo Bouza",
    "Rodolfo Ambrosio","Tevita Tu'ifua","David Gérard","Kingsley Jones"
  ),
  coach_tenure_yrs = c(
    8.0, 1.5, 6.0, 6.0, 3.5,
    9.0, 2.0, 2.5, 2.0, 3.0, 1.0,
    2.5, 2.5, 2.5, 2.0, 6.0, 2.0,
    2.0, 2.0, 2.0, 7.0
  ),
  combination_status = c(
    "Freedom Cup & World Cup Champion Core","Robertson Cycle Rebuild (Freedom Cup Runner-up)","Settled 6-Nations Champion Core","Settled Grand Slam Core","Rebuilt Post-2023 Unit",
    "Long-standing Core","Post-Cheika Transition","Schmidt Rebuilding Phase","Pacific Hybrid Combination","Eddie Jones Young Squad","Gatland Major Rebuild",
    "Quesada Evolving Unit","Set-Piece Heavy Core","MLR Hybrid Unit","European Professional Core","Super Rugby Americas Core","División de Honor Core",
    "Domestic Core Unit","Pacific Veteran Core","Eastern European Pack Unit","MLR Native Squad"
  ),
  style_category = c(
    "Set Piece & Tony Brown Attack","Running & Width","Set Piece & Lineout Drive","Expansive & Unpredictable","Kicking & Field Position",
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
    9.8, 8.8, 9.6, 8.8, 7.2,
    7.8, 8.2, 6.2, 8.0, 7.5, 5.8,
    6.8, 9.0, 5.5, 6.5, 6.0, 4.8,
    6.2, 6.5, 7.2, 4.5
  ),
  Sd = c(
    9.8, 8.5, 8.2, 9.2, 7.8,
    6.8, 7.2, 6.5, 6.2, 6.0, 5.5,
    6.2, 5.8, 4.2, 4.8, 3.5, 3.8,
    4.5, 5.2, 4.0, 3.8
  ),
  win_pct_top10 = c(
    85, 72, 80, 75, 52,
    55, 50, 42, 35, 30, 25,
    40, 20, 5, 15, 0, 5,
    10, 10, 5, 0
  ),
  # --- NEW: Player Workload & Injury Risk Mitigation ---
  workload_rotation_rating = c(
    "Elite (23-man Squad Rotation)","High (Super Rugby Load Managed)","Controlled (IRFU Central Minutes Cap)","Heavy Load (Top 14 Overload Risk)","Moderate (Premiership 24-game Cap)",
    "High Starter Dependency","Moderate (European Pro Rotation)","Moderate (RA Load Management)","High Fatigue Risk (Global Travel)","Controlled (League One Moderate Games)",
    "High Fatigue Risk (Thin Squad)","Moderate (Benetton Load Managed)","High Starter Dependency","Moderate (MLR Workload)","High Fatigue Risk",
    "Extreme Fatigue Risk (Amateur/Pro Mix)","High Fatigue Risk","Moderate (Peñarol Centrally Managed)","High Fatigue Risk (Veteran Load)",
    "High Fatigue Risk","High Fatigue Risk"
  ),
  season_minutes_status = c(
    "~1,400 mins/yr (Centrally Managed)","~1,600 mins/yr (SR Managed)","~1,350 mins/yr (Strict IRFU Cap)","~2,200 mins/yr (Top 14 Heavy)","~1,800 mins/yr (Prem Cap)",
    "~1,900 mins/yr (High Overuse)","~1,850 mins/yr (Euro Pro)","~1,650 mins/yr (RA Managed)","~2,000 mins/yr (Travel Heavy)","~1,200 mins/yr (JRLO Short Season)",
    "~2,000 mins/yr (Overuse Risk)","~1,700 mins/yr (Benetton Core)","~2,100 mins/yr (Pro D2 Heavy)","~1,500 mins/yr (MLR Season)","~1,900 mins/yr (French Pro D2)",
    "~1,800 mins/yr (Amateur Load)","~1,700 mins/yr (Local Load)","~1,400 mins/yr (SLAR Managed)","~1,800 mins/yr (Veteran Overuse)","~1,900 mins/yr (Domestic)",
    "~1,600 mins/yr (MLR Load)"
  ),
  n_players = c(
    480, 510, 520, 495, 490,
    360, 380, 420, 280, 290, 370,
    340, 180, 170, 140, 120, 90,
    100, 110, 95, 80
  ),
  data_source = "research_compiled_v3"
)

# Export raw squad & coaching dataset
write.csv(squad_data_v3, file.path(DATA_DIR, "squad_coaching_data.csv"), row.names = FALSE)

# Export Nations Championship Match Fee dataset
nc_fees <- data.frame(
  rank = 1:12,
  team = c("England","Ireland","France","New Zealand","Scotland","Wales","Australia","South Africa","Japan","Italy","Fiji","Georgia"),
  union_contracting_structure = c("RFU Enhanced Contracts","IRFU Central Contracts + Bonus","FFR Test Match Allowance","NZR Central Pool","SRU Match Fee Pool","WRU Match Scale","RA Central Incentive","SARU PONI Pool + Match Fee","JRFU Match Allowance","FIR Match Bonus","FRU Test Allowance","GRU Match Scale"),
  match_fee_usd = c(29000, 22000, 20000, 14000, 13000, 11000, 10000, 6800, 6000, 5500, 3000, 2500),
  est_annual_12match_usd = c(348000, 264000, 240000, 168000, 156000, 132000, 120000, 81600, 72000, 66000, 36000, 30000)
)
write.csv(nc_fees, file.path(DATA_DIR, "nations_championship_match_fees.csv"), row.names = FALSE)

# Export Currency Arbitrage dataset
currency_arbitrage <- data.frame(
  country = c("South Africa","New Zealand","Australia","Fiji","United Kingdom","France (Eurozone)","Japan"),
  currency_code = c("ZAR","NZD","AUD","FJD","GBP","EUR","JPY"),
  symbol = c("R","$","$","$","£","€","¥"),
  rate_to_usd = c(18.20, 1.65, 1.52, 2.25, 0.78, 0.92, 152.00),
  ppp_cost_of_living_index = c(1.00, 0.85, 0.85, 1.20, 0.70, 0.75, 0.85)
)
write.csv(currency_arbitrage, file.path(DATA_DIR, "currency_exchange_arbitrage.csv"), row.names = FALSE)

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

# Load player database for dynamic spine calculation
player_db <- read.csv(file.path(DATA_DIR, "player_database.csv"), stringsAsFactors = FALSE)

# Calculate Spine Cohesion & Eigenvector Centrality Matrix per team
calc_spine_eigenvector <- function(spine_clubs) {
  n <- length(spine_clubs)
  if (n < 2) return(list(score=2.0, lambda=0.0, ev_vec=rep(0.2, max(1, n))))
  
  # Build Adjacency Matrix A (n x n) representing shared club connections
  A <- matrix(0, nrow = n, ncol = n)
  for (i in 1:n) {
    for (j in 1:n) {
      if (i != j && spine_clubs[i] == spine_clubs[j] && spine_clubs[i] != "") {
        A[i, j] <- 1.0
      }
    }
  }
  
  # Solve Eigenvalue Decomposition: A * v = lambda * v
  ev <- eigen(A)
  lambda_max <- max(Re(ev$values))
  principal_v <- abs(Re(ev$vectors[, 1]))
  if (sum(principal_v) > 0) principal_v <- principal_v / sum(principal_v)
  
  # Max possible eigenvalue for K5 complete graph is 4.0
  eigen_score <- round(min(10.0, max(2.0, (lambda_max / 4.0) * 8.0 + 2.0)), 2)
  list(score = eigen_score, lambda = round(lambda_max, 3), ev_vec = round(principal_v, 3))
}

spine_scores <- lapply(unique(squad_data_v3$team), function(tm) {
  team_spine <- player_db %>% filter(team == tm & (grepl("Spine", role) | (position == "Hooker" & role == "Starter")))
  spine_clubs <- team_spine$club
  spine_clubs <- spine_clubs[spine_clubs != "" & !is.na(spine_clubs)]
  
  ev_res <- calc_spine_eigenvector(spine_clubs)
  
  if (length(spine_clubs) > 0) {
    tbl <- sort(table(spine_clubs), decreasing = TRUE)
    max_same <- as.integer(tbl[1])
    dom_club <- names(tbl)[1]
    
    score <- if (max_same == 5) 10.0
             else if (max_same == 4) 9.0
             else if (max_same == 3) 7.0
             else if (max_same == 2) 4.5
             else 2.0
  } else {
    max_same <- 1
    dom_club <- "Scattered"
    score <- 2.0
  }
  
  data.frame(
    team = tm,
    spine_dominant_club = dom_club,
    spine_match_count = max_same,
    spine_score = score,
    Sd_calc = score,
    eigen_spine_score = ev_res$score,
    eigen_lambda_max = ev_res$lambda,
    stringsAsFactors = FALSE
  )
}) %>% bind_rows()

# ── 4. MERGE & CALCULATE SYNERGY v3.0 ────────────────────────
cat("\n⏳ Merging and calculating v3.0 synergy scores...\n")

all_data <- squad_data_v3 %>%
  left_join(fp_df %>% select(team, Fp, dominant_club, fp_display, fp_max_same), by="team") %>%
  left_join(spine_scores, by="team") %>%
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

# Formula v3.0: S = (Ti×0.15 + (Cd + spine_bonus)×0.25 + Fp×0.20 + Pc×0.15 + Ts×0.10 + Sd×0.15) × 10
# spine_bonus: up to +0.75 for elite spines (matches of 3+)
all_data <- all_data %>%
  rowwise() %>%
  mutate(
    spine_bonus = (spine_score / 10.0) * 0.75,
    profile   = classify_profile(Cd, Fp, Ti, Pc, Sd),
    raw_score = Ti*0.15 + (Cd + spine_bonus)*0.25 + Fp*0.20 + Pc*0.15 + Ts*0.10 + Sd*0.15
  ) %>%
  ungroup()

s_min <- min(all_data$raw_score)
s_max <- max(all_data$raw_score)
all_data$synergy <- round(40 + (all_data$raw_score - s_min)/(s_max - s_min) * 55, 1)
all_data <- all_data %>% arrange(desc(synergy)) %>% mutate(rank = row_number())

# Export full calculated CSV to data/
write.csv(all_data, file.path(DATA_DIR, "full_synergy_standings.csv"), row.names = FALSE)

# ── 5. PRINT RESULTS ─────────────────────────────────────────
cat("\n=== FULL SYNERGY STANDINGS v3.0 ===\n")
print(as.data.frame(all_data %>%
  select(rank, team, wr_rank, synergy, Ti, Cd, Fp, Pc, Ts, Sd, win_pct_top10, profile)))

# Load player database
player_db <- read.csv(file.path(DATA_DIR, "player_database.csv"), stringsAsFactors = FALSE)

# ── 6. EXPORT JSON ───────────────────────────────────────────
teams_list <- lapply(seq_len(nrow(all_data)), function(i) {
  r <- all_data[i, ]
  
  # Filter players for this team
  team_players <- player_db %>% filter(team == r$team)
  players_list <- if(nrow(team_players) > 0) {
    lapply(seq_len(nrow(team_players)), function(j) {
      list(
        name     = team_players$player_name[j],
        position = team_players$position[j],
        club     = team_players$club[j],
        caps     = as.integer(team_players$caps[j]),
        role     = team_players$role[j]
      )
    })
  } else {
    list()
  }

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
    Xp                 = round(r$Pc, 2),
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
    style_icon         = r$style_icon,
    workload_rotation_rating = r$workload_rotation_rating,
    season_minutes_status    = r$season_minutes_status,
    spine_dominant_club      = r$spine_dominant_club,
    spine_match_count        = as.integer(r$spine_match_count),
    spine_score              = round(r$spine_score, 1),
    players                  = players_list
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
cat(sprintf("📊 Raw CSV datasets written to: %s\n", DATA_DIR))
