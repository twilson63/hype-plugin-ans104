-- Simple test for ANS-104 plugin
local ans104 = require("ans104")

print("Testing ANS-104 plugin...")

-- Test parameters
local params = {
    wallet = "./wallet.json",
    data = "Hello, Arweave!",
    tags = {
        ["Content-Type"] = "text/plain",
        ["App-Name"] = "Test"
    }
}

-- Try to create a data item
local result, err = ans104.create(params)

if err then
    print("Error:", err)
else
    print("Success! Data item ID:", result.id)
end