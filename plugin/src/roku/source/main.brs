' NOTE: this might be lower case main
sub Main()

    screen = CreateObject("roSGScreen")

    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)

    screen.CreateScene("MainScene")

    screen.Show()

    while true

        msg = wait(0, port)
        if type(msg) = "roSGScreenEvent"
            if msg.isScreenClosed()
                return
            end if
        end if

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
        if type(msg) = "roSGScreenEvent"
            if msg.isScreenClosed()
                return
            end if
        end if
    end while
end sub
