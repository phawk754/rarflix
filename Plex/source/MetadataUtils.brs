
'* This logic reflects that in the PosterScreen.SetListStyle
'* Not using the standard sizes appears to slow navigation down
Function ImageSizes(viewGroup, contentType) As Object
	'* arced-square size	
	sdWidth = "223"
	sdHeight = "200"
	hdWidth = "300"
	hdHeight = "300"
	if viewGroup = "movie" OR viewGroup = "show" OR viewGroup = "season" OR viewGroup = "episode" then
	'* arced-portrait sizes
		sdWidth = "158"
		sdHeight = "204"
		hdWidth = "214"
		hdHeight = "306"
	elseif contentType = "episode" AND viewGroup = "episode" then
		'* flat-episodic sizes
		sdWidth = "166"
		sdHeight = "112"
		hdWidth = "224"
		hdHeight = "168"
	elseif viewGroup = "Details" then
		'* arced-square sizes
		sdWidth = "223"
		sdHeight = "200"
		hdWidth = "300"
		hdHeight = "300"
	
	endif
	sizes = CreateObject("roAssociativeArray")
	sizes.sdWidth = sdWidth
	sizes.sdHeight = sdHeight
	sizes.hdWidth = hdWidth
	sizes.hdHeight = hdHeight
	return sizes
End Function

Function createBaseMetadata(container, item) As Object
    metadata = CreateObject("roAssociativeArray")

    'print "createBaseMetadata: ";item@key

    server = container.server
    if item@machineIdentifier <> invalid then
        server = GetPlexMediaServer(item@machineIdentifier)
    end if

    metadata.Title = firstOf(item@title, item@name)

    ' There is a *massive* performance problem on grid views if the description
    ' isn't truncated.
    metadata.Description = truncateString(item@summary, 250, invalid)
    metadata.ShortDescriptionLine1 = metadata.Title
    metadata.ShortDescriptionLine2 = truncateString(item@summary, 250, invalid)
    metadata.Type = item@type
    metadata.Key = item@key
    metadata.Settings = item@settings

    metadata.viewGroup = container.ViewGroup

    sizes = ImageSizes(container.ViewGroup, item@type)                                                                                    
    art = firstOf(item@thumb, item@parentThumb, item@art, container.xml@thumb)
    if art <> invalid AND server <> invalid then
        metadata.SDPosterURL = server.TranscodedImage(container.sourceUrl, art, sizes.sdWidth, sizes.sdHeight)
        metadata.HDPosterURL = server.TranscodedImage(container.sourceUrl, art, sizes.hdWidth, sizes.hdHeight)
    end if

    metadata.sourceUrl = container.sourceUrl
    metadata.server = server

    metadata.HasDetails = false
    metadata.ParseDetails = baseParseDetails
    metadata.Refresh = baseMetadataRefresh

    return metadata
End Function

Function baseParseDetails()
    m.HasDetails = true
    return m
End Function

Sub baseMetadataRefresh(detailed=false)
End Sub

Function newSearchMetadata(container, item) As Object
    metadata = createBaseMetadata(container, item)

    metadata.type = "search"
    metadata.ContentType = "search"
    metadata.search = true
    metadata.prompt = item@prompt

    if metadata.SDPosterURL = invalid then
        metadata.SDPosterURL = "file://pkg:/images/icon-search.jpg"
        metadata.HDPosterURL = "file://pkg:/images/icon-search.jpg"
    end if

    return metadata
End Function

