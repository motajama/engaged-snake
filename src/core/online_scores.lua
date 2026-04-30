local OnlineScores = {}
OnlineScores.__index = OnlineScores

local function load_config()
    local ok, config = pcall(require, "score_client_config")
    if ok and type(config) == "table" then
        return config
    end
    return {}
end

local function urlencode(value)
    return tostring(value or ""):gsub("\n", "\r\n"):gsub("([^%w%-_%.~])", function(char)
        return string.format("%%%02X", string.byte(char))
    end)
end

local function form_encode(fields)
    local parts = {}
    for key, value in pairs(fields) do
        parts[#parts + 1] = urlencode(key) .. "=" .. urlencode(value)
    end
    table.sort(parts)
    return table.concat(parts, "&")
end

function OnlineScores.new()
    return setmetatable({
        config = load_config(),
        last_status = nil,
    }, OnlineScores)
end

function OnlineScores:is_configured()
    return
        type(self.config.endpoint) == "string" and self.config.endpoint ~= "" and
        type(self.config.password) == "string" and self.config.password ~= ""
end

function OnlineScores:submit(entry)
    if not self:is_configured() then
        self.last_status = "disabled"
        return false, "disabled"
    end

    local use_https = self.config.endpoint:match("^https://") ~= nil
    local ok_http, http
    if use_https then
        ok_http, http = pcall(require, "ssl.https")
    else
        ok_http, http = pcall(require, "socket.http")
    end
    local ok_ltn12, ltn12 = pcall(require, "ltn12")
    if not ok_http or not ok_ltn12 then
        self.last_status = use_https and "https_unavailable" or "socket_unavailable"
        return false, self.last_status
    end
    if self.config.timeout then
        http.TIMEOUT = tonumber(self.config.timeout) or http.TIMEOUT
    end

    local body = form_encode({
        password = self.config.password,
        player_name = entry.name,
        score = entry.score,
        level_ended = entry.level_ended,
        victory = entry.victory and 1 or 0,
    })
    local response = {}
    local _, status_code = http.request({
        url = self.config.endpoint,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
            ["Content-Length"] = tostring(#body),
        },
        source = ltn12.source.string(body),
        sink = ltn12.sink.table(response),
    })

    local success = tonumber(status_code) and status_code >= 200 and status_code < 300
    self.last_status = success and "saved" or ("http_" .. tostring(status_code))
    return success, table.concat(response)
end

return OnlineScores
