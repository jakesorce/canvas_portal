$ ->
  $loadingDiv = $('#loading')
  $portalForm = $('#portal_form')
  $branches = $('#branches')
  $basicOptionsDropdown = $('#basic_option_dropdown_text')
  $advancedOptionsDropdown = $('#advanced_option_dropdown_text')
  $branchContents = $('#branch_contents')
  $patchsetContents = $('#patchset_contents')
  $multiplePatchsetContents = $('#multiple_patchset_contents')
  $multiplePluginsContents = $('#multiple_plugins_contents')
  $pluginPatchsetContents = $('#plugin_patchset_contents')
  $versionModal = $('#version_modal')
  $errorLogHolder = $('#error_log_holder')
  $canvasnetPatchsetContents = $('#canvasnet_patchset_contents')
  dropdownMessage = 'What do you want to do?'

  $('#footer_img').effect("highlight", {}, 1500)
  
  enableBeforeUnload = ->
    window.onbeforeunload = (e) ->
      "You are in the middle of generating an environment, do you really want to leave?"

  disableBeforeUnload = ->
    window.onbeforeunload = null

  confirmation = (message) ->
    confirm(message)

  disableElement = (element) ->
    element.attr('disabled', 'disabled')

  enableElement = (element) ->
    element.removeAttr('disabled')

  closePatchset = ->
    $('.remove_patchset').bind 'click', ->
      $addPatchset = $('#add_patchset')
      $(@).parent().parent().remove()
      enableElement($addPatchset) if $addPatchset.is(':disabled') 

  closePlugin = ->
    $('.remove_plugin').bind 'click', ->
      $addPlugin = $('#add_plugin')
      $(@).parent().parent().remove()
      enableElement($addPlugin) if $addPlugin.is(':disabled') 

  hideContents = ->
    $patchsetContents.slideToggle() if $patchsetContents.is(':visible')
    $branchContents.slideToggle() if $branchContents.is(':visible')
    $pluginPatchsetContents.slideToggle() if $pluginPatchsetContents.is(':visible')
    $multiplePatchsetContents.slideToggle() if $multiplePatchsetContents.is(':visible')
    $multiplePluginsContents.slideToggle() if $multiplePluginsContents.is(':visible')
    $errorLogHolder.slideToggle() if $errorLogHolder.is(':visible')
    $canvasnetPatchsetContents.slideToggle() if $canvasnetPatchsetContents.is(':visible')
   
  dropdownOptionClicked = (e, elementClicked, dropdown) ->
    hideContents()
    e.preventDefault()
    setDropdownText(dropdown, elementClicked.text())

  validatePlugin = (pluginElement) -> 
    isValid = 0
    if pluginElement.val().length > 0
      regex = /^git\s(fetch|pull)\sssh:\/\/[a-zA-Z]*@gerrit.instructure.com:29418\/\S*\srefs\/changes\/\d+\/\d+\/\d+/
      pattern = new RegExp(regex)
      if pattern.test(pluginElement.val().trim()) is false
        alert('invalid plugin')
        pluginElement.val('')
        isValid = 1
    else
      alert('cannot have an empty plugin')
      isValid = 1
    isValid

  validatePatchset = (patchsetElement) ->
    isValid = 0
    if patchsetElement.val().length > 0
      digitRegEx = /^\d+\/\d+\/\d+$/
      pattern = new RegExp(digitRegEx)
      if pattern.test(patchsetElement.val().trim()) is false
        alert('invalid patchset')
        patchsetElement.val('')
        isValid = 1
    else
      alert('cannot have an empty patchset number')
      isValid = 1
    isValid

  openLoadingScreen = (loadingText, action) ->
    setLoadingText(loadingText)
    $('#game').prepend('<iframe src="http://ryanflorence.com/snake" width="800" height="600"></iframe>')
    $loadingDiv.bPopup
      modalClose: false,
      escClose: false
    $.ajax
      type: 'GET',
      url: '/action_time',
      data: action,
      success: (data) ->
        progressbar(data)
      error: (data) ->
        console.log(data)

  generatePluginsHtml = (pluginList, htmlTag) ->
    plugins = pluginList.split(',')
    "<#{htmlTag}>#{plugin}</#{htmlTag}>" for plugin in plugins

  progressbar = (actionTime) ->
    console.log(actionTime)
    unless actionTime == ''
      step = actionTime / 100
      if step is 0
        $('#progress_info').slideToggle()
        $('#progressbar').width('100%')
      else
        setInterval ->
          $progressbar = $('#progressbar')
          $progress = $progressbar.parent()
          progressbarWidth = ($progressbar.width() / $progress.width()) * 100
          if progressbarWidth < 100
            newValue = (progressbarWidth + 1)
            $progressbar.width(newValue.toString() + '%')
        , step
      $('#progress_holder').slideToggle()

  sendPost = (postUrl, postData) ->
    enableBeforeUnload()
    postData.push({name: 'docs', value: true}) if $('#documentation_check').is(':checked')
    postData.push({name: 'localization', value: true}) if $('#localization_check').is(':checked')
    $.ajax
      type: 'POST',
      url: postUrl,
      data: postData,
      timeout: 600000,
      success: (data) ->
        disableBeforeUnload()
        window.location.replace(window.location.toString().split(':')[1])
      error: (data) ->
        disableBeforeUnload()
        if postUrl is '/change_version'
          action = 'change_version'
          oneEight = 'ree-1.8.7-2011.03'
          oneNine = '1.9.3-p286'
          $loadingDiv.close()
          alert("failed to switch to Ruby version #{postData}")
          openLoadingScreen('Reverting version change...', action)
          if postData is oneEight then sendPost("/#{action}", [{name: 'oneNine', value: oneNine}]) else sendPost("/#{action}", [{name: 'oneEight', value: oneEight}])
        else
          console.log(data)
          alert("ajax failure: #{data.responseText}")
          $loadingDiv.close()
          location.reload()

  generateBranchHtml = (branchList) ->
    "<li><a href='#' class='branch_link'>#{branch.trim()}</a></li>" for branch in branchList
  
  isValidPlugin = (plugins) ->
    valid = false
    regex = /^git\s(fetch|pull)\sssh:\/\/[a-zA-Z]*@gerrit.instructure.com:29418\/[\S]*\S*\srefs\/changes\/\d+\/\d+\/\d+\s&&\sgit\ checkout\sFETCH_HEAD/
    plugins.each (idx, el) ->
      valid = regex.test($(el).val())
    alert('invalid plugin') if !valid
    valid

  isUniquePlugin = (plugins) ->
    valid = true
    projects = []
    plugins.each (idx, el) -> 
      console.log("VAL " + $(el).val())
      project = $(el).val().split(":29418/")[1].split(" ")[0]
      projects.push(project)
    
    projects.sort()
    last = projects[0]
    i = 1

    while i < projects.length
      valid = false if projects[i] is last
      last = projects[i]
      i++
    alert("can't have duplicate plugin patchsets") if !valid  
    valid

  isUnique = (patchsets) ->
    values = []
    patchsets.each (idx, val) ->
      values.push $(val).val()
    values.sort()
    k = 1
    while k < values.length
      return false  if values[k] is values[k - 1]
      ++k
    true

  setLoadingText = (value) ->
    if value isnt null then text = value else text = "Environment generating..."
    $('#loading_text').text(text)

  setDropdownText = (dropdown, value) ->
    dropdown.html("#{value} &#x25BE")

  branchLinkClickHandler = ->
    $('.branch_link').bind 'click', ->
      $('#branch_name').val($(@).text())
      $branches.close()

  $('#error_file_link').bind 'click', (e) ->
    e.preventDefault()
    $link = $(@)
    if $errorLogHolder.is(':visible')
      $link.text('Show Error File Contents')
      $errorLogHolder.slideToggle()
    else
      $link.text('Hide Error File Contents')
      $.get('/error_file_text', (data) ->
        $errorLogHolder.html(data)
        $errorLogHolder.slideToggle())

  $('#docs').bind 'click', (e) ->
    action = 'documentation'
    e.preventDefault()
    if confirmation('Really generate documentation?')
      $('#documentation_check').attr('checked', false)
      openLoadingScreen('Generating Docs...', action)
      sendPost("/#{action}", [{name: 'documentation', value: 'true'}])
    else
      setDropdownText($advancedOptionsDropdown, dropdownMessage)

  $('#add_patchset').bind 'click', ->
    patchsetCount = $('.patchset:visible').length
    unless patchsetCount is 5 
      disableElement($(@)) if patchsetCount is 4
      template = $('#patchset_template').html()
      if patchsetCount is 1
        $('#initial_patchset_group').after(template)
      else
        $('.additional_patchset:visible:last').after(template)
      closePatchset()


  $('#add_plugin').bind 'click', ->
    pluginCount = $('.plugin_patchset:visible').length
    unless pluginCount is 5 
      disableElement($(@)) if pluginCount is 4
      template = $('#plugin_template').html()
      if pluginCount is 1
        $('#initial_plugin_group').after(template)
      else
        $('.additional_plugin:visible:last').after(template)
      closePlugin()

  $portalForm.bind 'submit', (e) ->
    action = 'checkout'
    e.preventDefault()
    if validatePatchset($('#portal_form_patchset')) is 0
      openLoadingScreen(null, action)
      sendPost("/#{action}", $(@).serializeArray())

  $('#branch_form').bind 'submit', (e) ->
    e.preventDefault()
    if $('#branch_name').val() is ''
      alert('branch name cannot be empty')
    else
      action = 'branch'
      if confirmation('Checking out a branch will reset your database, do you really want to do this?')
        openLoadingScreen(null, action)
        sendPost("/#{action}", $(@).serializeArray())
      else
        setDropdownText($advancedOptionsDropdown, dropdownMessage)
  
  $('#multiple_patchsets').bind 'submit', (e) ->
    action = 'checkout_multiple'
    e.preventDefault()
    $patchsets = $('.patchset:visible')
    if isUnique($patchsets)
      isValid = 0
      $patchsets.each ->
        isValid = validatePatchset($(@)) 
      
      if isValid is 0
        formattedPatchsets = (patchsetValue.value for patchsetValue in $patchsets)
        openLoadingScreen(null, action)
        sendPost("/#{action}", [{name: 'patchsets', value: formattedPatchsets.join('*')}])
    else
      alert('you have the same patchset more than once')
  
  $('#multiple_plugins').bind 'submit', (e) ->
    action = 'checkout_multiple_plugins'
    e.preventDefault()
    $plugins = $('.plugin_patchset:visible')

    if $plugins.length == 1
      alert('this option is for checking out multiple plugin patchsets only')
    else
      if isValidPlugin($plugins)  && isUniquePlugin($plugins)
        formattedPlugins = (pluginValue.value for pluginValue in $plugins)
        openLoadingScreen(null, action)
        sendPost("/#{action}", [{name: 'plugins', value: formattedPlugins.join('*')}])

  $('#plugin_form').bind 'submit', (e) ->
    action = 'plugin_patchset'
    e.preventDefault()
    if $('#patchset_url').val() isnt ''
      openLoadingScreen(null, action)
      sendPost("/#{action}", $(@).serializeArray())

  $('#canvasnet_patchset_form').bind 'submit', (e) ->
    action = 'canvasnet_patchset'
    e.preventDefault()
    if validatePatchset($('#canvasnet_patchset')) is 0
      openLoadingScreen(null, action)
      sendPost("/#{action}", $(@).serializeArray())

  $('#footer_img').popover
    title: 'Portal Info',
    trigger: 'hover', 
    placement: 'top',
    html: true,
    content: ->
      $('#canvas_state_info').html()
  
  $('#version_form').bind 'submit', (e) ->
    action = 'change_version'
    e.preventDefault()
    $version = $('#version_text').text().split(' ')[0]
    openLoadingScreen("Switching to #{$version}...", action)
    $versionModal.modal('hide')
    sendPost("/#{action}", [{name: 'version', value: $version}])

  $('#available_branches').bind 'click', (e) ->
    $branchesButton = $(@)
    $.get('/branch_list', (data) ->
      disableElement($branchesButton)
      $branchesList = $('#branches_list')
      branchList = data.split('\n')
      $branchesList.html(generateBranchHtml(branchList))
      branchLinkClickHandler()
      $branches.bPopup
        onClose: ->
          enableElement($branchesButton))

  $('#checkout').bind 'click', (e) ->
    dropdownOptionClicked(e, $(@), $basicOptionsDropdown)
    $patchsetContents.slideToggle()

  $('#action_flags_toggle').bind 'click', (e) ->
    $actionFlags = $('#action_flags')
    e.preventDefault()
    $actionFlags.slideToggle()
    $actionFlags.find('input').attr('checked', false) if $actionFlags.is(':visible')

  $('#use_master').bind 'click', (e) ->
    action = 'branch'
    dropdownOptionClicked(e, $(@), $basicOptionsDropdown)
    if confirmation('Really use master branch?')
      openLoadingScreen(null, action)
      sendPost("/#{action}", [{name: 'branch', value: 'master'}])
    else
      setDropdownText($basicOptionsDropdown, dropdownMessage)

  $('#change_version').bind 'click', (e) ->
    e.preventDefault()
    $('#version_form').submit()

  $versionModal.on 'hide', ->
    setDropdownText($advancedOptionsDropdown, dropdownMessage)

  $versionModal.on 'show', ->
    $.ajax
      type: 'GET',
      async: false,
      url: '/ruby_version',
      success: (data) ->
        $versionText = $('#version_text')
        oneEightSeven = 'ree-1.8.7-2011.03'
        oneNineThree = '1.9.3-p286'
        if data.trim() is oneNineThree
          $versionText.text(oneEightSeven)
        else
          $versionText.text(oneNineThree)
        $('#version_info').text(data)

  $('#close_version_modal').bind 'click', (e) ->
    e.preventDefault()
    $versionModal.modal('hide')

  $('#dump_db').bind 'click', (e) ->
    action = 'dcm_initial_data'
    dropdownOptionClicked(e, $(this), $advancedOptionsDropdown)
    if confirmation('Really reset database?')
      openLoadingScreen('Database resetting...', action)
      sendPost("/#{action}", [{name: 'reset_database', value: 'production'}])
    else
      setDropdownText($advancedOptionsDropdown, dropdownMessage)

  $('#branch_checkout').bind 'click', (e) ->
    dropdownOptionClicked(e, $(@), $advancedOptionsDropdown)
    $branchContents.slideToggle()

  $('#plugin_patchset').bind 'click', (e) ->
    dropdownOptionClicked(e, $(@), $advancedOptionsDropdown)
    $pluginPatchsetContents.slideToggle()

  $('#shutdown_portal').bind 'click', (e) ->
    action = 'shutdown'
    dropdownOptionClicked(e, $(@), $advancedOptionsDropdown)
    if confirmation('Really shutdown your portal?')
      openLoadingScreen('Shutting down...', action)
      $.ajax
        type: 'POST',
        url: '/shutdown',
        success: (data) ->
          alert('portal is shutdown, please ask in #QA if you need it started back up again')
        error: (data) ->
          alert('portal could not shutdown')
          console.log(data)
    else
      setDropdownText($advancedOptionsDropdown, dropdownMessage)
  
  $('#change_ruby_version').bind 'click', (e) ->
    dropdownOptionClicked(e, $(@), $advancedOptionsDropdown)
    $versionModal.modal('show')

  $('#restart_jobs_canvas').bind 'click', (e) ->
    action = 'restart_jobs_canvas'
    dropdownOptionClicked(e, $(@), $advancedOptionsDropdown)
    if confirmation("Really restart jobs for Canvas LMS? This option assumes that you are on a branch of Canvas LMS. If you aren't sure what branch you are on, click cancel and hover over the canvas logo at the bottom")
      openLoadingScreen('Restarting Jobs Canvas...', action)
      sendPost("/#{action}", [])
    else
      setDropdownText($advancedOptionsDropdown, dropdownMessage)

  $('#view_error_log').bind 'click', (e) ->
    dropdownOptionClicked(e, $(@), $advancedOptionsDropdown)
    $.get('/error_log', (data) ->
      $errorLogHolder.text(data))
    $errorLogHolder.slideToggle()

  $('#master_canvas_net').bind 'click', (e) ->
    action = 'master_canvas_net'
    dropdownOptionClicked(e, $(@), $advancedOptionsDropdown)
    if confirmation('Really change to Canvas Network Master?')
      openLoadingScreen('Canvas Network Master...', action)
      sendPost("/#{action}", [])
    else
      setDropdownText($advancedOptionsDropdown, dropdownMessage)

  $('#patchset_canvas_net').bind 'click', (e) ->
    action = 'plugin_canvas_net'
    dropdownOptionClicked(e, $(@), $advancedOptionsDropdown)
    $canvasnetPatchsetContents.slideToggle()

  $('#restart_jobs_canvasnet').bind 'click', (e) ->
    action = 'restart_jobs_canvasnet'
    dropdownOptionClicked(e, $(@), $advancedOptionsDropdown)
    if confirmation("Really restart jobs for Canvas Network? This option assumes that you are on a branch of Canvas Network. If you aren't sure what branch you are on, click cancel and hover over the canvas logo at the bottom")
      openLoadingScreen('Restarting Jobs Canvasnet...', action)
      sendPost("/#{action}", [])
    else
      setDropdownText($advancedOptionsDropdown, dropdownMessage)
 
  $('#multiple_patchsets_option').bind 'click', (e) ->
    dropdownOptionClicked(e, $(@), $advancedOptionsDropdown)
    $('#multiple_patchset_contents').slideToggle()
 
  $('#multiple_plugins_option').bind 'click', (e) ->
    dropdownOptionClicked(e, $(@), $advancedOptionsDropdown)
    $('#multiple_plugins_contents').slideToggle()
    
  $('#start_server').bind 'click', (e) ->
    action = 'start_server'
    dropdownOptionClicked(e, $(@), $advancedOptionsDropdown)
    if confirmation('Do you really want to start the server again? This could result in you having old code and outdated assets. Only do this if you really know what you are doing!')
      openLoadingScreen('Starting Server...', action)
      sendPost("/apache_server/start", [])
    else
      setDropdownText($advancedOptionsDropdown, dropdownMessage)

  $('#one_eight_seven, #one_nine_three').bind 'click', (e) ->
    setDropdownText($('#version_text'), $(@).text())

  $('#option_toggle_link').bind 'click', (e) ->
    e.preventDefault()
    $optionToggleLink = $(@)
    if $optionToggleLink.text() is 'Advanced Options' 
      setDropdownText($basicOptionsDropdown, dropdownMessage)
      linkText = 'Basic Options'
      $('#basic_options').slideToggle()
      $('#advanced_options').slideToggle()
    else
      setDropdownText($advancedOptionsDropdown, dropdownMessage)
      linkText = 'Advanced Options'
      $('#advanced_options').slideToggle()
      $('#basic_options').slideToggle()
    $optionToggleLink.text(linkText)
    $('input[type=text]').val('')
    hideContents()

  $('.help_button').bind 'click', (e) ->
    e.preventDefault()
    $('#help_pop_up').bPopup()

  $('.plugins_help_button').bind 'click', (e) ->
    e.preventDefault()
    $helpButton = $(@)
    disableElement($helpButton)
    plugins = $.get('/plugins_list', (data) ->
      $('#plugins_list').html(generatePluginsHtml(data, 'li')))
    $('#plugins_help_pop_up').bPopup
      onClose: ->
        enableElement($helpButton)
