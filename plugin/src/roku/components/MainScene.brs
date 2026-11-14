sub init()
    initSlideshow()
    m.settings = m.top.FindNode("settings")
    m.menu = m.top.FindNode("settingsMenu")
    m.serverValue = m.top.FindNode("serverValue")
    m.delayValue = m.top.FindNode("delayValue")
    m.settingsStatus = m.top.FindNode("settingsStatus")
    m.menu.ObserveField("itemSelected", "settingSelected")
    m.saving = false
    m.top.SetFocus(true)
end sub

sub configurationChanged()
    applySlideshowConfiguration(m.top.configuration)
    if m.top.settingsOnly or m.server = ""
        openSettings()
    else
        resumeSlideshow()
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if m.settings.visible
        if key = "back"
            if not m.saving then closeSettings()
            return true
        end if
        return false
    end if
    if key = "right"
        navigate("/next")
        return true
    else if key = "left"
        navigate("/prev")
        return true
    else if key = "options"
        openSettings()
        return true
    else if key = "back"
        m.top.exitRequested = true
        return true
    end if
    return false
end function

sub openSettings()
    pauseSlideshow()
    m.editServer = m.server
    m.editDelay = m.delay
    m.settingsStatus.text = ""
    updateSettingsLabels()
    m.settings.visible = true
    m.menu.SetFocus(true)
end sub

sub updateSettingsLabels()
    m.serverValue.text = m.editServer
    if m.editServer = "" then m.serverValue.text = "Not configured"
    m.delayValue.text = m.editDelay.ToStr() + " seconds"
end sub

sub settingSelected()
    if m.saving then return
    selected = m.menu.itemSelected
    m.settingsStatus.text = ""
    if selected = 0 or selected = 1
        m.editingServer = selected = 0
        m.editor = CreateObject("roSGNode", "StandardKeyboardDialog")
        m.editor.buttons = ["Apply", "Cancel"]
        if m.editingServer
            m.editor.title = "Photo server base URL"
            m.editor.message = ["Include http:// or https:// and any path prefix."]
            m.editor.text = m.editServer
            m.editor.keyboardDomain = "alphanumeric"
        else
            m.editor.title = "Seconds between photos"
            m.editor.message = ["Enter a positive whole number of seconds."]
            m.editor.text = m.editDelay.ToStr()
            m.editor.keyboardDomain = "numeric"
        end if
        m.editor.ObserveField("buttonSelected", "editorButtonSelected")
        m.editor.ObserveField("wasClosed", "editorClosed")
        m.top.dialog = m.editor
    else if selected = 2
        if m.editServer = ""
            m.settingsStatus.text = "Enter a valid server URL before saving."
            return
        end if
        m.saving = true
        m.settingsStatus.text = "Saving..."
        print "Roku Memories: requesting settings save"
        m.top.saveRequested = { serverUrl: m.editServer, delay: m.editDelay }
    else
        closeSettings()
    end if
end sub

sub editorButtonSelected()
    if m.editor.buttonSelected = 0
        value = m.editor.text.Trim()
        if m.editingServer
            normalized = NormalizeServerUrl(value)
            if normalized = ""
                m.editor.message = ["Enter an http:// or https:// base URL without a query or fragment."]
                return
            end if
            m.editServer = normalized
        else
            if not ValidDelay(value)
                m.editor.message = ["Enter a positive whole number of seconds."]
                return
            end if
            m.editDelay = value.ToInt()
        end if
        updateSettingsLabels()
    end if
    m.editor.close = true
end sub

sub editorClosed()
    m.editor = invalid
    m.menu.SetFocus(true)
end sub

sub settingsSaved()
    result = m.top.saveResult
    print "Roku Memories: received settings save result: "; result.success
    m.saving = false
    if not result.success
        m.settingsStatus.text = "Could not save settings. Please try again."
        return
    end if
    applySlideshowConfiguration(result.configuration)
    closeSettings()
    ' Apply a changed server immediately, keeping the previous photo until ready.
    if not m.top.settingsOnly then requestImage("/next")
end sub

sub closeSettings()
    m.settings.visible = false
    if m.top.settingsOnly
        m.top.exitRequested = true
        return
    end if
    m.top.SetFocus(true)
    resumeSlideshow()
end sub
