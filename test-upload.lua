-- Test script to upload ANS-104 data items to up.arweave.net
-- This script creates a data item and provides instructions for uploading

local ans104 = require("ans104")

-- Configuration
local WALLET_PATH = os.getenv("ARWEAVE_WALLET") or "./wallet.json"
local BUNDLER_URL = "https://up.arweave.net"

-- Helper to save binary data
local function save_binary(filename, data)
    local file = io.open(filename, "wb")
    if not file then
        return false, "Could not open file for writing"
    end
    file:write(data)
    file:close()
    return true
end

-- Helper to decode base64
local function base64_decode(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

-- Main upload function
local function upload_data_item()
    print("ANS-104 Data Item Upload Test")
    print("=============================\n")
    
    -- Check wallet exists
    local wallet_file = io.open(WALLET_PATH, "r")
    if not wallet_file then
        print("Error: Wallet file not found at " .. WALLET_PATH)
        print("Set ARWEAVE_WALLET environment variable or place wallet.json in current directory")
        return false
    end
    wallet_file:close()
    
    -- Create test data as a string
    local test_id = math.random(100000, 999999)
    local test_data = string.format([[{
    "message": "Hello from ANS-104 Hype Plugin!",
    "timestamp": "%s",
    "test_id": %d,
    "plugin_info": {
        "name": "ans104",
        "version": "1.0.0",
        "framework": "hype"
    }
}]], os.date("%Y-%m-%d %H:%M:%S UTC"), test_id)
    
    -- Create data item
    print("Creating data item...")
    local params = {
        wallet = WALLET_PATH,
        data = test_data,
        tags = {
            ["Content-Type"] = "application/json",
            ["App-Name"] = "ANS104-Hype-Plugin",
            ["App-Version"] = "1.0.0",
            ["Test-ID"] = tostring(test_id),
            ["Created"] = os.date("%Y-%m-%d %H:%M:%S"),
            ["Type"] = "test-upload"
        }
    }
    
    local dataItem, err = ans104.create(params)
    if err then
        print("Error creating data item:", err)
        return false
    end
    
    print("✓ Data item created successfully!")
    print("  ID: " .. dataItem.id)
    print("  Size: " .. string.len(dataItem.data) .. " bytes")
    
    -- Count tags
    local tag_count = 0
    if dataItem.tags then
        for _ in pairs(dataItem.tags) do
            tag_count = tag_count + 1
        end
    end
    print("  Tags: " .. tag_count)
    
    -- Save raw data item for upload
    if dataItem.raw then
        local filename = "dataitem-" .. dataItem.id .. ".raw"
        local raw_binary = base64_decode(dataItem.raw)
        local ok, err = save_binary(filename, raw_binary)
        if ok then
            print("\n✓ Raw data item saved to: " .. filename)
            print("  File size: " .. string.len(raw_binary) .. " bytes")
            print("\nUpload using curl:")
            print("curl -X POST " .. BUNDLER_URL .. " \\")
            print("  -H 'Content-Type: application/octet-stream' \\")
            print("  --data-binary @" .. filename)
        else
            print("Warning: Could not save raw file:", err)
        end
    else
        print("\nWarning: No raw bundle data available")
    end
    
    -- Save JSON representation
    local json_filename = "dataitem-" .. dataItem.id .. ".json"
    local json_file = io.open(json_filename, "w")
    if json_file then
        -- Simple JSON formatting for display
        json_file:write("{\n")
        json_file:write('  "id": "' .. dataItem.id .. '",\n')
        json_file:write('  "signature": "' .. dataItem.signature .. '",\n')
        json_file:write('  "owner": "' .. dataItem.owner .. '",\n')
        json_file:write('  "tags": ' .. tag_count .. '\n')
        json_file:write("}\n")
        json_file:close()
        print("\n✓ JSON representation saved to: " .. json_filename)
    end
    
    -- Display upload instructions
    print("\n" .. string.rep("=", 50))
    print("UPLOAD INSTRUCTIONS")
    print(string.rep("=", 50))
    
    print("\n1. Direct upload to bundler:")
    print("   curl -X POST " .. BUNDLER_URL .. " \\")
    print("     -H 'Content-Type: application/octet-stream' \\")
    print("     --data-binary @" .. (dataItem.raw and ("dataitem-" .. dataItem.id .. ".raw") or json_filename))
    
    print("\n2. Check transaction status:")
    print("   curl " .. BUNDLER_URL .. "/tx/" .. dataItem.id .. "/status")
    
    print("\n3. View on Arweave (after processing):")
    print("   https://arweave.net/" .. dataItem.id)
    print("   https://viewblock.io/arweave/tx/" .. dataItem.id)
    
    print("\n4. View via gateway:")
    print("   https://gateway.arweave.net/" .. dataItem.id)
    
    print("\n" .. string.rep("=", 50))
    print("Note: Processing may take a few minutes.")
    print("The data item must be included in a bundle and mined.")
    
    return true
end

-- Run the upload test
local success = upload_data_item()

if success then
    print("\n✅ Test completed successfully!")
else
    print("\n❌ Test failed!")
    os.exit(1)
end