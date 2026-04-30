local Json = require("src.util.json")

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

local function request_transport(url)
    local use_https = url:match("^https://") ~= nil
    local ok_http, http
    if use_https then
        ok_http, http = pcall(require, "ssl.https")
    else
        ok_http, http = pcall(require, "socket.http")
    end
    local ok_ltn12, ltn12 = pcall(require, "ltn12")
    if not ok_http or not ok_ltn12 then
        return nil, nil, use_https and "https_unavailable" or "socket_unavailable"
    end
    return http, ltn12, nil
end

local function scores_endpoint(config)
    if type(config.scores_endpoint) == "string" and config.scores_endpoint ~= "" then
        return config.scores_endpoint
    end
    if type(config.endpoint) == "string" and config.endpoint ~= "" then
        return config.endpoint:gsub("submit%.php$", "scores.php")
    end
    return nil
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

    local http, ltn12, transport_error = request_transport(self.config.endpoint)
    if transport_error then
        self.last_status = transport_error
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

function OnlineScores:fetch_scores()
    local endpoint = scores_endpoint(self.config)
    if not endpoint then
        self.last_status = "disabled"
        return false, "disabled"
    end

    local http, ltn12, transport_error = request_transport(endpoint)
    if transport_error then
        self.last_status = transport_error
        return false, transport_error
    end
    if self.config.timeout then
        http.TIMEOUT = tonumber(self.config.timeout) or http.TIMEOUT
    end

    local response = {}
    local _, status_code = http.request({
        url = endpoint,
        method = "GET",
        sink = ltn12.sink.table(response),
    })

    if not (tonumber(status_code) and status_code >= 200 and status_code < 300) then
        self.last_status = "http_" .. tostring(status_code)
        return false, self.last_status
    end

    local ok, decoded = pcall(Json.decode, table.concat(response))
    if not ok or type(decoded) ~= "table" or decoded.ok ~= true or type(decoded.scores) ~= "table" then
        self.last_status = "invalid_response"
        return false, "invalid_response"
    end

    local scores = {}
    for index, entry in ipairs(decoded.scores) do
        scores[index] = {
            name = entry.player_name or entry.name or "PLY",
            score = tonumber(entry.score) or 0,
            level_ended = tonumber(entry.level_ended) or 1,
            victory = entry.victory == true or entry.victory == 1,
        }
    end

    self.last_status = "online"
    return true, scores
end

return OnlineScores
