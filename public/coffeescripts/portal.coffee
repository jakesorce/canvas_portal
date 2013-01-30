$ ->
  $loadingDiv = $('#loading')
  $portalForm = $('#portal_form')
  $branches = $('#branches')
  $basicOptionsDropdown = $('#basic_option_dropdown_text')
  $advancedOptionsDropdown = $('#advanced_option_dropdown_text')
  $branchContents = $('#branch_contents')
  $patchsetContents = $('#patchset_contents')
  $multiplePatchsetContents = $('#multiple_patchset_contents')
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

  hideContents = ->
    $patchsetContents.slideToggle() if $patchsetContents.is(':visible')
    $branchContents.slideToggle() if $branchContents.is(':visible')
    $pluginPatchsetContents.slideToggle() if $pluginPatchsetContents.is(':visible')
    $multiplePatchsetContents.slideToggle() if $multiplePatchsetContents.is(':visible')
    $errorLogHolder.slideToggle() if $errorLogHolder.is(':visible')
    $canvasnetPatchsetContents.slideToggle() if $canvasnetPatchsetContents.is(':visible')
   
  dropdownOptionClicked = (e, elementClicked, dropdown) ->
    hideContents()
    e.preventDefault()
    setDropdownText(dropdown, elementClicked.text())

  validatePatchset = (patchsetElement) ->
    isValid = 0
    if patchsetElement.val().length > 0
      digitRegEx = /^\d+\/\d+\/\d+$/
      pattern = new RegExp(digitRegEx)
      if pattern.test(patchsetElement.val()) is false
        alert('invalid patchset')
        patchsetElement.val('')
        isValid = 1
    else
      alert('cannot have an empty patchset number')
      isValid = 1
    isValid

  openLoadingScreen = (loadingText, action) ->
    setLoadingText(loadingText)
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
          if postData is oneEight then sendPost("/#{action}", oneNine) else sendPost("/#{action}", oneEight)
        else
          console.log(data)
          alert("ajax failure: #{data.responseText}")
          $loadingDiv.close()

  generateBranchHtml = (branchList) ->
    "<li><a href='#' class='branch_link'>#{branch.trim()}</a></li>" for branch in branchList

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

  $portalForm.bind 'submit', (e) ->
    action = 'checkout'
    e.preventDefault()
    $patchset = $('#portal_form_patchset')
    if validatePatchset($patchset) is 0
      openLoadingScreen(null, action)
      sendPost("/#{action}", $patchset.val())

  $('#branch_form').bind 'submit', (e) ->
    e.preventDefault()
    $branchName = $('#branch_name').val()
    if $branchName is ''
      alert('branch name cannot be empty')
    else
      action = 'branch'
      if confirmation('Checking out a branch will reset your database, do you really want to do this?')
        openLoadingScreen(null, action)
        sendPost("#{action}", $branchName)
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
        sendPost("/#{action}", formattedPatchsets.toString())
    else
      alert('you have the same patchset more than once')
  
  $('#plugin_form').bind 'submit', (e) ->
    action = 'plugin_patchset'
    e.preventDefault()
    $patchsetUrl = $('#patchset_url')
    if $patchsetUrl.val() isnt ''
      openLoadingScreen(null, action)
      sendPost("/#{action}", $patchsetUrl)

  $('#canvasnet_patchset_form').bind 'submit', (e) ->
    action = 'canvasnet_patchset'
    e.preventDefault()
    $patchset = $('#canvasnet_patchset')
    if validatePatchset($patchset) is 0
      openLoadingScreen(null, action)
      sendPost("/#{action}", $patchset)

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
    sendPost("/#{action}", $version)

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

  $('#use_master').bind 'click', (e) ->
    action = 'branch'
    dropdownOptionClicked(e, $(@), $basicOptionsDropdown)
    if confirmation('Really use master branch?')
      openLoadingScreen(null, action)
      sendPost("/#{action}", 'master')
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
      sendPost("/#{action}/development", null)
    else
      setDropdownText($advancedOptionsDropdown, dropdownMessage)

  $('#branch_checkout').bind 'click', (e) ->
    dropdownOptionClicked(e, $(@), $advancedOptionsDropdown)
    $branchContents.slideToggle()

  $('#plugin_patchset').bind 'click', (e) ->
    dropdownOptionClicked(e, $(@), $advancedOptionsDropdown)
    $pluginPatchsetContents.slideToggle()

  $('#generate_documentation').bind 'click', (e) ->
    action = 'documentation'
    dropdownOptionClicked(e, $(@), $advancedOptionsDropdown)
    if confirmation('Really genereate documentation?')
      openLoadingScreen('Documentation generating...', action)
      sendPost("/#{action}", null)
    else
      setDropdownText($advancedOptionsDropdown, dropdownMessage)
  
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

  $('#validate_localization').bind 'click', (e) ->
    action = 'localization'
    dropdownOptionClicked(e, $(@), $advancedOptionsDropdown)
    if confirmation('Validating Localization will run on the current branch, continue?')
      openLoadingScreen('Adding Localization Code...', action)
      sendPost("/#{action}", null)
    else
      setDropdownText($advancedOptionsDropdown, dropdownMessage)
   
  $('#restart_jobs_canvas').bind 'click', (e) ->
    action = 'restart_jobs_canvas'
    dropdownOptionClicked(e, $(@), $advancedOptionsDropdown)
    if confirmation("Really restart jobs for Canvas LMS? This option assumes that you are on a branch of Canvas LMS. If you aren't sure what branch you are on, click cancel and hover over the canvas logo at the bottom")
      openLoadingScreen('Restarting Jobs Canvas...', action)
      sendPost("/#{action}", null)
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
      sendPost("/#{action}", null)
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
      sendPost("/#{action}", null)
    else
      setDropdownText($advancedOptionsDropdown, dropdownMessage)
 
  $('#multiple_patchsets_option').bind 'click', (e) ->
    dropdownOptionClicked(e, $(@), $advancedOptionsDropdown)
    $('#multiple_patchset_contents').slideToggle()
 
  $('#start_server').bind 'click', (e) ->
    action = 'start_server'
    dropdownOptionClicked(e, $(@), $advancedOptionsDropdown)
    if confirmation('Do you really want to start the server again? This could result in you having old code and outdated assets. Only do this if you really know what you are doing!')
      openLoadingScreen('Starting Server...', action)
      sendPost("/apache_server/start", null)
    else
      setDropdownText($advancedOptionsDropdown, dropdownMessage)

  $('#one_eight_seven, #one_nine_three').bind 'click', (e) ->
    setDropdownText($('#version_text'), $(@).text())

  $('#option_toggle_link').bind 'click', ->
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
