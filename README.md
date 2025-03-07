# Osmosis
## Game Overview
This game simulates the selective permeability of a cell membrane, allowing players to control which molecules can pass through the membrane. The objective is to separate red and blue molecules to opposite sides of the screen within a time limit.

## Design
* Molecule Physics Engine: Collision detection and velocity management for multiple moving objects
* Membrane Logic: Selective permeability based on molecule type and membrane state
* State Machine: 5-state FSM for game flow control
* VGA Controller: 640x480 resolution display
* Timer Implementation: Multi-level counters for frame, half-second, and second timing used for game logic and flashing displays
* Board inputs for gameplay and 7-segment hex displays for timer output

<p align = "center">
<img src="https://github.com/user-attachments/assets/19fb5531-a641-4e9b-a0c4-91ad3fec4fc9">
</p>
