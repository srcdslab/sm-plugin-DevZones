# DevZones SourcePawn Plugin - Copilot Instructions

## Project Overview

DevZones is a comprehensive zone management system for SourceMod, designed for Source engine game servers. It provides a core zone creation and management framework with modular extension plugins for specific zone behaviors (anti-camp, teleport, damage control, etc.).

### Key Architecture
- **Core Plugin**: `devzones.sp` - Main zone management, creation, editing, and event handling
- **Extension Plugins**: Modular plugins that hook into zone events for specific functionality:
  - `devzones_ammo.sp` - Ammunition management in zones
  - `devzones_anticamp.sp` - Anti-camping enforcement
  - `devzones_hide.sp` - Player visibility control
  - `devzones_jail.sp` - Player confinement zones
  - `devzones_noblock.sp` - Collision blocking prevention
  - `devzones_nodamage.sp` - Damage immunity zones
  - `devzones_noentry.sp` - Access restriction zones
  - `devzones_nohud.sp` - HUD element hiding
  - `devzones_slap.sp` - Player slapping/punishment
  - `devzones_teleport.sp` - Teleportation zones
  - `devzones_test.sp` - Testing/debugging functionality
- **Native API**: `include/devzones.inc` - Provides native functions for third-party plugins

## Technical Environment

- **Language**: SourcePawn
- **Platform**: SourceMod 1.11.0+ (uses 1.11.0-git6966 in CI)
- **Build System**: SourceKnight (configured via `sourceknight.yaml`)
- **Compiler**: SourcePawn compiler (spcomp) via SourceKnight
- **Dependencies**: 
  - SourceMod base includes
  - MultiColors plugin (for colored chat output)
  - SDKTools for entity manipulation

## Development Workflow

### Build Process
1. **Local Development**: Use SourceKnight CLI for building
   ```bash
   # Build all plugins
   sourceknight build
   
   # Output goes to /addons/sourcemod/plugins/
   ```

2. **CI/CD**: Automated via GitHub Actions (`.github/workflows/ci.yml`)
   - Builds on Ubuntu 22.04
   - Creates packaged releases with plugins and configs
   - Supports both tag releases and "latest" builds from main/master

3. **Testing**: Deploy to development server with SourceMod for testing

### File Structure
```
addons/sourcemod/
├── scripting/
│   ├── devzones.sp              # Core plugin
│   ├── devzones_*.sp            # Extension plugins
│   └── include/devzones.inc     # Native API definitions
├── configs/dev_zones/           # Zone configuration files
│   └── *.zones.txt             # Map-specific zone definitions (KeyValues format)
└── plugins/                     # Compiled output (generated)
```

### Zone Configuration Format
Zone files use KeyValues format with the following structure:
```
"Zones"
{
    "0"  // Zone index
    {
        "name"          "teleport1"                              // Zone name
        "cordinate_a"   "-2860.968750 -1993.744995 853.323242"  // First corner position
        "cordinate_b"   "-2710.451904 -1872.031250 838.338318"  // Second corner position  
        "vis"           "0"                                      // Visibility (0=hidden, 1=visible)
        "team"          "0"                                      // Team restriction (0=all, 2=T, 3=CT)
    }
}

## Code Style & Standards

### SourcePawn Conventions
- **Indentation**: 4 spaces (using tabs)
- **Semicolons**: `#pragma semicolon 1` (required)
- **Declarations**: `#pragma newdecls required` (modern syntax)
- **Naming**:
  - Functions: `PascalCase` (e.g., `Zone_IsClientInZone`)
  - Variables: `camelCase` for local, `g_PascalCase` for globals
  - Constants: `UPPER_CASE` with defines (e.g., `#define MAX_ZONES 256`)

### Project-Specific Patterns
- **Global Variables**: Prefix with `g_` (e.g., `g_Zones`, `g_Editing`)
- **Arrays**: Use descriptive sizing (e.g., `[MAXPLAYERS + 1]`)
- **Handles**: Initialize as `INVALID_HANDLE`, use `delete` for cleanup
- **Version Management**: Single `#define VERSION` in core plugin
- **Colors**: Predefined color arrays for team-based zone visualization

