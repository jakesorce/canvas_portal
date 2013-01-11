$ ->
  disableButtons = ->
    $('.button-holder button').attr disabled: 'disabled'

  reload = ->
    location.reload()

  $('#server_status').bPopup
    modalClose: false,
    escClose: false

  $('#canvas').bind 'click', ->
    disableButtons()
    window.location.replace(window.location.toString().split(':')[1])

  $('#portal').bind 'click', ->
    confirmation = confirm "Going to the portal will stop the canvas server, you will not be able to go back to canvas until you complete another action from the portal. Do you really want to do this?"
    if confirmation
      disableButtons()
      $.ajax
        type: 'POST',
        async: false,
        url: '/apache_server/stop',
        success: ->
          reload()
