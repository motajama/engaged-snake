local Json = require("src.util.json")

local files = {
    "datasets/base/dataset.json",
    "datasets/base/lang/en.json",
    "datasets/base/lang/cs.json",
}

for _, path in ipairs(files) do
    local file, open_error = io.open(path, "rb")
    if not file then
        error(string.format("failed to open %s: %s", path, tostring(open_error)))
    end

    local content = file:read("*a")
    file:close()
    Json.decode(content)
end
