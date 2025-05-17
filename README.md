# Shape-Ships-AI

*Shape-Ships-AI* is a neon-styled 2D shooter inspired by *Geometry Wars: Retro Evolved*, built in Processing 4.4.1. The game features AI-driven custom enemies with dynamic behaviors (homing, shielding, orbiting, erratic, boomerang) that adapt to player performance, making it a standout project for an AI portfolio. Developed to showcase procedural enemy generation and adaptive difficulty in game development.

## Features
- **AI-Driven Enemies**: Custom enemies spawn in stage 5 (score ≥ 200, kill rate ≥ 5, survival time ≥ 60s) with 1–2 attributes (e.g., homing bullets, shielding toggles every 10s), varied shapes (pentagon, octagon, star, heptagon, cross, triangle), and neon colors.
- **Dynamic Difficulty**: Enemy spawn rate scales from 1 to 2 enemies/s over 300s, with custom enemy probability increasing from 6% to 20% based on player `skillLevel` (score, kills, time).
- **Gameplay Mechanics**: Players control a ship with arrow keys, shoot with left-click, deploy black holes with right-click (pulls enemies), and restart with spacebar.
- **Visuals**: Neon cyan/pink grid background, glowing enemies, and smooth 60 FPS rendering using Processing’s P2D renderer.
- **HUD**: Displays stage, score, and lives in the top-left corner.

## Installation
1. Download and install [Processing 4.4.1](https://processing.org/download).
2. Clone this repository:
   ```bash
   git clone https://github.com/Kirby-Manjarres/Shape-Ships-AI.git
