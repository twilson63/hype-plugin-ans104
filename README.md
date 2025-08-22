# ANS-104 Hype Plugin

A Hype plugin for creating and signing ANS-104 data items on Arweave using the [goar](https://github.com/everFinance/goar) library.

## Features

- Create ANS-104 data items with custom data and tags
- Sign data items using Arweave wallets
- Support for optional target and anchor fields
- Full integration with Hype framework

## Installation

1. Build the plugin:
```bash
go mod download
go build -buildmode=plugin -o ans104.so ans104.go
```

2. Use with Hype:
```bash
./hype run your-script.lua --plugins ans104=./
```

## Usage

### Creating a Data Item

```lua
local ans104 = require("ans104")

local dataItem, err = ans104.create({
    wallet = "./wallet.json",
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
else
    print("Data item created with ID:", dataItem.id)
end
```

### Signing an Existing Data Item

```lua
local ans104 = require("ans104")

local signedItem, err = ans104.sign({
    wallet = "./wallet.json",
    item = unsignedItemJSON
})

if err then
    print("Error:", err)
else
    print("Data item signed successfully")
end
```

## API Reference

### `ans104.create(params)`

Creates and signs a new ANS-104 data item.

**Parameters:**
- `wallet` (string, required): Path to Arweave wallet JSON file
- `data` (string, required): The data content
- `tags` (table, optional): Key-value pairs for tags
- `target` (string, optional): Target address
- `anchor` (string, optional): Anchor value

**Returns:**
- Success: Data item object with `id`, `signature`, `owner`, `target`, `anchor`, `tags`, and `data`
- Error: `nil` and error message

### `ans104.sign(params)`

Signs an existing unsigned data item.

**Parameters:**
- `wallet` (string, required): Path to Arweave wallet JSON file
- `item` (string, required): JSON string of the unsigned data item

**Returns:**
- Success: JSON string of the signed data item
- Error: `nil` and error message

## Testing

Run the test suite:

```bash
./hype run test.lua --plugins ans104=./
```

Test uploading to Arweave:

```bash
./hype run test-upload.lua --plugins ans104=./
```

Note: Tests require a valid Arweave wallet file at `./wallet.json`.

## Publishing to Arweave

The plugin creates ANS-104 data items that can be published to Arweave via bundler services.

### Supported Bundlers

The plugin has been tested and works with:
- ✅ **[Irys](https://irys.xyz)** - `node1.irys.xyz`
- ✅ **[Turbo](https://ardrive.io)** - `upload.ardrive.io`

### Example: Publishing a Data Item

```lua
local ans104 = require("ans104")

-- Create a data item
local dataItem, err = ans104.create({
    wallet = "./wallet.json",
    data = "Your data here",
    tags = {
        ["Content-Type"] = "text/plain"
    }
})

if not err then
    -- Save the raw data item for upload
    -- The dataItem.raw field contains base64-encoded binary data
    -- Decode and save it, then upload with curl:
    
    -- For Irys:
    -- curl -X POST https://node1.irys.xyz/tx \
    --   -H 'Content-Type: application/octet-stream' \
    --   --data-binary @dataitem.raw
    
    -- For Turbo:
    -- curl -X POST https://upload.ardrive.io/tx \
    --   -H 'Content-Type: application/octet-stream' \
    --   --data-binary @dataitem.raw
end
```

### Viewing Your Data

After uploading, your data will be available at:
- **Irys**: `https://gateway.irys.xyz/{data-item-id}`
- **Arweave** (after bundling): `https://arweave.net/{data-item-id}`

## Building from Source

1. Ensure you have Go 1.21+ installed
2. Clone this repository
3. Run:
   ```bash
   go mod download
   go build -buildmode=plugin -o ans104.so ans104.go
   ```

## License

MIT
