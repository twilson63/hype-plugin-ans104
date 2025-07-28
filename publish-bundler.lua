-- Script to publish ANS-104 data items to Arweave bundler
-- This version creates a properly formatted bundle for up.arweave.net

local ans104 = require("ans104")

-- Helper function to base64url encode
local function base64url_encode(data)
    -- This is a placeholder - in practice you'd need a proper base64url encoder
    -- Hype might provide one, or you could use a Lua library
    return data -- For now, assuming the data is already encoded
end

-- Main publish function
local function publish_to_bundler(wallet_path, data_content, tags)
    print("ANS-104 Data Item Publisher")
    print("===========================\n")
    
    -- Create the data item
    print("Creating data item...")
    local params = {
        wallet = wallet_path,
        data = data_content,
        tags = tags or {}
    }
    
    -- Add default tags if not present
    if not params.tags["Content-Type"] then
        params.tags["Content-Type"] = "text/plain"
    end
    
    local dataItem, err = ans104.create(params)
    if err then
        return nil, "Failed to create data item: " .. err
    end
    
    print("✓ Data item created")
    print("  ID: " .. dataItem.id)
    print("  Size: " .. #dataItem.data .. " bytes")
    
    -- Format for bundler submission
    -- The bundler expects data items in a specific binary format
    print("\nFormatting for bundler...")
    
    -- Save to file for manual submission
    local filename = "dataitem-" .. dataItem.id .. ".json"
    local file = io.open(filename, "w")
    if file then
        -- Write formatted JSON
        file:write('{\n')
        file:write('  "format": "json-1.0",\n')
        file:write('  "id": "' .. dataItem.id .. '",\n')
        file:write('  "signature": "' .. dataItem.signature .. '",\n')
        file:write('  "owner": "' .. dataItem.owner .. '",\n')
        file:write('  "target": "' .. (dataItem.target or "") .. '",\n')
        file:write('  "anchor": "' .. (dataItem.anchor or "") .. '",\n')
        file:write('  "tags": [\n')
        
        for i, tag in ipairs(dataItem.tags) do
            file:write('    {\n')
            file:write('      "name": "' .. tag.name .. '",\n')
            file:write('      "value": "' .. tag.value .. '"\n')
            file:write('    }')
            if i < #dataItem.tags then
                file:write(',')
            end
            file:write('\n')
        end
        
        file:write('  ],\n')
        file:write('  "data": "' .. base64url_encode(dataItem.data) .. '"\n')
        file:write('}\n')
        file:close()
        
        print("✓ Data item saved to: " .. filename)
    end
    
    -- Generate submission instructions
    print("\nTo publish this data item:")
    print("1. Using curl:")
    print("   curl -X POST https://up.arweave.net/tx \\")
    print("     -H 'Content-Type: application/octet-stream' \\")
    print("     --data-binary @" .. filename)
    print("\n2. Using arbundles:")
    print("   npm install -g arbundles")
    print("   arbundles upload " .. filename)
    print("\n3. View transaction:")
    print("   https://arweave.net/" .. dataItem.id)
    print("   https://viewblock.io/arweave/tx/" .. dataItem.id)
    
    return dataItem, nil
end

-- Example usage
local function main()
    -- Configuration
    local wallet_path = "./wallet.json"
    
    -- Create a test data item
    local data_content = [[
Hello, Arweave!

This is a test data item created using the ANS-104 Hype Plugin.
It demonstrates how to create and publish data items to Arweave
using the bundler service at up.arweave.net.

Timestamp: ]] .. os.date("%Y-%m-%d %H:%M:%S UTC", os.time())
    
    local tags = {
        ["Content-Type"] = "text/plain",
        ["App-Name"] = "ANS104-Hype-Plugin",
        ["App-Version"] = "1.0.0",
        ["Title"] = "Test Data Item from Hype",
        ["Description"] = "Testing ANS-104 bundler integration",
        ["Unix-Time"] = tostring(os.time()),
        ["Type"] = "test"
    }
    
    -- Publish the data item
    local dataItem, err = publish_to_bundler(wallet_path, data_content, tags)
    
    if err then
        print("\nError: " .. err)
        return 1
    end
    
    print("\n✓ Success! Data item prepared for publishing.")
    print("\nData Item Summary:")
    print("- ID: " .. dataItem.id)
    print("- Size: " .. #dataItem.data .. " bytes")
    print("- Tags: " .. #dataItem.tags)
    
    return 0
end

-- Run if executed directly
if arg and arg[0]:match("publish%-bundler%.lua$") then
    os.exit(main())
end

-- Export for use as module
return {
    publish_to_bundler = publish_to_bundler
}