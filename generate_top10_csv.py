import csv

players = [
    # SOUTH AFRICA (Springboks)
    ("Eben Etzebeth", "South Africa 🇿🇦", "Sharks", "URC", 280000, 120, "Starter (Spine)", 95.0, 3.39, 168000, "Underpaid"),
    ("Ox Nché", "South Africa 🇿🇦", "Sharks", "URC", 150000, 35, "Starter", 78.0, 5.20, 90000, "Underpaid"),
    ("Bongi Mbonambi", "South Africa 🇿🇦", "Sharks", "URC", 160000, 68, "Starter (Spine)", 82.0, 5.13, 96000, "Underpaid"),
    ("Frans Malherbe", "South Africa 🇿🇦", "Stormers", "URC", 210000, 69, "Starter", 84.0, 4.00, 126000, "Underpaid"),
    ("Siya Kolisi", "South Africa 🇿🇦", "Sharks", "URC", 550000, 85, "Starter (Spine)", 92.0, 1.67, 330000, "Underpaid"),
    ("Pieter-Steph du Toit", "South Africa 🇿🇦", "Verblitz", "Japan JRLO", 750000, 76, "Starter", 94.0, 1.25, 507000, "Fair Value"),
    ("Cheslin Kolbe", "South Africa 🇿🇦", "Suntory", "Japan JRLO", 950000, 38, "Starter", 91.0, 0.96, 642200, "Fair Value"),
    ("Malcolm Marx", "South Africa 🇿🇦", "Spears", "Japan JRLO", 680000, 64, "Bench / Rotation", 85.0, 1.25, 459680, "Fair Value"),
    ("Vincent Koch", "South Africa 🇿🇦", "Sharks", "URC", 190000, 49, "Bench / Rotation", 75.0, 3.95, 114000, "Underpaid"),
    ("Handré Pollard", "South Africa 🇿🇦", "Leicester", "Premiership", 780000, 68, "Starter (Spine)", 86.0, 1.10, 300300, "Fair Value"),
    ("Damian de Allende", "South Africa 🇿🇦", "Wild Knights", "Japan JRLO", 720000, 78, "Starter", 88.0, 1.22, 486720, "Fair Value"),
    ("Jesse Kriel", "South Africa 🇿🇦", "Eagles", "Japan JRLO", 650000, 68, "Starter", 85.0, 1.31, 439400, "Fair Value"),
    ("Willie le Roux", "South Africa 🇿🇦", "Bulls", "URC", 220000, 93, "Starter (Spine)", 84.0, 3.82, 132000, "Underpaid"),
    ("RG Snyman", "South Africa 🇿🇦", "Leinster", "URC", 480000, 34, "Starter", 86.0, 1.79, 262080, "Underpaid"),
    ("Kwagga Smith", "South Africa 🇿🇦", "Blue Revs", "Japan JRLO", 620000, 40, "Bench / Rotation", 84.0, 1.35, 419120, "Fair Value"),
    ("Kurt-Lee Arendse", "South Africa 🇿🇦", "Bulls", "URC", 180000, 18, "Starter", 82.0, 4.56, 108000, "Underpaid"),
    ("Damian Willemse", "South Africa 🇿🇦", "Stormers", "URC", 240000, 40, "Starter (Spine)", 85.0, 3.54, 144000, "Underpaid"),
    ("Manie Libbok", "South Africa 🇿🇦", "Stormers", "URC", 190000, 18, "Starter (Spine)", 78.0, 4.11, 114000, "Underpaid"),

    # NEW ZEALAND (All Blacks)
    ("Ardie Savea", "New Zealand 🇳🇿", "Kobe", "Japan JRLO", 750000, 84, "Starter (Spine)", 94.0, 1.25, 507000, "Fair Value"),
    ("Codie Taylor", "New Zealand 🇳🇿", "Crusaders", "Super Rugby", 340000, 85, "Starter (Spine)", 86.0, 2.53, 176290, "Underpaid"),
    ("Scott Barrett", "New Zealand 🇳🇿", "Crusaders", "Super Rugby", 410000, 69, "Starter", 85.0, 2.07, 212585, "Underpaid"),
    ("Jordie Barrett", "New Zealand 🇳🇿", "Hurricanes", "Super Rugby", 380000, 60, "Starter", 83.0, 2.18, 197030, "Underpaid"),
    ("Rieko Ioane", "New Zealand 🇳🇿", "Blues", "Super Rugby", 390000, 67, "Starter", 84.0, 2.15, 202215, "Underpaid"),
    ("Beauden Barrett", "New Zealand 🇳🇿", "Verblitz", "Japan JRLO", 820000, 123, "Starter (Spine)", 92.0, 1.12, 554320, "Fair Value"),
    ("Will Jordan", "New Zealand 🇳🇿", "Crusaders", "Super Rugby", 360000, 31, "Starter (Spine)", 88.0, 2.44, 186660, "Underpaid"),
    ("Mark Tele'a", "New Zealand 🇳🇿", "Blues", "Super Rugby", 280000, 11, "Starter", 80.0, 2.86, 145180, "Underpaid"),
    ("Tyrel Lomax", "New Zealand 🇳🇿", "Hurricanes", "Super Rugby", 320000, 32, "Starter", 81.0, 2.53, 165920, "Underpaid"),
    ("Ethan de Groot", "New Zealand 🇳🇿", "Highlanders", "Super Rugby", 290000, 25, "Starter", 79.0, 2.72, 150365, "Underpaid"),
    ("Richie Mo'unga", "New Zealand 🇳🇿", "Brave Lupus", "Japan JRLO", 850000, 56, "Starter (Spine)", 91.0, 1.07, 574600, "Fair Value"),
    ("Shannon Frizell", "New Zealand 🇳🇿", "Brave Lupus", "Japan JRLO", 650000, 33, "Starter", 83.0, 1.28, 439400, "Fair Value"),

    # IRELAND (Irish Rugby)
    ("Dan Sheehan", "Ireland 🇮🇪", "Leinster", "URC", 240000, 26, "Starter (Spine)", 88.0, 3.67, 131040, "Underpaid"),
    ("Andrew Porter", "Ireland 🇮🇪", "Leinster", "URC", 320000, 62, "Starter", 85.0, 2.66, 174720, "Underpaid"),
    ("Tadhg Furlong", "Ireland 🇮🇪", "Leinster", "URC", 450000, 72, "Starter", 89.0, 1.98, 245700, "Underpaid"),
    ("Caelan Doris", "Ireland 🇮🇪", "Leinster", "URC", 380000, 43, "Starter (Spine)", 90.0, 2.37, 207480, "Underpaid"),
    ("Jamison Gibson-Park", "Ireland 🇮🇪", "Leinster", "URC", 320000, 35, "Starter (Spine)", 87.0, 2.72, 174720, "Underpaid"),
    ("Hugo Keenan", "Ireland 🇮🇪", "Leinster", "URC", 310000, 39, "Starter (Spine)", 86.0, 2.77, 169260, "Underpaid"),
    ("Bundee Aki", "Ireland 🇮🇪", "Connacht", "URC", 390000, 56, "Starter", 90.0, 2.31, 212940, "Underpaid"),
    ("Garry Ringrose", "Ireland 🇮🇪", "Leinster", "URC", 350000, 57, "Starter", 85.0, 2.43, 191100, "Underpaid"),
    ("James Lowe", "Ireland 🇮🇪", "Leinster", "URC", 340000, 31, "Starter", 84.0, 2.47, 185640, "Underpaid"),
    ("Josh van der Flier", "Ireland 🇮🇪", "Leinster", "URC", 380000, 62, "Starter", 89.0, 2.34, 207480, "Underpaid"),
    ("Peter O'Mahony", "Ireland 🇮🇪", "Munster", "URC", 360000, 105, "Starter", 84.0, 2.33, 196560, "Underpaid"),
    ("Tadhg Beirne", "Ireland 🇮🇪", "Munster", "URC", 370000, 46, "Starter", 87.0, 2.35, 202020, "Underpaid"),
    ("James Ryan", "Ireland 🇮🇪", "Leinster", "URC", 350000, 64, "Bench / Rotation", 83.0, 2.37, 191100, "Underpaid"),
    ("Jack Crowley", "Ireland 🇮🇪", "Munster", "URC", 220000, 18, "Starter (Spine)", 79.0, 3.59, 120120, "Underpaid"),
    ("John Ryan", "Ireland 🇮🇪", "Munster", "URC", 180000, 24, "Rotation / Veteran", 65.0, 3.61, 98280, "Underpaid"),
    ("Paddy Jackson", "Ireland 🇮🇪", "Lyon", "Top 14", 450000, 0, "Club Only", 20.0, 0.44, 185625, "Overpaid"),

    # FRANCE (Les Bleus)
    ("Antoine Dupont", "France 🇫🇷", "Toulouse", "Top 14", 950000, 52, "Starter (Spine)", 98.0, 1.03, 391875, "Fair Value"),
    ("Thomas Ramos", "France 🇫🇷", "Toulouse", "Top 14", 620000, 36, "Starter (Spine)", 86.0, 1.39, 255750, "Fair Value"),
    ("Grégory Alldritt", "France 🇫🇷", "La Rochelle", "Top 14", 720000, 48, "Starter (Spine)", 90.0, 1.25, 297000, "Fair Value"),
    ("Peato Mauvaka", "France 🇫🇷", "Toulouse", "Top 14", 480000, 32, "Starter (Spine)", 82.0, 1.71, 198000, "Underpaid"),
    ("Cyril Baille", "France 🇫🇷", "Toulouse", "Top 14", 520000, 47, "Starter", 83.0, 1.60, 214500, "Underpaid"),
    ("Uini Atonio", "France 🇫🇷", "La Rochelle", "Top 14", 550000, 60, "Starter", 78.0, 1.42, 226875, "Underpaid"),
    ("Thibaud Flament", "France 🇫🇷", "Toulouse", "Top 14", 460000, 26, "Starter", 81.0, 1.76, 189750, "Underpaid"),
    ("Damian Penaud", "France 🇫🇷", "Bordeaux", "Top 14", 680000, 48, "Starter", 91.0, 1.34, 280500, "Fair Value"),
    ("Louis Bielle-Biarrey", "France 🇫🇷", "Bordeaux", "Top 14", 320000, 11, "Starter", 82.0, 2.56, 132000, "Underpaid"),
    ("Matthieu Jalibert", "France 🇫🇷", "Bordeaux", "Top 14", 580000, 30, "Starter (Spine)", 83.0, 1.43, 239250, "Fair Value"),
    ("Gaël Fickou", "France 🇫🇷", "Racing 92", "Top 14", 750000, 85, "Starter", 87.0, 1.16, 309375, "Fair Value"),
    ("Mid-Tier Top 14 Prop", "France 🇫🇷", "Top 14 Club", "Top 14", 460000, 3, "Rotation", 25.0, 0.54, 189750, "Overpaid"),
    ("French Squad Lock", "France 🇫🇷", "Top 14 Club", "Top 14", 410000, 5, "Rotation", 28.0, 0.68, 169125, "Overpaid"),

    # ENGLAND (Red Roses / XV)
    ("Maro Itoje", "England 🏴󠁧󠁢󠁥󠁮󠁧󠁿", "Saracens", "Premiership", 850000, 76, "Starter", 90.0, 1.06, 327250, "Fair Value"),
    ("Ellis Genge", "England 🏴󠁧󠁢󠁥󠁮󠁧󠁿", "Bristol", "Premiership", 580000, 58, "Starter", 82.0, 1.41, 223300, "Fair Value"),
    ("Ben Earl", "England 🏴󠁧󠁢󠁥󠁮󠁧󠁿", "Saracens", "Premiership", 420000, 30, "Starter (Spine)", 84.0, 2.00, 161700, "Underpaid"),
    ("Marcus Smith", "England 🏴󠁧󠁢󠁥󠁮󠁧󠁿", "Harlequins", "Premiership", 650000, 30, "Starter (Spine)", 83.0, 1.28, 250250, "Fair Value"),
    ("George Ford", "England 🏴󠁧󠁢󠁥󠁮󠁧󠁿", "Sale", "Premiership", 620000, 96, "Starter (Spine)", 85.0, 1.37, 238700, "Fair Value"),
    ("Freddie Steward", "England 🏴󠁧󠁢󠁥󠁮󠁧󠁿", "Leicester", "Premiership", 380000, 34, "Starter (Spine)", 79.0, 2.08, 146300, "Underpaid"),
    ("Henry Slade", "England 🏴󠁧󠁢󠁥󠁮󠁧󠁿", "Exeter", "Premiership", 480000, 60, "Starter", 81.0, 1.69, 184800, "Underpaid"),
    ("Jamie George", "England 🏴󠁧󠁢󠁥󠁮󠁧󠁿", "Saracens", "Premiership", 520000, 88, "Starter (Spine)", 83.0, 1.60, 200200, "Underpaid"),
    ("Dan Cole", "England 🏴󠁧󠁢󠁥󠁮󠁧󠁿", "Leicester", "Premiership", 320000, 112, "Starter", 76.0, 2.38, 123200, "Underpaid"),
    ("Jack Willis", "England 🏴󠁧󠁢󠁥󠁮󠁧󠁿", "Toulouse", "Top 14", 550000, 0, "Club / Ineligible", 25.0, 0.45, 226875, "Overpaid"),
    ("Manu Tuilagi", "England 🏴󠁧󠁢󠁥󠁮󠁧󠁿", "Bayonne", "Top 14", 600000, 1, "Club / Ineligible", 30.0, 0.50, 247500, "Overpaid"),
    ("Billy Vunipola", "England 🏴󠁧󠁢󠁥󠁮󠁧󠁿", "Montpellier", "Top 14", 520000, 0, "Club / Ineligible", 27.0, 0.52, 214500, "Overpaid"),
    ("Zach Mercer", "England 🏴󠁧󠁢󠁥󠁮󠁧󠁿", "Gloucester", "Premiership", 480000, 0, "Club Only", 26.0, 0.54, 184800, "Overpaid"),
    ("Kyle Sinckler", "England 🏴󠁧󠁢󠁥󠁮󠁧󠁿", "Toulon", "Top 14", 580000, 0, "Club / Ineligible", 32.0, 0.55, 239250, "Overpaid"),
    ("Luke Cowan-Dickie", "England 🏴󠁧󠁢󠁥󠁮󠁧󠁿", "Sale", "Premiership", 450000, 2, "Club / Backup", 30.0, 0.67, 173250, "Overpaid"),
    ("Courtney Lawes", "England 🏴󠁧󠁢󠁥󠁮󠁧󠁿", "Brive", "Top 14", 520000, 0, "Retired / Club", 35.0, 0.67, 214500, "Overpaid"),
    ("Premiership Rotation Lock", "England 🏴󠁧󠁢󠁥󠁮󠁧󠁿", "Premiership Club", "Premiership", 380000, 2, "Rotation", 22.0, 0.58, 146300, "Overpaid"),

    # SCOTLAND
    ("Finn Russell", "Scotland 🏴󠁧󠁢󠁳󠁣󠁴󠁿", "Bath", "Premiership", 1150000, 75, "Starter (Spine)", 92.0, 0.80, 442750, "Fair Value"),
    ("Duhan van der Merwe", "Scotland 🏴󠁧󠁢󠁳󠁣󠁴󠁿", "Edinburgh", "URC", 380000, 39, "Starter", 82.0, 2.16, 207480, "Underpaid"),
    ("Zander Fagerson", "Scotland 🏴󠁧󠁢󠁳󠁣󠁴󠁿", "Glasgow", "URC", 310000, 62, "Starter", 80.0, 2.58, 169260, "Underpaid"),
    ("Pierre Schoeman", "Scotland 🏴󠁧󠁢󠁳󠁣󠁴󠁿", "Edinburgh", "URC", 320000, 31, "Starter", 81.0, 2.53, 174720, "Underpaid"),
    ("Huw Jones", "Scotland 🏴󠁧󠁢󠁳󠁣󠁴󠁿", "Glasgow", "URC", 290000, 48, "Starter", 83.0, 2.86, 158340, "Underpaid"),
    ("Sione Tuipulotu", "Scotland 🏴󠁧󠁢󠁳󠁣󠁴󠁿", "Glasgow", "URC", 310000, 25, "Starter", 82.0, 2.65, 169260, "Underpaid"),
    ("Blair Kinghorn", "Scotland 🏴󠁧󠁢󠁳󠁣󠁴󠁿", "Toulouse", "Top 14", 520000, 53, "Starter (Spine)", 84.0, 1.62, 214500, "Underpaid"),

    # ARGENTINA (Los Pumas)
    ("Marcos Kremer", "Argentina 🇦🇷", "Clermont", "Top 14", 480000, 64, "Starter", 82.0, 1.71, 198000, "Underpaid"),
    ("Emiliano Boffelli", "Argentina 🇦🇷", "Edinburgh", "URC", 320000, 60, "Starter", 78.0, 2.44, 174720, "Underpaid"),
    ("Pablo Matera", "Argentina 🇦🇷", "Honda Heat", "Japan JRLO", 650000, 98, "Starter", 88.0, 1.35, 439400, "Fair Value"),
    ("Julián Montoya", "Argentina 🇦🇷", "Leicester", "Premiership", 520000, 95, "Starter (Spine)", 87.0, 1.67, 200200, "Underpaid"),
    ("Mateo Carreras", "Argentina 🇦🇷", "Bayonne", "Top 14", 340000, 20, "Starter", 79.0, 2.32, 140250, "Underpaid"),

    # AUSTRALIA (Wallabies)
    ("Rob Valetini", "Australia 🇦🇺", "Brumbies", "Super Rugby", 350000, 39, "Starter (Spine)", 84.0, 2.40, 160875, "Underpaid"),
    ("Will Skelton", "Australia 🇦🇺", "La Rochelle", "Top 14", 680000, 30, "Starter", 80.0, 1.18, 280500, "Fair Value"),
    ("Taniela Tupou", "Australia 🇦🇺", "Reds", "Super Rugby", 420000, 51, "Starter", 82.0, 1.95, 193200, "Underpaid"),
    ("Samu Kerevi", "Australia 🇦🇺", "Urayasu", "Japan JRLO", 720000, 49, "Starter", 85.0, 1.18, 486720, "Fair Value"),
    ("Marika Koroibete", "Australia 🇦🇺", "Wild Knights", "Japan JRLO", 780000, 59, "Starter", 87.0, 1.12, 527280, "Fair Value"),
    ("Allan Alaalatoa", "Australia 🇦🇺", "Brumbies", "Super Rugby", 380000, 67, "Starter", 80.0, 2.11, 174800, "Underpaid"),

    # FIJI (Flying Fijians)
    ("Te Vita Ikanivere", "Fiji 🇫🇯", "Drua", "Super Rugby", 65000, 15, "Starter (Spine)", 62.0, 9.54, 62400, "Underpaid"),
    ("Waisea Nayacalevu", "Fiji 🇫🇯", "Sale", "Premiership", 340000, 38, "Starter", 78.0, 2.29, 130900, "Underpaid"),
    ("Eroni Mawi", "Fiji 🇫🇯", "Saracens", "Premiership", 220000, 32, "Starter", 68.0, 3.09, 84700, "Underpaid"),
    ("Levani Botia", "Fiji 🇫🇯", "La Rochelle", "Top 14", 450000, 31, "Starter", 81.0, 1.80, 185625, "Underpaid"),
    ("Semi Radradra", "Fiji 🇫🇯", "Lyon", "Top 14", 620000, 18, "Starter", 80.0, 1.29, 255750, "Fair Value"),
    ("Josua Tuisova", "Fiji 🇫🇯", "Racing 92", "Top 14", 580000, 24, "Starter", 83.0, 1.43, 239250, "Fair Value"),

    # JAPAN (Brave Blossoms)
    ("Warner Dearns", "Japan 🇯🇵", "Toshiba", "Japan JRLO", 380000, 18, "Starter", 72.0, 1.89, 256800, "Underpaid"),
    ("Keita Inagaki", "Japan 🇯🇵", "Wild Knights", "Japan JRLO", 320000, 49, "Starter", 76.0, 2.38, 216200, "Underpaid"),
    ("Atsushi Sakate", "Japan 🇯🇵", "Wild Knights", "Japan JRLO", 310000, 37, "Starter (Spine)", 74.0, 2.39, 209480, "Underpaid"),
    ("Kazuki Himeno", "Japan 🇯🇵", "Verblitz", "Japan JRLO", 450000, 32, "Starter", 80.0, 1.78, 304200, "Underpaid"),
    ("Michael Leitch", "Japan 🇯🇵", "Brave Lupus", "Japan JRLO", 480000, 84, "Starter", 84.0, 1.75, 324480, "Underpaid")
]

with open("C:/Users/simon/.gemini/antigravity/scratch/personal-qualities-audit/rugby_pipeline/data/top10_nations_player_valuations.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["player_name","team","club","league","salary_usd","caps","role","perf_score","pvi","net_ppp_usd","status"])
    for row in players:
        writer.writerow(row)

print(f"Generated top10_nations_player_valuations.csv with {len(players)} players!")
