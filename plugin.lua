-- ANS-104 Plugin for Hype
-- This file provides the Lua interface for the ANS-104 functionality

local M = {}

-- Simple JSON encoder for basic types
local function encode_json(obj)
    local t = type(obj)
    if t == "string" then
        return '"' .. obj:gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', '\\r') .. '"'
    elseif t == "number" or t == "boolean" then
        return tostring(obj)
    elseif t == "table" then
        local is_array = true
        local n = 0
        for k, v in pairs(obj) do
            n = n + 1
            if type(k) ~= "number" or k ~= n then
                is_array = false
                break
            end
        end
        
        local parts = {}
        if is_array then
            for i, v in ipairs(obj) do
                table.insert(parts, encode_json(v))
            end
            return "[" .. table.concat(parts, ",") .. "]"
        else
            for k, v in pairs(obj) do
                if type(k) == "string" then
                    table.insert(parts, encode_json(k) .. ":" .. encode_json(v))
                end
            end
            return "{" .. table.concat(parts, ",") .. "}"
        end
    elseif obj == nil then
        return "null"
    else
        error("Cannot encode type: " .. t)
    end
end

-- Simple JSON decoder (basic implementation)
local function decode_json(str)
    -- This is a very basic decoder that handles the CLI output
    -- For production use, consider a proper JSON library
    local ok, result = pcall(loadstring("return " .. str:gsub('"([^"]+)":', '[%1]=')))
    if ok and result then
        return result
    end
    
    -- Try to parse as a simple object
    local obj = {}
    for key, value in str:gmatch('"([^"]+)":"([^"]*)"') do
        obj[key] = value
    end
    
    -- Check for error field
    local error_match = str:match('"error":"([^"]+)"')
    if error_match then
        obj.error = error_match
    end
    
    -- Extract common fields
    obj.id = str:match('"id":"([^"]+)"') or obj.id
    obj.signature = str:match('"signature":"([^"]+)"') or obj.signature
    obj.owner = str:match('"owner":"([^"]+)"') or obj.owner
    obj.data = str:match('"data":"([^"]+)"') or obj.data
    obj.raw = str:match('"raw":"([^"]+)"') or obj.raw
    
    return obj
end

-- Helper function to call the Go CLI tool
local function callGoCLI(params)
    -- Convert params to JSON
    local paramsJSON = encode_json(params)
    
    -- Build command
    local cmd = string.format('./ans104-cli -params=%q', paramsJSON)
    
    -- Execute command
    local handle = io.popen(cmd, 'r')
    if not handle then
        return nil, "Failed to execute ans104-cli"
    end
    
    local output = handle:read('*all')
    local success = handle:close()
    
    if not success then
        return nil, "ans104-cli execution failed"
    end
    
    -- Parse JSON output
    local result = decode_json(output)
    if not result then
        return nil, "Failed to parse CLI output"
    end
    
    if result.error then
        return nil, result.error
    end
    
    return result
end

-- Create and sign a new ANS-104 data item
function M.create(params)
    if not params then
        return nil, "params table required"
    end
    
    if not params.wallet then
        return nil, "wallet path required"
    end
    
    if not params.data then
        return nil, "data required"
    end
    
    -- Call the Go CLI tool
    return callGoCLI(params)
end

-- Sign an existing data item
function M.sign(params)
    -- Not implemented in CLI version
    return nil, "Sign operation not currently supported - use create instead"
end

-- Get a bundle containing the data item for submission
function M.bundle(params)
    if not params then
        return nil, "params table required"
    end
    
    -- For now, use create which returns the data item
    -- Bundle creation would need to be added to the CLI
    return callGoCLI(params)
end

return M