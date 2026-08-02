
function GetServerUrl()
    return "http://192.168.1.100:8080"
end function


#if false

function GetRegistryObject() 
    return CreateObject("roRegistrySection", "RokuMemories")
end function

function GetServerUrl()

    reg = GetRegistryObject()

    value = reg.Read("ServerUrl")
    if value = invalid or value = ""
        return "http://192.168.1.100:8080"
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


#end if