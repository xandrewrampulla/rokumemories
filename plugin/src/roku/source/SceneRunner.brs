sub runScene(sceneName as String, settingsOnly as Boolean)
    screen = CreateObject("roSGScreen")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)
    scene = screen.CreateScene(sceneName)
    ' Initialize the screen before using SceneGraph interfaces from this thread.
    screen.Show()
    if sceneName = "MainScene"
        scene.settingsOnly = settingsOnly
        saveObserved = scene.ObserveField("saveRequested", port)
        exitObserved = scene.ObserveField("exitRequested", port)
        if not saveObserved or not exitObserved
            print "Roku Memories: could not register settings event observers"
            screen.Close()
            return
        end if
        print "Roku Memories: settings event observers ready"
    end if
    ' Keep registry I/O on the main thread, outside the render thread.
    scene.configuration = ReadConfiguration()

    while true
        msg = wait(0, port)
        if type(msg) = "roSGScreenEvent"
            if msg.IsScreenClosed() then return
        else if type(msg) = "roSGNodeEvent"
            fieldName = LCase(msg.GetField())
            print "Roku Memories: scene event "; fieldName
            if fieldName = "exitrequested"
                screen.Close()
                return
            else if fieldName = "saverequested"
                config = msg.GetData()
                print "Roku Memories: saving settings"
                saved = SaveConfiguration(config)
                print "Roku Memories: settings save completed: "; saved
                scene.saveResult = { success: saved, configuration: config }
            end if
        end if
    end while
end sub
