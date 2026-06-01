**Due date: 6/1 23:59**

# Dragonshire — Farm Village Simulator
Programming Methodology Team Project, Spring 2026 — **Team 20**.
A medieval-fantasy **Farm Village Simulator (PvE)** in **C++17 + SFML**: farm,
raise livestock, trade, craft and upgrade, then defend the village from monster waves.

# Run
(1) Pull Docker Image
```
docker pull --platform linux/amd64 mono1ka/team_20_project:0.1.0
```
(2) Run the app

Option A — Play in your browser (recommended):
```
bash scripts/run.sh
```
This starts the container, builds `build/main` on first run, and serves the game over VNC.
The first run takes ~30 seconds while the VNC tools install (cached afterwards). Wait until
the terminal reports the VNC server is ready, then open the link in step (3). Press **Ctrl+C**
to stop.

Option B — Native OS window via host X11:
```
bash scripts/run.sh --docker
```
Opens a real OS window instead of the browser. Needs an X server (Linux desktop, WSLg on
Windows 11, or XQuartz on macOS). Run `bash scripts/run.sh --help` for all modes.

(3) Web browser
```
http://localhost:6080/vnc.html
```
(Auto-connecting, auto-scaling variant: `http://localhost:6080/vnc_lite.html?autoconnect=true&resize=scale`)

# Game System
### (1) GUI
- Implemented using a full GUI system
- Move with **WASD**; dash by double-tapping a movement key (uses stamina)
- Interact / talk / confirm with **E**; every dialog and popup shows its own key hints
- Combat: melee = **Left-click** or **Space**, magic = **Right-click** or **Q**, area magic = **G**
- Inventory **I**, Equipment **B**, hotbar consumables **1–4**, pause / close popup **Esc**
- **English / 한국어** language toggle (Settings → Language; defaults to English)

### (2) Field (Farming)
- 9 crops available: Wheat, Carrot, Tomato, Winterberry, Pumpkin, Golden Wheat, Mana Berry, Frost Lily, Dragon Fruit
- Base sell prices range widely: Wheat 8 → Dragon Fruit 170 (Col)
- Plant → grow → harvest with **quality grades**; some crops are multi-harvest
- Plant / harvest / water the tile in front with **F**; bulk farm actions with **T** (Village Lv 2+)
- Premium seeds unlock as the village level rises

### (3) Livestock (Pen)
- Raise chickens (eggs), cows (milk), sheep (wool), and bees (honey)
- **Feed quality affects product grade** — feed a nearby animal with **R**
- Charles the herder tends the pen; talk to him to bulk-feed or bulk-collect from the herd

### (4) Production & Crafting
- Production buildings: Mill (wheat → flour), Dairy (milk → butter → cheese), Bakery (flour → bread), Winery (fruit → wine)
- Product grade follows the input ingredient's grade
- Otto the Smith enhances and repairs weapons — bring mana crystals and prisms

### (5) Market & Storehouse
- Currency is **Col**; prices fluctuate over time
- Bran (village) sells seeds, livestock, and tools; Iola (city) sells rare late-game goods, magic stones, and dragon-tier gear
- Mustafar the wandering merchant carries mythic gear for a limited time, at a premium
- Markus' storehouse holds bulk goods with grade-aware stacking; crops spill over there when your bag is full

### (6) Village Level & Upgrades
- Tristan in the Town Hall manages **village-level upgrades** and **per-building tiers**
- Higher levels unlock better crops and goods, and more efficient workers

### (7) Combat & Wave Defense
- Equip a **weapon** (physical damage) AND a **magic stone** (magic damage); **Q** swaps weapons
- Fight goblins, archers, and tanks; explore the dungeon for tougher foes
- Periodic monster **waves** attack the south gate — you can't leave the village mid-wave

### (8) Travel & Time System
- Henry / Cedric ready a horse to travel between the Village and the City (each trip burns game hours; higher-tier stables are faster)
- One in-game hour passes every real minute; sleeping advances time; full day/night cycle

### (9) Season & Weather
- Weather affects crop growth: storms damage seedlings, sunny days speed up harvests
- Random events occur: drought, pest infestation, and flood
- Celine's almanac in the plaza predicts the next **three days** of weather

### (10) Mini-game
- Bruno runs a **"Three Doors"** betting table in town
- Limited to five hands per season — pick your battles

---

**Notes for graders**
- The game window is 1280×720, rendered on a virtual display and streamed to your browser; noVNC scales it to fit.
- The VNC tool-chain installs on first launch; rebuild from `docker/` (`docker/docker_build.sh`) to bake it in and skip the wait.
- Progress autosaves. Found a bug or have feedback? Please open a GitHub Issue on this repo.
