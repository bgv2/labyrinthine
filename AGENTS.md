# Pass It On

## Project Overview

This is a small, single-player 2D maze game built in Godot 4 using
GDScript.

The player navigates a dark maze while carrying a light. Light relays
are distributed throughout the maze. The player must press the interaction
input while near a relay to activate it. An activated relay takes over most
of the lighting, while the player's own light becomes much dimmer. The
player can explicitly take the light back at the active relay.

The game should remain intentionally small and simple. Avoid unnecessary
systems, abstractions, dependencies, or artwork requirements.

## Core Game Loop

1.  Start with the player's light at full brightness.
2.  Navigate the dark maze.
3.  Approach a relay and press the interaction input to activate it.
4.  The relay's PointLight2D turns on, and all other relays turn off.
5.  The player's PointLight2D is reduced to 20% of its original Energy.
6.  The active relay stays on if the player walks away.
7.  At a different relay, press interact to switch the light to it.
8.  At the active relay, press interact to take the light back.
9.  The relay turns off and the player's light returns to 100%.
10. Reaching the exit displays "YOU WIN!" and stops normal gameplay.

## Design Goals

-   Keep the game immediately understandable through its lighting
    behavior.
-   Make "pass it on" part of the actual mechanic.
-   Use darkness and light as the primary challenge.
-   Require deliberate interaction with relays.
-   Minimize artwork and use simple 2D shapes where possible.
-   Keep gameplay values easy to tune.
-   Keep the architecture beginner-friendly.

Do not add enemies, combat, procedural maze generation, inventories,
save systems, dialogue systems, or other mechanics unless explicitly
requested.

## Project Structure

Prefer:

-   `scenes/` --- Godot scene files.
-   `scripts/` --- GDScript files.
-   `assets/` --- Textures, audio, fonts, and other assets.
-   `project.godot` --- Project configuration.

Do not modify `.godot/`. Preserve an existing project structure when
practical.

## Technical Requirements

-   Godot 4.x only.
-   GDScript only.
-   Use normal Godot scene/node architecture.
-   No external plugins or dependencies.
-   No Godot 3 APIs.
-   Avoid unnecessary autoloads and global state.
-   Prefer signals when they make communication clearer.
-   Prefer readable, beginner-friendly code.
-   Expose tunable gameplay values in the Inspector.
-   Preserve existing nodes, textures, collision shapes, and lighting
    assets.
-   Do not replace existing artwork or lighting textures unless
    explicitly requested.

## Existing Scene

The level is expected to contain approximately:

``` text
Main
├── CanvasModulate
├── Maze
├── Player
│   ├── Sprite2D
│   ├── CollisionShape2D
│   └── PointLight2D
├── Relay(s)
│   ├── Sprite2D
│   ├── CollisionShape2D
│   └── PointLight2D
├── Exit
│   └── CollisionShape2D
└── UI
```

Exact names may differ. Inspect the actual project before writing node
references.

## Lighting

Use Godot's 2D lighting system rather than manually hiding maze tiles.

The scene uses a `CanvasModulate` to make the maze dark. The player's
PointLight2D provides normal illumination. Each relay has a PointLight2D
that starts disabled.

### Player Light

Store the player's starting PointLight2D Energy at runtime.

When a relay activates:

``` gdscript
player_light.energy = original_player_energy * 0.20
```

When the player takes the light back:

``` gdscript
player_light.energy = original_player_energy
```

Do not disable the player's light when a relay is active.

### Relay Light

Relays start with their PointLight2D disabled.

Activation:

``` gdscript
relay_light.enabled = true
```

Deactivation:

``` gdscript
relay_light.enabled = false
```

Do not replace the existing light texture.

## Player

Use `CharacterBody2D`.

The player should:

-   Move in two dimensions.
-   Use responsive movement.
-   Collide with maze walls.
-   Have a tunable movement speed.
-   Support keyboard and controller input.
-   Stop moving after winning.

A reasonable default speed is approximately 200 pixels per second.

## Input

Use Godot's Input Map.

Preferred actions:

-   `move_left`
-   `move_right`
-   `move_up`
-   `move_down`
-   `interact`

Keyboard defaults should include WASD and arrow keys.

Controller support should use standard joypad directional inputs.

`interact` should support:

-   Keyboard: E
-   Controller: South/A button

Preserve existing mappings if they already exist.

## Relays

Each relay is an `Area2D` with:

``` text
Relay
├── Sprite2D
├── CollisionShape2D
└── PointLight2D
```

A relay activates only when the player is inside its Area2D and presses
`interact`. Entering the area alone does not activate it.

On activation:

1.  Turn off every other relay.
2.  Mark this relay active and enable its PointLight2D.
3.  Dim the player's light to 20% of its original Energy.
4.  Make it the current active relay.

The player may activate a relay while another is active. Activating the new
relay turns off the previous relay and does not restore the player's light.

## Active Relay Behavior

The active relay remains on if the player walks away. Leaving its area does
not restore the player's light. The player can activate a different relay
by entering its area and pressing `interact`; this switches the active
relay and leaves the player's light dimmed.

