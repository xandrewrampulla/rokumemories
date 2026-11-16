' Run with the production Configuration, Slideshow, and MainScene scripts.
sub Main()
    m.failures = 0
    check(NormalizeServerUrl(" http://photos:8080/pictures/ ") = "http://photos:8080/pictures", "normalize path prefix and trailing slash")
    check(NormalizeServerUrl("http://") = "", "reject missing host")
    check(NormalizeServerUrl("http://photos/my albums") = "", "reject whitespace in base URL")
    check(NormalizeServerUrl("https://photos:8080/prefix") = "https://photos:8080/prefix", "accept HTTPS and a path prefix")
    check(NormalizeServerUrl("http://photos?token=x") = "", "reject query in base URL")
    check(ValidDelay("15"), "default delay accepted")
    check(not ValidDelay("0") and not ValidDelay("-1") and not ValidDelay("1.5"), "reject nonpositive or fractional delay")

    fixture()
    resumeSlideshow()
    check(m.loading and m.current = invalid, "initial request starts without a displayed photo")
    check(m.timer.control = "stop", "delay does not start during loading")
    check(Instr(1, m.pending.uri, "/next?") > 0, "first photo uses next endpoint")
    completeLoad()
    check(m.current.id = "posterA" and m.posterA.opacity = 1, "show first loaded photo")
    check(m.timer.control = "start" and m.timer.duration = 15, "start full delay after display")

    navigate("/next")
    check(m.pending.id = "posterB" and m.posterA.opacity = 1, "load hidden poster while retaining current photo")
    check(m.timer.control = "stop", "manual navigation stops previous delay")
    completeLoad()
    check(m.current.id = "posterB" and m.posterA.opacity = 0, "switch to replacement only after load")
    check(m.timer.control = "start", "reset delay after navigation")
    navigate("/prev")
    check(Instr(1, m.pending.uri, "/prev?") > 0, "left navigation uses prev endpoint")
    m.pending.loadStatus = "failed"
    posterLoaded(loadEvent(m.pending.id))
    check(m.current.id = "posterB" and m.posterB.opacity = 1, "failed image retains last photo")
    check(not m.loading and not m.spinner.visible, "failure clears loading state")
    check(m.timer.control = "start", "failure leaves slideshow able to continue")
    navigate("/next")
    loadFailed()
    check(m.posterB.opacity = 1 and not m.loading, "timeout retains last photo")

    navigate("/next")
    posterLoaded(loadEvent("unrelated"))
    check(m.loading and m.current.id = "posterB", "ignore other poster events")
    navigate("/prev")
    navigate("/next")
    check(m.navigation.Count() = 2, "queue rapid manual navigation")
    completeLoad()
    check(Instr(1, m.pending.uri, "/prev?") > 0 and m.navigation.Count() = 1, "preserve request order")
    completeLoad()
    check(Instr(1, m.pending.uri, "/next?") > 0 and m.navigation.Count() = 0, "dispatch next queued request")
    completeLoad()
    check(not m.loading and m.timer.control = "start", "resume timing after queued requests")

    navigate("/next")
    openSettings()
    check(m.settings.visible and m.paused, "settings pause slideshow")
    completeLoad()
    check(m.timer.control = "stop", "load completion cannot restart timer behind settings")
    m.editServer = "http://unsaved"
    m.editDelay = 99
    closeSettings()
    check(m.server = "http://photos" and m.delay = 15, "cancel discards edited settings")
    check(not m.paused and m.timer.control = "start", "cancel resumes slideshow")

    openSettings()
    m.top.saveResult = { success: false }
    settingsSaved()
    check(m.settings.visible and m.settingsStatus.text <> "", "save failure leaves settings open")
    m.top.saveResult = { success: true, configuration: { serverUrl: "http://new-server/prefix", delay: 20 } }
    settingsSaved()
    check(m.server = "http://new-server/prefix" and m.delay = 20, "apply successfully saved configuration")
    check(not m.settings.visible and m.loading, "save returns to slideshow and loads from new server")
    check(Instr(1, m.pending.uri, "http://new-server/prefix/next?") = 1, "retain configured base path")

    fixture()
    m.top.configuration = { serverUrl: "", delay: 15 }
    configurationChanged()
    check(m.settings.visible and not m.loading, "first launch opens settings before network requests")
    m.editingServer = true
    m.editor = { buttonSelected: 0, text: "bad URL", message: [], close: false }
    editorButtonSelected()
    check(m.editServer = "" and not m.editor.close, "invalid URL stays in editor without modifying settings")
    m.editor.text = "http://photos/prefix/"
    editorButtonSelected()
    check(m.editServer = "http://photos/prefix" and m.editor.close, "apply normalized server URL")
    m.editingServer = false
    m.editor = { buttonSelected: 0, text: "0", message: [], close: false }
    editorButtonSelected()
    check(m.editDelay = 15 and not m.editor.close, "invalid delay stays in editor")
    m.editor.text = "25"
    editorButtonSelected()
    check(m.editDelay = 25 and m.editor.close, "apply edited delay")
    m.menu.itemSelected = 2
    settingSelected()
    check(m.top.saveRequested.serverUrl = "http://photos/prefix" and m.top.saveRequested.delay = 25, "request persistence of both edited values")
    m.saving = false
    closeSettings()
    check(not m.loading, "unconfigured app does not request photos")
    onKeyEvent("options", true)
    check(m.settings.visible, "options opens settings")
    onKeyEvent("back", true)
    check(not m.settings.visible, "back cancels settings")
    onKeyEvent("back", false)
    check(not m.top.exitRequested, "ignore key release")
    onKeyEvent("back", true)
    check(m.top.exitRequested, "back exits normal application")

    fixture()
    m.top.settingsOnly = true
    configurationChanged()
    check(m.settings.visible and not m.loading, "screensaver settings entry opens configuration only")
    m.top.saveResult = { success: true, configuration: { serverUrl: "http://photos", delay: 30 } }
    settingsSaved()
    check(m.top.exitRequested and not m.loading, "save exits screensaver settings without starting slideshow")

    if m.failures > 0
        print "FAILURES: "; m.failures
        ' Cause a nonzero interpreter exit when any assertion failed.
        invalidFunctionForFailedTests()
    else
        print "PASS: slideshow timing, navigation, failures, and settings behavior"
    end if
