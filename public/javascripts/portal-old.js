var $loadingDiv = $('#loading');
var $portalForm = $('#portal_form');
var $branches = $('#branches');
var $basicOptionsDropdown = $('#basic_option_dropdown_text');
var $advancedOptionsDropdown = $('#advanced_option_dropdown_text');
var $branchContents = $('#branch_contents');
var $patchsetContents = $('#patchset_contents');
var $pluginPatchsetContents = $('#plugin_patchset_contents');
var $versionModal = $('#version_modal');
var dropdownMessage = 'What do you want to do?';

window.onload = function() {
  $.get('/canvas_state', function(data) {
  $('#branch_info').html(data);
  });  
} 

function enableBeforeUnload() {
  window.onbeforeunload = function (e) {
    return "You are in the middle of generating an environment, do you really want to leave?";
  };
}

function disableBeforeUnload() {
  window.onbeforeunload = null;
}

function confirmation(message) {
  return confirm(message);
}

function disableElement(element) {
  element.attr('disabled', 'disabled');
}

function enableElement(element) {
  element.removeAttr('disabled');
}

function hideContents() {
  var $patchsetContents = $('#patchset_contents');
  var $branchContents = $('#branch_contents');
  var $pluginPatchsetContents = $('#plugin_patchset_contents');
  if($patchsetContents.is(':visible'))
    $patchsetContents.slideToggle();
  if($branchContents.is(':visible'))
    $branchContents.slideToggle();
  if($pluginPatchsetContents.is(':visible'))
    $pluginPatchsetContents.slideToggle(); 
}

function dropdownOptionClicked(e, element_clicked, dropdown) {
  hideContents();
  e.preventDefault();
  setDropdownText(dropdown, element_clicked.text());
}

function validatePatchset(patchsetElement) {
  var isValid = true;
  if (patchsetElement.val().length > 0) {
    var digitRegEx = /\d+\/\d+\/\d+/;
    var pattern = new RegExp(digitRegEx);
    if (!pattern.test(patchsetElement.val())) {
      isValid = false;
      alert('invalid patchset');
      patchsetElement.val('');
    }
  }
  else {
    alert('cannot have an empty patchset number');
    isValid = false;
  }
  return isValid;
}

function openLoadingScreen(loadingText) {
  setLoadingText(loadingText);
  $loadingDiv.bPopup({
    modalClose:false,
    escClose:false
  });
}

function generatePluginsHtml(htmlTag) {
  var html = '';
  $.ajax({
    type: 'GET',
    async: false,
    url: '/plugins_list',
    success: function(data) {
      var plugins = data.split(',');
      for(var i = 0; i < plugins.length; i++)
        html = html + '<'+htmlTag+'>' + plugins[i] + '</'+htmlTag+'>';
      }
  });
  return html;
}

function sendPost(postUrl, postData) {
  enableBeforeUnload();
  $.ajax({
    type:'POST',
    url:postUrl,
    data:postData,
    timeout:600000,
    success:function (data) {
      disableBeforeUnload();
      var port80 = window.location.toString().split(':')[1];
      window.location.replace(port80);
    },
    error:function (data) {
      if(postUrl == '/change_version') {
         var one_eight = 'ree-1.8.7-2011.03';
         var one_nine = '1.9.3-p286';
         $loadingDiv.close();
         alert('failed to switch to Ruby version ' + postData);
         openLoadingScreen('Reverting version change...');
         if(postData == one_eight)
           sendPost('/change_version', one_nine);
         else if(postData == one_nine)
           sendPost('/change_version', one_eight);
      }
      else {
        console.log(data);  
        alert('ajax failure:' + data.responseText);
        $loadingDiv.close();
        disableBeforeUnload();
      }
    }
  });  
} 

function generateBranchHtml(branchList) {
  var html = '';
  for(var i = 0; i < (branchList.length - 1); i++)
    html = html + '<li><a href="#" class="branch_link">' + branchList[i].trim() + '</a></li>';
  return html;
}

function setLoadingText(value) {
  var text = '';
  if(value != null)
    text = value;
  else
    text = 'Please wait while the environment is generated...';
  $('#loading_text').text(text);
}

function setDropdownText(dropdown, value) {
  dropdown.html(value + ' &#x25BE;');
}
 
function branchLinkClickHandler() { 
  $('.branch_link').bind('click', function() {
    $('#branch_name').val($(this).text());
    $branches.close();
  });
}

$portalForm.bind('submit', function(e) {
  e.preventDefault();
  var $patchset = $('#portal_form_patchset');
  if(validatePatchset($patchset)) {
    openLoadingScreen(null);
    sendPost('/checkout', $patchset.val());
  }
});
  
$('#branch_form').bind('submit', function(e) {
  e.preventDefault();
  var $branchName = $('#branch_name').val();
  if($branchName == '')
    alert('branch name cannot be empty');
  else {
    if (confirmation('Checking out a branch will reset your database, do you really want to do this?'))  {
      openLoadingScreen(null);
      sendPost('/branch', $branchName);
    }
    else
      setDropdownText($advancedOptionsDropdown, dropdownMessage);
  }
});