## Taking the Light Back

When the player is inside the currently active relay's Area2D and presses
`interact`:

1.  Disable the relay's PointLight2D and mark it inactive.
2.  Restore the player's PointLight2D Energy.
3.  Clear the current active relay.

Interaction near an inactive relay activates it. Interaction outside all
relay areas does nothing.

## Multiple Relays

Only one relay can be active at a time. Activating a relay always turns off
every other relay. Switching relays must not restore the player's light.

## Interaction Prompt

When the player is inside a relay's Area2D, show a small UI prompt for enabling or disabling the relay.

Hide the prompt outside all relay areas and after winning.

## Exit

The existing Exit should be an `Area2D`.

When the player enters it:

1.  Mark the game as won.
2.  Display a centered `YOU WIN!` message.
3.  Stop player movement.
4.  Disable relay interaction.
5.  Hide the interaction prompt.

Do not automatically change scenes.

## Recommended Scripts

Keep the architecture small.

### `player.gd`

Responsible for:

-   Movement.
-   Movement input.
-   Player PointLight2D reference.
-   Storing original light Energy.
-   Applying the 80% dimming.
-   Restoring full light.
-   Preventing movement after winning.

### `relay.gd`

Responsible for:

-   Detecting player entry.
-   Activating its PointLight2D.
-   Tracking active state.
-   Tracking whether the player is in interaction range.
-   Handling taking the light back.
-   Communicating relay state to the level.

### `main.gd`

Responsible for:

-   Coordinating the current active relay.
-   Tracking win state.
-   Displaying the win UI.
-   Preventing interaction after winning.
-   Connecting relevant signals.

Avoid a global game manager unless genuinely necessary.

## Suggested Signals

Use signals where helpful, for example:

``` gdscript
signal relay_activated(relay)
signal light_taken_back(relay)
signal player_won
```

Do not create signals solely for architectural complexity.

## Maze

The maze is an existing `TileMapLayer`.

Do not implement procedural maze generation or alter the maze layout
unless requested.

Maze walls must have collision so the player cannot pass through them.

## Development Guidelines

When making changes:

1.  Inspect the existing project, scenes, and scripts first.
2.  Preserve existing behavior unless the requested feature requires
    changes.
3.  Make the smallest reasonable change.
4.  Avoid unrelated refactoring.
5.  Prefer readable code over clever code.
6.  Expose useful gameplay values in the Inspector.
7.  Do not add unrequested features.
8.  Use the existing directory structure.
9.  Check for parser errors after changes.
10. Run the project when possible.
11. Fix obvious runtime errors.
12. Report changed files and why.

## Testing Requirements

Verify that:

### Player

-   WASD works.
-   Arrow keys work.
-   Controller movement works when available.
-   Maze collision works.
-   Player light starts at full Energy.
-   Movement stops after winning.

### Relay

-   Relay lights start disabled.
-   Relays remain off until activated with `interact` while nearby.
-   Interact activates an inactive nearby relay.
-   Relay light turns on.
-   Player light becomes exactly 20% of its original Energy.
-   Leaving does not deactivate the relay.
-   Leaving does not restore the player's light.
-   Returning allows interaction.
-   Activating a different relay switches off the previous one.
-   E or controller interaction activates an inactive nearby relay.
-   E or controller interaction at the active relay returns the light.
-   Player light returns to its original Energy.
-   Interaction prompt appears and disappears correctly.

### Exit

-   Entering the exit displays `YOU WIN!`.
-   Movement stops after winning.
-   Relay interaction stops after winning.
-   The win message remains visible.

### Edge Cases

-   Multiple relays cannot create an inconsistent active state.
-   Leaving a relay never restores the player's light automatically.
-   Entering another relay does not accidentally restore the player's
    light.
-   Interact outside a relay does nothing.
-   Interact near an inactive relay activates it and turns off any other relay.
-   Winning hides the interaction prompt.

## Code Style

Prefer:

-   Clear variable names.
-   Small functions with one responsibility.
-   Typed variables and return types when useful.
-   `@onready` for stable node references.
-   `@export` for tunable values.

Avoid:

-   Deep inheritance hierarchies.
-   Singleton-heavy architecture.
-   Large manager classes.
-   Per-frame node searches.
-   Repeated `get_node()` calls when references can be cached.
-   Magic numbers for tunable gameplay values.

## Important Design Principle

Do not make substantial game-design decisions unless explicitly
requested.

The intended mechanic is:

``` text
FULL PLAYER LIGHT
        ↓
APPROACH RELAY
        ↓
PRESS INTERACT
        ↓
RELAY TURNS ON (OTHER RELAYS TURN OFF)
        ↓
PLAYER LIGHT = 20%
        ↓
PLAYER EXPLORES / MOVES AWAY
        ↓
RETURN TO ACTIVE RELAY
        ↓
PRESS INTERACT
        ↓
RELAY TURNS OFF
        ↓
PLAYER LIGHT = 100%
```

Preserve this behavior when implementing or modifying the game.

Implementation should support the intended design rather than replace
it.
