# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Hype plugin project (ANS-104) that provides ANS-104 data item signing capabilities. The plugin wraps the Go library `goar` (https://github.com/everFinance/goar) into a Lua API for use within the Hype framework (https://twilson63.github.io/hype).

## Key Dependencies

- **Hype Framework**: https://twilson63.github.io/hype - The plugin framework this project extends
- **goar Library**: https://github.com/everFinance/goar - Go library for ANS-104 operations

## Plugin Structure

According to Hype plugin development guide, the plugin should follow this structure:

```
ans104/
├── hype-plugin.yaml    # Plugin manifest
├── plugin.lua          # Main plugin code with Lua API
├── ans104.go          # Go module wrapping goar
├── ans104.so          # Compiled shared library (generated)
├── test.lua           # Plugin tests
└── README.md          # Documentation
```

## Hype Plugin Requirements

### Manifest File (hype-plugin.yaml)
```yaml
name: "ans104"
version: "1.0.0"
type: "lua"
main: "plugin.lua"
description: "ANS-104 data item signing plugin for Hype"
author: "Your Name"
license: "MIT"
```

### Plugin API Pattern
Hype plugins should follow these patterns:
- Return multiple values (result, error) for error handling
- Validate all inputs
- Use optional parameters with defaults
- Implement proper state management

## ANS-104 Data Item Structure

Data items created by this plugin contain:
- `data`: String or binary content
- `tags`: Name-value key pairs
- `target`: Target address (optional)
- `anchor`: Anchor value (optional)

## Development Commands

```bash
# Build the Go shared library
go build -buildmode=c-shared -o ans104.so ans104.go

# Run Go tests
go test ./...

# Test the plugin with Hype
./hype run test.lua --plugins ans104=./

# Build with embedded plugin
./hype build app.lua --plugins ans104 -o app
```

## Plugin Implementation Notes

1. **Go-Lua Bridge**: The Go module must be compiled as a shared library (.so) that can be loaded by Lua via FFI
2. **Key Management**: Keys are managed by Hype wallet - the plugin should accept key data from Hype
3. **Error Handling**: Follow Hype's pattern of returning (result, error) tuples
4. **Data Handling**: Support both string and binary data types

## Example Plugin Usage

```lua
local ans104 = require("ans104")

-- Create and sign a data item
local dataItem, err = ans104.create({
    data = "Hello, Arweave!",
    tags = {
        ["Content-Type"] = "text/plain",
        ["App-Name"] = "MyApp"
    },
    target = "optional-target-address",
    anchor = "optional-anchor"
})

if err then
    print("Error:", err)
    return
end
```

## Testing Strategy

Create comprehensive tests in `test.lua` that:
- Test data item creation with various input types
- Verify signature generation
- Test error conditions
- Validate tag handling
- Test binary data support