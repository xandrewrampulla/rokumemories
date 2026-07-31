

sub init()
    print "Running the screen saver"
    m.image1 = m.top.findNode("image1")
    m.image2 = m.top.findNode("image2")
    m.fade   = m.top.findNode("fade")
    m.fader  = m.top.findNode("fader")


    m.active = 1   ' which poster is currently visible

    m.image1.observeField("loadStatus", "onImageLoaded")
    m.image2.observeField("loadStatus", "onImageLoaded")

    ' initial load
    loadInto(m.image2)

    m.timer = m.top.findNode("mytimer")
    m.timer.ObserveField("fire","runtimer")
    m.timer.control = "start"
end sub

sub runtimer()

    print "Running the timer "; m.active
    if m.active = 1
        nextPoster = m.image2
    else
        nextPoster = m.image1
    end if

    loadInto(nextPoster)

end sub

sub loadInto(poster)
    ts = CreateObject("roDateTime").asSeconds().ToStr()
    poster.uri = "http://192.168.68.144:8080/pictures/next?ts=" + ts
    print "Changing poster to "; poster.uri
end sub

sub onImageLoaded(event as Object)

    status = event.getData()
    if status <> "ready"
        return
    end if

    print "Image finished loading → starting fade"
    nextPoster = image1
    oldPoster = image1
    if m.active = 1
        nextPoster = m.image2
        oldPoster = m.image1
        m.active = 2
    else
        nextPoster = m.image1
        oldPoster = m.image2
        m.active = 1
    end if

    print "Fader = "; m.fader
    print "oldPoster = "; oldPoster
    print "nextPoster = "; nextPoster
    print "new m.active = "; m.active


    oldPoster.opacity = 0
    nextPoster.opacity = 1


end sub