end sub

sub check(condition as Boolean, description as String)
    if not condition
        print "FAIL: " + description
        m.failures = m.failures + 1
    end if
end sub

sub fixture()
    m.top = {
        configuration: { serverUrl: "http://photos", delay: 15 }
        settingsOnly: false
        exitRequested: false
        SetFocus: function(focus as Boolean) as Boolean
            return true
        end function
    }
    m.posterA = { id: "posterA", uri: "", opacity: 0, loadStatus: "none" }
    m.posterB = { id: "posterB", uri: "", opacity: 0, loadStatus: "none" }
    m.spinner = { visible: false }
    m.status = { text: "" }
    m.timer = { control: "stop", duration: 15 }
    m.timeout = { control: "stop" }
    m.current = invalid
    m.pending = invalid
    m.loading = false
    m.paused = true
    m.navigation = []
    m.requestId = 0
    m.server = "http://photos"
    m.delay = 15
    m.settings = { visible: false }
    m.menu = {
        SetFocus: function(focus as Boolean) as Boolean
            return true
        end function
    }
    m.serverValue = { text: "" }
    m.delayValue = { text: "" }
    m.settingsStatus = { text: "" }
    m.saving = false
end sub

sub completeLoad()
    m.pending.loadStatus = "ready"
    posterLoaded(loadEvent(m.pending.id))
end sub

function loadEvent(nodeId as String) as Object
    return {
        nodeId: nodeId
        GetNode: function() as String
            return m.nodeId
        end function
    }
end function
