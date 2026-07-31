sub init()
    m.top.functionName = "run"
end sub

sub run()
    url = m.top.url
    if url = "" then return

    http = CreateObject("roUrlTransfer")
    http.SetUrl(url)
    http.SetRequest("POST")
    http.AsyncPostFromString("")
    print "In theory made call to "; url
end sub
