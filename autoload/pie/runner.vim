
func! pie#runner#Get()
    " We always use the simple runner right now. See the comments in daemon
    " for an explanation
    return pie#runner#simple#Get()
endfunc
