-- Simple upload test for ANS-104 plugin
local ans104 = require("ans104")

print("Simple ANS-104 Upload Test")
print("==========================\n")

-- Create a simple data item
local params = {
    wallet = "./wallet.json",
    data = "Hello Arweave! This is a test from the ANS-104 Hype Plugin.",
    tags = {
        ["Content-Type"] = "text/plain"
    }
}

print("Creating data item...")
local result, err = ans104.create(params)

if err then
    print("Error:", err)
    os.exit(1)
end

print("✓ Data item created successfully!")
print("  ID: " .. result.id)

-- Save raw data if available
if result.raw then
    -- Decode base64
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local data = result.raw
    data = string.gsub(data, '[^'..b..'=]', '')
    local decoded = (data:gsub('.', function(x)
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
    
    local filename = "simple-" .. result.id .. ".raw"
    local file = io.open(filename, "wb")
    if file then
        file:write(decoded)
        file:close()
        print("  Raw file: " .. filename)
        print("  Size: " .. string.len(decoded) .. " bytes")
        
        print("\nTo upload:")
        print("curl -X POST https://node1.irys.xyz/tx \\")
        print("  -H 'Content-Type: application/octet-stream' \\")
        print("  --data-binary @" .. filename)
    end
end

print("\nView URLs (after upload):")
print("  https://arweave.net/" .. result.id)
print("  https://gateway.arweave.net/" .. result.id)