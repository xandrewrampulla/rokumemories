sub init()
    initSlideshow()
end sub

sub configurationChanged()
    applySlideshowConfiguration(m.top.configuration)
    ' A running screensaver never opens interactive settings or handles keys.
    resumeSlideshow()
end sub
