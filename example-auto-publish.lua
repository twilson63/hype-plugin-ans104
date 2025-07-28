-- Example: Automatically publish an ANS-104 data item to Arweave
local ans104 = require("ans104")

-- Configuration
local BUNDLER_URL = "https://node1.irys.xyz/tx"  -- or "https://upload.ardrive.io/tx"

-- Create and sign a data item
print("🔨 Creating ANS-104 data item...")
local dataItem, err = ans104.create({
    wallet = "./wallet.json",
    data = "Hello from Hype ANS-104! Published at " .. os.date(),
    tags = {
        ["Content-Type"] = "text/plain",
        ["App-Name"] = "hype-ans104-demo",
        ["Published-Date"] = os.date("%Y-%m-%d %H:%M:%S")
    }
})

if err then
    print("❌ Error creating data item:", err)
    return
end

print("✅ Created data item with ID:", dataItem.id)

-- Decode base64 to get raw binary
local b64 = require("b64")
local rawData = b64.decode(dataItem.raw)

-- Save to temporary file for curl
local tmpFile = "/tmp/dataitem-" .. dataItem.id .. ".raw"
local file = io.open(tmpFile, "wb")
if not file then
    print("❌ Failed to create temp file")
    return
end
file:write(rawData)
file:close()

-- Upload using curl
print("📤 Uploading to bundler:", BUNDLER_URL)
local cmd = string.format(
    "curl -s -X POST %s -H 'Content-Type: application/octet-stream' --data-binary @%s",
    BUNDLER_URL,
    tmpFile
)

local handle = io.popen(cmd, "r")
local response = handle:read("*a")
handle:close()

-- Clean up temp file
os.remove(tmpFile)

-- Check response
if response and response ~= "" then
    print("✅ Upload response:", response)
    print("")
    print("🌐 View your data at:")
    print("   https://gateway.irys.xyz/" .. dataItem.id)
    print("   https://arweave.net/" .. dataItem.id .. " (after bundling)")
else
    print("❌ Upload may have failed - no response received")
end