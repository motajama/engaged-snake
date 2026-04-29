local Json = require("src.util.json")

local Localization = {}
Localization.__index = Localization

function Localization.new()
    return setmetatable({
        tables = {},
        current_language = "en",
    }, Localization)
end

function Localization:load(dataset)
    self.tables = {}
    for _, language in ipairs(dataset.languages or {}) do
        local path = string.format("datasets/base/lang/%s.json", language)
        local content = assert(love.filesystem.read(path), "missing localization file: " .. path)
        self.tables[language] = Json.decode(content)
    end
end

function Localization:set_language(language)
    if self.tables[language] then
        self.current_language = language
    end
end

function Localization:get(key, replacements)
    local current = self.tables[self.current_language] or {}
    local fallback = self.tables.en or {}
    local value = current[key] or fallback[key] or key

    if replacements then
        for name, replacement in pairs(replacements) do
            value = value:gsub("{" .. name .. "}", tostring(replacement))
        end
    end

    return value
end

return Localization
