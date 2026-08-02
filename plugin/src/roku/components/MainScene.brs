
sub init()
    
    m.posterA = m.top.findNode("posterA")
    m.posterB = m.top.findNode("posterB")

    m.spinner = m.top.findNode("spinner")

    m.fadeAIn = m.top.findNode("fadeAIn")
    m.fadeAOut = m.top.findNode("fadeAOut")

    m.fadeBIn = m.top.findNode("fadeBIn")
    m.fadeBOut = m.top.findNode("fadeBOut")


    m.current = "A"

    m.settings = m.top.findNode("settings")

    m.serverValue = m.top.findNode("serverValue")
    m.delayValue = m.top.findNode("delayValue")

    m.server = GetServerUrl()
    m.delay = GetDelay()


    m.posterB.observeField("loadStatus", "posterLoaded")

    m.timer = CreateObject("roSGNode", "Timer")
    m.timer.duration = m.delay
    m.timer.repeat = true
    m.timer.observeField("fire", "timerFired")
    m.top.appendChild(m.timer)

    m.top.setFocus(true)

    requestImage("/pictures/next")
    
end sub



sub timerFired()
    requestImage("/pictures/next")
end sub



sub requestImage(path)
    m.spinner.visible = true
    url = m.server + path  + "?t=" + CreateObject("roDateTime").AsSeconds().ToStr()
    m.posterB.uri = url
end sub



sub posterLoaded()

    if m.posterB.loadStatus <> "ready"
        return
    end if


    m.spinner.visible = false
    if m.current = "A"
        m.posterA.opacity = 0
        m.posterB.opacity = 1
        m.current = "B"
    else
        m.posterA.opacity = 1
        m.posterB.opacity = 0
        m.current = "A"
    end if

    m.timer.control="start"
end sub



function onKeyEvent(key, press) as Boolean

    print "on key pressed " + key
    if press = false
        return false
    end if

    ' Handle the back button and the ok button for the settings dialog
    if m.settings.visible then
        
        if key = "back" then
            closeSettings(false)
            return true
        end if

        if key = "OK" then
            closeSettings(true)
            return true
        end if

        return true

    end if


    if key="right"
        requestImage("/pictures/next")
        return true
    end if


    if key="left"
        requestImage("/pictures/back")
        return true
    end if


    if key="options"
        openSettings()
        return true
    end if

    return false
end function


' ==========================================
' Settings specific functions
' ==========================================


function settingsOnKeyEvent(key, press) as Boolean
    if key = "back" then
        closeSettings(false)
        return true
    end if

    if key = "OK" then
        closeSettings(true)
        return true
    end if

end function

sub openSettings()

    m.timer.control = "stop"

    m.settings.visible = true

    m.serverValue.text = m.server
    m.delayValue.text = stri(m.delay)

    m.settingsMode = true

    m.settings.setFocus(true)

end sub

sub closeSettings(save as Boolean)

    if save then
        ' later we'll save registry values here
    end if

    m.settings.visible = false

    m.settingsMode = false

    m.top.setFocus(true)

    m.timer.control = "start"

end sub




' --------------------------- -----------------------
' Common functions that are copied to other files
' ---------------------------------------------------




function GetRegistryObject() 
    return CreateObject("roRegistrySection", "RokuMemories")
end function

function GetServerUrl()

    reg = GetRegistryObject()

    value = reg.Read("ServerUrl")
    if value = invalid or value = ""
        return "http://192.168.68.144:8080"
    end if

    return value

end function


function SetServerUrl(value)

    reg = GetRegistryObject()

    reg.Write("ServerUrl", value)
    reg.Flush()

end function



function GetDelay()

    reg = GetRegistryObject()

    value = reg.Read("Delay")
    if value = invalid or value = ""
        return 15
    end if

    return val(value)

end function



function SetDelay(value)

    reg = GetRegistryObject()

    reg.Write("Delay", stri(value))
    reg.Flush()

end function