$('#plugin_form').bind('submit', function(e) {
  e.preventDefault();
  var $patchsetUrl = $('#patchset_url');
  if($patchsetUrl.val() != '') {
    openLoadingScreen(null);
    sendPost('/plugin_patchset', $patchsetUrl);
  }
});

$('#footer').popover({
  title: 'Portal Info',
  trigger: 'hover',
  placement: 'top',
  html: true,
  content: function() {
    return $('#canvas_state_info').html();
  }
});

$('#version_form').bind('submit', function(e) {
  e.preventDefault();
  var $version = $('#version_text').text().split(' ')[0];
  openLoadingScreen('Changing to Ruby Version ' + $version + '...');
  $versionModal.modal('hide');
  sendPost('/change_version', $version);
});

$('#available_branches').bind('click', function() {
  var $branchesButton = $(this);
  $.get('/branch_list', function(data) {
    disableElement($branchesButton);
    var $branchesList = $('#branches_list');
    var branchList = data.split('\n');
    $branchesList.html(generateBranchHtml(branchList));
    branchLinkClickHandler();
    $branches.bPopup({
      onClose: function() {
        enableElement($branchesButton);
    }});
  });
});
 
$('#checkout').bind('click', function(e) {
  dropdownOptionClicked(e, $(this), $basicOptionsDropdown);
  $('#patchset_contents').slideToggle();
});

$('#use_master').bind('click', function(e) {
  dropdownOptionClicked(e, $(this), $basicOptionsDropdown);
  if (confirmation('Really use master branch?')) {
    openLoadingScreen(null);
    sendPost('/branch', 'master');
  }
  else
    setDropdownText($basicOptionsDropdown, dropdownMessage);
});

$('#change_version').bind('click', function(e) {
  e.preventDefault();
  $('#version_form').submit();
});

$versionModal.on('hide', function() {
  setDropdownText($advancedOptionsDropdown, dropdownMessage);
});

$versionModal.on('show', function() {
  $.ajax({
    type: 'GET',
    async: false,
    url: '/ruby_version',
    success: function(data) {
      var $versionDropdown = $('#version_select');
      var $oneEightSeven = $('#one_eight_seven');
      var $oneNineThree = $('#one_nine_three');
      if(data.trim() == '1.9.3-p286') {
        $oneEightSeven.removeClass('force-hide');
        $oneNineThree.addClass('force-hide');
      }
      else {
        $oneEightSeven.addClass('force-hide');
        $oneNineThree.removeClass('force-hide');
      }
      $('#version_info').text(data);
    }
  });
});

$('#close_version_modal').bind('click', function(e) {
  e.preventDefault();
  $versionModal.modal('hide');
});

$('#dump_db').bind('click', function(e) {
  dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
  if (confirmation('Really reset database?')) {
    openLoadingScreen('Please wait while the database is reset...');
    sendPost('/dcm_initial_data/development', null);
  }
  else
    setDropdownText($advancedOptionsDropdown, dropdownMessage);
});

$('#branch_checkout').bind('click', function(e) {
  dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
  $branchContents.slideToggle();
});

$('#plugin_patchset').bind('click', function(e) {
  dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
  $pluginPatchsetContents.slideToggle();
});

$('#generate_documentation').bind('click', function(e) {
  dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
  if (confirmation('Really genereate documentation?')) {
    openLoadingScreen('Please wait while the documentation is generated...');
    sendPost('/documentation', null);
  }
  else
    setDropdownText($advancedOptionsDropdown, dropdownMessage);
});

$('#change_ruby_version').bind('click', function(e) {
  dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
  $versionModal.modal();
});

$('#validate_localization').bind('click', function(e) {
  dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
  if(confirmation('Validating Localization will run on the current branch, continue?')) {
    openLoadingScreen('Adding Localization Code...');
    sendPost('/localization', null);
  }
  else
    setDropdownText($advancedOptionsDropdown, dropdownMessage);
});

$('#master_canvas_net').bind('click', function(e) {
  dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
});

$('#patchset_canvas_net').bind('click', function(e) {
  dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
});

$('#one_eight_seven'), $('#one_nine_three').bind('click', function(e) {
  setDropdownText($('#version_text'), $(this).text());
});

$('#option_toggle_link').bind('click', function() {
  var linkText = '';
  var $optionToggleLink = $(this);
  if($optionToggleLink.text() == 'Advanced Options') {
    setDropdownText($basicOptionsDropdown, dropdownMessage);
    linkText = 'Basic Options';
    $('#basic_options').slideToggle();
    $('#advanced_options').slideToggle();
  }
  else {
    setDropdownText($advancedOptionsDropdown, dropdownMessage);
    linkText = 'Advanced Options';
    $('#advanced_options').slideToggle();
    $('#basic_options').slideToggle();
  }
  $optionToggleLink.text(linkText);
  $('input[type=text]').val('');
  hideContents();
});

$('.help_button').bind('click', function(e) {
  e.preventDefault();
  $('#help_pop_up').bPopup();
});

$('.plugins_help_button').bind('click', function(e) {
  e.preventDefault();
  var $helpButton = $(this);
  var html = generatePluginsHtml('li');
  var $pluginsList = $('#plugins_list');
  disableElement($helpButton);
  $pluginsList.html(html);
  $('#plugins_help_pop_up').bPopup({
    onClose: function() {
      enableElement($helpButton);
  }});
});