### Documentation Requirements
- **Native Functions**: Document all parameters and return values in `.inc` file
- **Complex Logic**: Add inline comments for non-obvious code sections
- **No Excessive Headers**: Avoid unnecessary plugin description headers
- **Copyright**: Maintain existing GPL license headers

## Key Development Concepts

### Zone System Architecture
1. **Zone Storage**: Zones stored in StringMap with position data
2. **Client Tracking**: Per-client zone state tracking arrays
3. **Event System**: Forward-based notifications (`Zone_OnClientEntry`, `Zone_OnClientLeave`)
4. **Visual Feedback**: Beam sprites for zone boundaries with team colors

### Native API Functions
Key natives available for extension development:
- `Zone_IsClientInZone()` - Check if client is in a specific zone
- `Zone_isPositionInZone()` - Check if coordinates are within a zone
- `Zone_CheckIfZoneExists()` - Verify zone existence
- `Zone_GetZonePosition()` - Get zone center position for teleportation

### Common Operations
- **Zone Creation**: Two-point selection system with position storage
- **Zone Validation**: Bounds checking and name validation
- **Client State**: Track which zones clients are currently in
- **Extension Integration**: Extensions register for zone events via forwards

### Memory Management
- Use `delete` for StringMaps and ArrayLists (no null checking needed)
- Never use `.Clear()` on StringMaps/ArrayLists (creates memory leaks)
- Always recreate containers after deletion
- Proper handle cleanup in `OnPluginEnd()`

## Testing Guidelines

### Development Testing
1. **Local Server**: Test on development server with SourceMod installed
2. **Zone Creation**: Verify zone creation, editing, and deletion
3. **Extension Behavior**: Test each extension plugin's functionality
4. **Multi-Client**: Test with multiple players for interaction scenarios
5. **Map Changes**: Verify zone persistence and loading across map changes

### Validation Checklist
- [ ] Plugin compiles without warnings
- [ ] No memory leaks (check with SourceMod profiler)
- [ ] Zone boundaries display correctly
- [ ] Client entry/exit events fire properly
- [ ] Extension plugins respond to zone events
- [ ] Configuration files load correctly
- [ ] Commands work with proper permissions

## Common Tasks

### Adding New Zone Types
1. Create new plugin file: `devzones_newtype.sp`
2. Include devzones: `#include <devzones>`
3. Register for zone events: Hook `Zone_OnClientEntry`/`Zone_OnClientLeave`
4. Add to `sourceknight.yaml` targets list
5. Test zone behavior and cleanup

### Modifying Core Functionality
1. **Zone Structure Changes**: Update core plugin and native API
2. **New Natives**: Add to `devzones.inc` and implement in core
3. **Configuration**: Add new config options while maintaining backwards compatibility
4. **Version Bump**: Update `VERSION` define and tag repository

### Debugging Issues
1. **Enable Logging**: Use SourceMod's built-in logging
2. **Zone Visualization**: Use beam display for debugging boundaries
3. **Client State**: Check client zone tracking arrays
4. **Event Flow**: Verify forward calls between core and extensions

## Performance Considerations

### Optimization Guidelines
- **Timer Usage**: Minimize timers, prefer event-driven logic
- **Loop Optimization**: Cache loop bounds, avoid nested client loops
- **String Operations**: Minimize string manipulations in frequently called functions
- **Zone Checking**: Optimize position-in-zone calculations (O(1) vs O(n))
- **Visual Updates**: Batch beam sprite updates when possible

### Server Impact
- **Tick Rate**: Consider impact on server performance
- **Memory Usage**: Monitor zone storage growth with large configurations
- **Client Limits**: Test with maximum player counts
- **Map Complexity**: Account for maps with many zones

## Troubleshooting

### Common Issues
- **Plugin Load Order**: Ensure core plugin loads before extensions
- **Missing Dependencies**: Verify SourceMod version and MultiColors availability
- **Zone Persistence**: Check file permissions for config directory
- **Extension Conflicts**: Verify extensions don't interfere with each other

### Build Issues
- **SourceKnight Config**: Verify `sourceknight.yaml` dependencies
- **Include Paths**: Ensure include files are in correct directories
- **Version Compatibility**: Check SourceMod API compatibility

This plugin system is mature and stable - focus on maintaining compatibility and adding features through the established extension pattern rather than modifying core functionality extensively.