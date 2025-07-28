-- Test script for publishing ANS-104 data items to Arweave
local ans104 = require("ans104")
local http = require("http") -- Assuming Hype has HTTP support

local function publish_data_item()
    print("Publishing ANS-104 Data Item to Arweave")
    print("=======================================\n")
    
    -- Note: Replace with your actual wallet path
    local wallet_path = "./wallet.json"
    
    -- Create a data item
    print("1. Creating data item...")
    local params = {
        wallet = wallet_path,
        data = "Hello from ANS-104 Hype Plugin! Timestamp: " .. os.date(),
        tags = {
            ["Content-Type"] = "text/plain",
            ["App-Name"] = "ANS104-Hype-Plugin",
            ["App-Version"] = "1.0.0",
            ["Unix-Time"] = tostring(os.time()),
            ["Published-Via"] = "up.arweave.net"
        }
    }
    
    local dataItem, err = ans104.create(params)
    if err then
        print("Error creating data item:", err)
        return false
    end
    
    print("✓ Data item created successfully")
    print("  ID:", dataItem.id)
    print("  Owner:", string.sub(dataItem.owner, 1, 20) .. "...")
    
    -- Prepare the bundle item for submission
    -- The bundler expects the data item in a specific format
    local bundleItem = {
        id = dataItem.id,
        signature = dataItem.signature,
        owner = dataItem.owner,
        target = dataItem.target or "",
        anchor = dataItem.anchor or "",
        tags = dataItem.tags,
        data = dataItem.data
    }
    
    -- Convert to JSON
    local json = require("json") -- Assuming Hype has JSON support
    local bundleJSON = json.encode(bundleItem)
    
    print("\n2. Publishing to up.arweave.net...")
    
    -- Submit to Arweave bundler
    local response, err = http.post({
        url = "https://up.arweave.net",
        headers = {
            ["Content-Type"] = "application/json",
            ["Accept"] = "application/json"
        },
        body = bundleJSON
    })
    
    if err then
        print("Error publishing to bundler:", err)
        return false
    end
    
    if response.status ~= 200 and response.status ~= 201 then
        print("Error: Bundler returned status", response.status)
        print("Response:", response.body)
        return false
    end
    
    print("✓ Data item published successfully!")
    
    -- Parse response
    local result = json.decode(response.body)
    if result and result.id then
        print("\n3. Transaction Details:")
        print("  Data Item ID:", dataItem.id)
        print("  View on Arweave:")
        print("  https://viewblock.io/arweave/tx/" .. dataItem.id)
        print("  https://arweave.net/" .. dataItem.id)
        print("\n  Note: It may take a few minutes for the data item to be indexed.")
    end
    
    return true
end

-- Alternative test using curl if HTTP module is not available
local function publish_data_item_curl()
    print("Publishing ANS-104 Data Item to Arweave (using curl)")
    print("===================================================\n")
    
    local wallet_path = "./wallet.json"
    
    -- Create data item
    print("1. Creating data item...")
    local params = {
        wallet = wallet_path,
        data = "Hello from ANS-104 Hype Plugin! Timestamp: " .. os.date(),
        tags = {
            ["Content-Type"] = "text/plain",
            ["App-Name"] = "ANS104-Hype-Plugin",
            ["App-Version"] = "1.0.0",
            ["Unix-Time"] = tostring(os.time())
        }
    }
    
    local dataItem, err = ans104.create(params)
    if err then
        print("Error creating data item:", err)
        return false
    end
    
    print("✓ Data item created successfully")
    print("  ID:", dataItem.id)
    
    -- Save data item to file for curl
    local bundleItem = {
        id = dataItem.id,
        signature = dataItem.signature,
        owner = dataItem.owner,
        target = dataItem.target or "",
        anchor = dataItem.anchor or "",
        tags = dataItem.tags,
        data = dataItem.data
    }
    
    -- Write to temporary file
    local tmpfile = "/tmp/ans104-dataitem.json"
    local file = io.open(tmpfile, "w")
    if not file then
        print("Error: Could not create temporary file")
        return false
    end
    
    -- Simple JSON encoding (for demo purposes)
    file:write('{\n')
    file:write('  "id": "' .. bundleItem.id .. '",\n')
    file:write('  "signature": "' .. bundleItem.signature .. '",\n')
    file:write('  "owner": "' .. bundleItem.owner .. '",\n')
    file:write('  "target": "' .. bundleItem.target .. '",\n')
    file:write('  "anchor": "' .. bundleItem.anchor .. '",\n')
    file:write('  "tags": [\n')
    for i, tag in ipairs(bundleItem.tags) do
        file:write('    {"name": "' .. tag.name .. '", "value": "' .. tag.value .. '"}')
        if i < #bundleItem.tags then
            file:write(',')
        end
        file:write('\n')
    end
    file:write('  ],\n')
    file:write('  "data": "' .. bundleItem.data .. '"\n')
    file:write('}\n')
    file:close()
    
    print("\n2. Publishing to up.arweave.net using curl...")
    print("Run this command:")
    print("curl -X POST https://up.arweave.net \\")
    print("  -H 'Content-Type: application/json' \\")
    print("  -d @" .. tmpfile)
    
    print("\nAfter publishing, view your data item at:")
    print("https://arweave.net/" .. dataItem.id)
    
    return true
end

-- Run the appropriate test
print("Choose test method:")
print("1. Use HTTP module (if available)")
print("2. Generate curl command")
print("\nRunning option 2 (curl command generation)...\n")

publish_data_item_curl()

-- Uncomment to try HTTP method if available:
-- publish_data_item()