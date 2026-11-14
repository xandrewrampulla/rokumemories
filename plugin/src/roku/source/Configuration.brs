function NormalizeServerUrl(value as String) as String
    value = value.Trim()
    ' Allow a reverse-proxy path prefix, but not a query or fragment.
    pattern = "^https?://([a-z0-9][a-z0-9.-]*|\[[0-9a-f:]+\])(:[0-9]{1,5})?(/[^?#\s]*)?$"
    if not CreateObject("roRegex", pattern, "i").IsMatch(value) then return ""
    while Right(value, 1) = "/"
        value = Left(value, Len(value) - 1)
    end while
    return value
end function

function ValidDelay(value as String) as Boolean
    value = value.Trim()
    if not CreateObject("roRegex", "^[0-9]+$", "").IsMatch(value) then return false
    ' The interval must fit the positive integer used by the slideshow.
    seconds = value.ToInt()
    return seconds > 0 and seconds.ToStr() = value
end function

function ReadConfiguration() as Object
    reg = CreateObject("roRegistrySection", "RokuMemories")
    delayText = reg.Read("Delay").Trim()
    delay = 15
    if ValidDelay(delayText) then delay = delayText.ToInt()
    return { serverUrl: NormalizeServerUrl(reg.Read("ServerUrl")), delay: delay }
end function

function SaveConfiguration(config as Object) as Boolean
    serverUrl = NormalizeServerUrl(config.serverUrl)
    delayText = config.delay.ToStr()
    if serverUrl = "" or not ValidDelay(delayText) then return false
    reg = CreateObject("roRegistrySection", "RokuMemories")
    if not reg.Write("ServerUrl", serverUrl) then return false
    if not reg.Write("Delay", delayText) then return false
    return reg.Flush()
end function
