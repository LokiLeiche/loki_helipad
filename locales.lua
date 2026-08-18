local Locale = Locale

if not Locale[Config.Locale] then
    error("Unable to find locale file for language "..Config.Locale)
end

function _U(key, ...)
    local arg = {...}
    local translation = Locale[Config.Locale][key]
    if not translation then
        translation = Locale["en"][key] --fallback to english to allow partial translations
    end
    translation = string.format(translation, table.unpack(arg))
    return translation
end
