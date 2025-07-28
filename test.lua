-- Test script for ANS-104 plugin
local ans104 = require("ans104")

local function test_create_data_item()
    print("Testing data item creation...")
    
    -- Note: This test requires a valid Arweave wallet file
    -- Replace with the actual path to your wallet
    local wallet_path = "./wallet.json"
    
    local params = {
        wallet = wallet_path,
        data = "Hello, Arweave! This is a test data item.",
        tags = {
            ["Content-Type"] = "text/plain",
            ["App-Name"] = "ANS104-Test",
            ["Version"] = "1.0.0"
        },
        target = "",  -- optional
        anchor = ""   -- optional
    }
    
    local result, err = ans104.create(params)
    
    if err then
        print("Error creating data item:", err)
        return false
    end
    
    print("Data item created successfully!")
    print("ID:", result.id)
    print("Owner:", result.owner)
    print("Signature:", string.sub(result.signature, 1, 50) .. "...")
    
    -- Print tags
    print("Tags:")
    for _, tag in ipairs(result.tags) do
        print("  " .. tag.name .. ": " .. tag.value)
    end
    
    return true
end

local function test_sign_data_item()
    print("\nTesting data item signing...")
    
    -- This would typically use an unsigned data item
    -- For this test, we'll use a mock JSON structure
    local wallet_path = "./wallet.json"
    
    local unsigned_item = [[{
        "id": "",
        "signature": "",
        "owner": "",
        "target": "",
        "anchor": "",
        "tags": [
            {"name": "Content-Type", "value": "text/plain"}
        ],
        "data": "VGVzdCBkYXRh"
    }]]
    
    local params = {
        wallet = wallet_path,
        item = unsigned_item
    }
    
    local result, err = ans104.sign(params)
    
    if err then
        print("Error signing data item:", err)
        return false
    end
    
    print("Data item signed successfully!")
    print("Signed item (truncated):", string.sub(result, 1, 100) .. "...")
    
    return true
end

-- Run tests
print("ANS-104 Plugin Test Suite")
print("=========================")

local tests_passed = 0
local tests_total = 0

-- Test 1: Create data item
tests_total = tests_total + 1
if test_create_data_item() then
    tests_passed = tests_passed + 1
end

-- Test 2: Sign data item
tests_total = tests_total + 1
if test_sign_data_item() then
    tests_passed = tests_passed + 1
end

print("\nTest Results: " .. tests_passed .. "/" .. tests_total .. " passed")

if tests_passed == tests_total then
    print("All tests passed!")
else
    print("Some tests failed.")
end