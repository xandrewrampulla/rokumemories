' Shared photo loading and timing for the normal app and screensaver.
sub initSlideshow()
    m.posterA = m.top.FindNode("posterA")
    m.posterB = m.top.FindNode("posterB")
    m.spinner = m.top.FindNode("spinner")
    m.status = m.top.FindNode("status")
    m.timer = m.top.FindNode("slideTimer")
    m.timeout = m.top.FindNode("loadTimeout")
    m.posterA.ObserveField("loadStatus", "posterLoaded")
    m.posterB.ObserveField("loadStatus", "posterLoaded")
    m.timer.ObserveField("fire", "timerFired")
    m.timeout.ObserveField("fire", "loadFailed")
    m.current = invalid
    m.pending = invalid
    m.loading = false
    m.paused = true
    m.navigation = []
    m.requestId = 0
    m.server = ""
    m.delay = 15
end sub

sub applySlideshowConfiguration(config as Object)
    m.timer.control = "stop"
    m.timeout.control = "stop"
    m.loading = false
    if m.pending <> invalid then m.pending.uri = ""
    m.pending = invalid
    m.navigation = []
    m.spinner.visible = false
    m.server = config.serverUrl
    m.delay = config.delay
    if m.server = ""
        m.status.text = "Configure the photo server URL in Roku Memories settings."
    else
        m.status.text = ""
    end if
end sub

sub timerFired()
    requestImage("/next")
end sub

sub navigate(path as String)
    m.timer.control = "stop"
    ' Serialize rapid key presses so next/prev calls reach the server in order.
    if m.loading
        m.navigation.Push(path)
    else
        requestImage(path)
    end if
end sub

sub requestImage(path as String)
    if m.paused or m.server = "" or m.loading then return
    m.timer.control = "stop"
    if m.current = invalid
        m.pending = m.posterA
    else if m.current.id = "posterA"
        m.pending = m.posterB
    else
        m.pending = m.posterA
    end if
    m.pending.opacity = 0
    m.loading = true
    m.spinner.visible = true
    m.requestId = m.requestId + 1
    stamp = CreateObject("roDateTime").AsSeconds().ToStr()
    m.timeout.control = "start"
    ' A unique query prevents caching of these stateful image endpoints.
    m.pending.uri = m.server + path + "?request=" + stamp + "-" + m.requestId.ToStr()
end sub

sub posterLoaded(event as Object)
    if not m.loading then return
    if event.GetNode() <> m.pending.id then return
    status = m.pending.loadStatus
    if status = "failed"
        loadFailed()
    else if status = "ready"
        m.timeout.control = "stop"
        m.loading = false
        m.spinner.visible = false
        if m.current <> invalid then m.current.opacity = 0
        m.pending.opacity = 1
        m.current = m.pending
        m.pending = invalid
        m.status.text = ""
        finishRequest()
    end if
end sub

sub loadFailed()
    if not m.loading then return
    m.loading = false
    m.timeout.control = "stop"
    m.spinner.visible = false
    m.pending.uri = ""
    m.pending = invalid
    ' Never hide or replace the last successfully displayed photo on failure.
    if m.current = invalid
        m.status.text = "Unable to load a photo. Check the server URL and connection."
    end if
    finishRequest()
end sub

sub finishRequest()
    if m.paused then return
    if m.navigation.Count() > 0
        requestImage(m.navigation.Shift())
    else
        startSlideTimer()
    end if
end sub

sub startSlideTimer()
    if m.paused or m.server = "" then return
    m.timer.duration = m.delay
    m.timer.control = "start"
end sub

sub pauseSlideshow()
    m.paused = true
    m.navigation = []
    m.timer.control = "stop"
end sub

sub resumeSlideshow()
    m.paused = false
    if m.loading then return
    if m.current = invalid
        requestImage("/next")
    else
        startSlideTimer()
    end if
end sub
