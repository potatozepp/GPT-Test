# Simple Tower Defense Game

This repository contains a minimal **3D** Godot project demonstrating a very basic tower defense prototype. The player can place path segments to guide enemies toward the core while a single tower automatically attacks nearby enemies.

Open `project.godot` in Godot and run the main scene to try it out. Press the **Start Game** button to begin. The scene is tuned for a **portrait/mobile** layout (720x1280 default), with a top resource HUD and a bottom shop/action area that is finger-friendly. Enemies now travel **bottom-to-top** across the map. In edit mode, tap **Place Path** or **Place Turret** to choose what to place, then tap on the map at the transparent preview position. A faint placement grid appears while editing to make snapping and lane planning clearer on mobile screens. Use right-drag in desktop builds to pan the camera and the wheel to zoom.

The main scene includes a basic camera and directional light so the level is visible without additional setup.
