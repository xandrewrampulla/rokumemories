
sub init()
    m.videoPlayer = m.top.findNode("videoPlayer")

    content = CreateObject("roSGNode", "ContentNode")
    content.url = "http://192.168.68.138:8888/testvideo/index.m3u8"
    content.streamFormat = "hls"
    content.contentType = "episode"

    m.videoPlayer.content = content
    m.videoPlayer.control = "play"

    m.videoPlayer.observeField("state", "onVideoState")
    m.videoPlayer.observeField("errorCode", "onVideoError")
    m.videoPlayer.observeField("errorMsg", "onVideoError")

    ' make sure the video doesn't "steal" the focus, otherwise onKeyEvent won't fire
    m.videoPlayer.enableUI = false
    m.videoPlayer.focusable = false
    m.top.setFocus(true)

end sub

sub onVideoState()
    print "VIDEO STATE: "; m.videoPlayer.state
end sub

sub onVideoError()
    print "VIDEO ERROR CODE: "; m.videoPlayer.errorCode
    print "VIDEO ERROR MSG: "; m.videoPlayer.errorMsg
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    print "Which button was pressed: "; key; ", preesed="; press
    if press = false then return  false ' Only handle key down events

    if key = "left" then
        ' Send HTTP POST
        print "Left button was pressed"
        sendCommand("http://192.168.68.138:5006/back")
        return true
    else if key = "right" then
        print "Right button was pressed"
        sendCommand("http://192.168.68.138:5006/next")
        return true
    end if

    return false
end function

sub sendCommand(url as String)
    task = CreateObject("roSGNode", "HttpPostTask")
    task.url = url
    task.control = "run"
end sub

sub main()
    print "Launching as APPLICATION"

    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.SetMessagePort(m.port)

    scene = screen.CreateScene("MainScene")
    screen.Show()

    while true
        msg = wait(0, m.port)
    end while
end sub


sub RunScreenSaver()
    print "Launching as SCREENSAVER"

    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.SetMessagePort(m.port)

    scene = screen.CreateScene("ScreensaverScene")
    screen.Show()

    while true
        msg = wait(0, m.port)
    end while
end sub
