-- Example: Publishing an ANS-104 data item to Arweave via bundlers
local ans104 = require("ans104")
local http = require("http")

-- Create and sign a data item
local dataItem, err = ans104.create({
    wallet = "./wallet.json",
    target = "",
    anchor = "",
    data = "",
    tags = {
        ["app-name"] = "hype-aos",
        ["created"] = tostring(os.time()),
        ["data-protocol"] = "ao",
        device = "process@1.0",
        ["execution-device"] = "lua@5.3a",
        -- ["execution-device"] = "stack@1.0",
        -- ["ao-types"] = "device-stack=csv",
        -- ["device-stack"] = "dedupe@1.0,lua@5.3a",
        ["module"] = "xVcnPK8MPmcocS6zwq1eLmM2KhfyarP8zzmz3UVi1g4",
        ["push-device"] = "push@1.0",
        ["scheduler"] = "V4sDeLYknWV03qY5L4SNcE8NYSba4cKJxo767hV0av4",
        ["authority"] = "V4sDeLYknWV03qY5L4SNcE8NYSba4cKJxo767hV0av4",
        ["scheduler-device"] = "scheduler@1.0",
        type = "Process",
        variant = "ao.N.1"
    }
})

if err then
    print("Error creating data item:", err)
    return
end

print("✅ Created data item with ID:", dataItem.id)

-- Save the raw data item to a file for upload
local filename = "dataitem-example.raw"
local file = io.open(filename, "wb")
if not file then
    print("❌ Failed to create output file")
    return
end

-- Decode base64 and write binary data
-- Using a simple base64 decode function
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

local rawData = base64_decode(dataItem.raw)
file:write(rawData)
file:close()

print("✅ Saved raw data item to:", filename)
print("")

-- Show upload commands for different bundlers
print("📤 To publish to Arweave, use one of these commands:")
print("")

local response = http.post("http://localhost:8734/push", rawData, {
  headers = {
    ["content-type"] = "application/ans104",
    ["codec-device"] = "ans104@1.0",
    ["accept-bundle"] = "true"
  }
})

print(response.body)
