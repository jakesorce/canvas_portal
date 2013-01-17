// Generated by CoffeeScript 1.4.0
(function() {

  $(function() {
    var $advancedOptionsDropdown, $basicOptionsDropdown, $branchContents, $branches, $errorLogHolder, $loadingDiv, $multiplePatchsetContents, $patchsetContents, $pluginPatchsetContents, $portalForm, $versionModal, branchLinkClickHandler, closePatchset, confirmation, disableBeforeUnload, disableElement, dropdownMessage, dropdownOptionClicked, enableBeforeUnload, enableElement, generateBranchHtml, generatePluginsHtml, hideContents, isUnique, openLoadingScreen, progressbar, sendPost, setDropdownText, setLoadingText, validatePatchset;
    $loadingDiv = $('#loading');
    $portalForm = $('#portal_form');
    $branches = $('#branches');
    $basicOptionsDropdown = $('#basic_option_dropdown_text');
    $advancedOptionsDropdown = $('#advanced_option_dropdown_text');
    $branchContents = $('#branch_contents');
    $patchsetContents = $('#patchset_contents');
    $multiplePatchsetContents = $('#multiple_patchset_contents');
    $pluginPatchsetContents = $('#plugin_patchset_contents');
    $versionModal = $('#version_modal');
    $errorLogHolder = $('#error_log_holder');
    dropdownMessage = 'What do you want to do?';
    $('#footer_img').effect("highlight", {}, 1500);
    enableBeforeUnload = function() {
      return window.onbeforeunload = function(e) {
        return "You are in the middle of generating an environment, do you really want to leave?";
      };
    };
    disableBeforeUnload = function() {
      return window.onbeforeunload = null;
    };
    confirmation = function(message) {
      return confirm(message);
    };
    disableElement = function(element) {
      return element.attr('disabled', 'disabled');
    };
    enableElement = function(element) {
      return element.removeAttr('disabled');
    };
    closePatchset = function() {
      return $('.remove_patchset').bind('click', function() {
        var $addPatchset;
        $addPatchset = $('#add_patchset');
        $(this).parent().parent().remove();
        if ($addPatchset.is(':disabled')) {
          return enableElement($addPatchset);
        }
      });
    };
    hideContents = function() {
      if ($patchsetContents.is(':visible')) {
        $patchsetContents.slideToggle();
      }
      if ($branchContents.is(':visible')) {
        $branchContents.slideToggle();
      }
      if ($pluginPatchsetContents.is(':visible')) {
        $pluginPatchsetContents.slideToggle();
      }
      if ($multiplePatchsetContents.is(':visible')) {
        $multiplePatchsetContents.slideToggle();
      }
      if ($errorLogHolder.is(':visible')) {
        return $errorLogHolder.slideToggle();
      }
    };
    dropdownOptionClicked = function(e, elementClicked, dropdown) {
      hideContents();
      e.preventDefault();
      return setDropdownText(dropdown, elementClicked.text());
    };
    validatePatchset = function(patchsetElement) {
      var digitRegEx, digitRegex, isValid, pattern;
      isValid = 0;
      if (patchsetElement.val().length > 0) {
        digitRegex = digitRegEx = /\d+\/\d+\/\d+/;
        pattern = new RegExp(digitRegEx);
        if (pattern.test(patchsetElement.val()) === false) {
          alert('invalid patchset');
          patchsetElement.val('');
          isValid = 1;
        }
      } else {
        alert('cannot have an empty patchset number');
        isValid = 1;
      }
      return isValid;
    };
    openLoadingScreen = function(loadingText, action) {
      setLoadingText(loadingText);
      $loadingDiv.bPopup({
        modalClose: false,
        escClose: false
      });
      return $.ajax({
        type: 'GET',
        url: '/action_time',
        data: action,
        success: function(data) {
          return progressbar(data);
        },
        error: function(data) {
          return console.log(data);
        }
      });
    };
    generatePluginsHtml = function(pluginList, htmlTag) {
      var plugin, plugins, _i, _len, _results;
      plugins = pluginList.split(',');
      _results = [];
      for (_i = 0, _len = plugins.length; _i < _len; _i++) {
        plugin = plugins[_i];
        _results.push("<" + htmlTag + ">" + plugin + "</" + htmlTag + ">");
      }
      return _results;
    };
    progressbar = function(actionTime) {
      var step;
      console.log(actionTime);
      step = actionTime / 100;
      if (step === 0) {
        $('#progress_info').slideToggle();
        $('#progressbar').width('100%');
      } else {
        setInterval(function() {
          var $progress, $progressbar, newValue, progressbarWidth;
          $progressbar = $('#progressbar');
          $progress = $progressbar.parent();
          progressbarWidth = ($progressbar.width() / $progress.width()) * 100;
          if (progressbarWidth < 100) {
            newValue = progressbarWidth + 1;
            return $progressbar.width(newValue.toString() + '%');
          }
        }, step);
      }
      return $('#progress_holder').slideToggle();
    };
    sendPost = function(postUrl, postData) {
      enableBeforeUnload();
      return $.ajax({
        type: 'POST',
        url: postUrl,
        data: postData,
        timeout: 600000,
        success: function(data) {
          disableBeforeUnload();
          return window.location.replace(window.location.toString().split(':')[1]);
        },
        error: function(data) {
          var action, oneEight, oneNine;
          disableBeforeUnload();
          if (postUrl === '/change_version') {
            action = 'change_version';
            oneEight = 'ree-1.8.7-2011.03';
            oneNine = '1.9.3-p286';
            $loadingDiv.close();
            alert("failed to switch to Ruby version " + postData);
            openLoadingScreen('Reverting version change...', action);
            if (postData === oneEight) {
              return sendPost("/" + action, oneNine);
            } else {
              return sendPost("/" + action, oneEight);
            }
          } else {
            console.log(data);
            alert("ajax failure: " + data.responseText);
            return $loadingDiv.close();
          }
        }
      });
    };
    generateBranchHtml = function(branchList) {
      var branch, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = branchList.length; _i < _len; _i++) {
        branch = branchList[_i];
        _results.push("<li><a href='#' class='branch_link'>" + (branch.trim()) + "</a></li>");
      }
      return _results;
    };
    isUnique = function(patchsets) {
      var k, values;
      values = [];
      patchsets.each(function(idx, val) {
        return values.push($(val).val());
      });
      values.sort();
      k = 1;
      while (k < values.length) {
        if (values[k] === values[k - 1]) {
          return false;
        }
        ++k;
      }
      return true;
    };
    setLoadingText = function(value) {
      var text;
      if (value !== null) {
        text = value;
      } else {
        text = "Environment generating...";
      }
      return $('#loading_text').text(text);
    };
    setDropdownText = function(dropdown, value) {
      return dropdown.html("" + value + " &#x25BE");
    };
    branchLinkClickHandler = function() {
      return $('.branch_link').bind('click', function() {
        $('#branch_name').val($(this).text());
        return $branches.close();
      });
    };
    $('#add_patchset').bind('click', function() {
      var patchsetCount, template;
      patchsetCount = $('.patchset:visible').length;
      if (patchsetCount !== 5) {
        if (patchsetCount === 4) {
          disableElement($(this));
        }
        template = $('#patchset_template').html();
        if (patchsetCount === 1) {
          $('#initial_patchset_group').after(template);
        } else {
          $('.additional_patchset:visible:last').after(template);
        }
        return closePatchset();
      }
    });
    $portalForm.bind('submit', function(e) {
      var $patchset, action;
      action = 'checkout';
      e.preventDefault();
      $patchset = $('#portal_form_patchset');
      if (validatePatchset($patchset) === 0) {
        openLoadingScreen(null, action);
        return sendPost("/" + action, $patchset.val());
      }
    });
    $('#branch_form').bind('submit', function(e) {
      var $branchName, action;
      e.preventDefault();
      $branchName = $('#branch_name').val();
      if ($branchName === '') {
        return alert('branch name cannot be empty');
      } else {
        action = 'branch';
        if (confirmation('Checking out a branch will reset your database, do you really want to do this?')) {
          openLoadingScreen(null, action);
          return sendPost("" + action, $branchName);
        } else {
          return setDropdownText($advancedOptionsDropdown, dropdownMessage);
        }
      }
    });
    $('#multiple_patchsets').bind('submit', function(e) {
      var $patchsets, action, formattedPatchsets, isValid, patchsetValue;
      action = 'checkout_multiple';
      e.preventDefault();
      $patchsets = $('.patchset:visible');
      if (isUnique($patchsets)) {
        isValid = 0;
        $patchsets.each(function() {
          return isValid = validatePatchset($(this));
        });
        if (isValid === 0) {
          formattedPatchsets = (function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = $patchsets.length; _i < _len; _i++) {
              patchsetValue = $patchsets[_i];
              _results.push(patchsetValue.value);
            }
            return _results;
          })();
          openLoadingScreen(null, action);
          return sendPost("/" + action, formattedPatchsets.toString());
        }
      } else {
        return alert('you have the same patchset more than once');
      }
    });
    $('#plugin_form').bind('submit', function(e) {
      var $patchsetUrl, action;
      action = 'plugin_patchset';
      e.preventDefault();
      $patchsetUrl = $('#patchset_url');
      if ($patchsetUrl.val() !== '') {
        openLoadingScreen(null, action);
        return sendPost("/" + action, $patchsetUrl);
      }
    });
    $('#footer_img').popover({
      title: 'Portal Info',
      trigger: 'hover',
      placement: 'top',
      html: true,
      content: function() {
        return $('#canvas_state_info').html();
      }
    });
    $('#version_form').bind('submit', function(e) {
      var $version, action;
      action = 'change_version';
      e.preventDefault();
      $version = $('#version_text').text().split(' ')[0];
      openLoadingScreen("Switching to " + $version + "...", action);
      $versionModal.modal('hide');
      return sendPost("/" + action, $version);
    });
    $('#available_branches').bind('click', function(e) {
      var $branchesButton;
      $branchesButton = $(this);
      return $.get('/branch_list', function(data) {
        var $branchesList, branchList;
        disableElement($branchesButton);
        $branchesList = $('#branches_list');
        branchList = data.split('\n');
        $branchesList.html(generateBranchHtml(branchList));
        branchLinkClickHandler();
        return $branches.bPopup({
          onClose: function() {
            return enableElement($branchesButton);
          }
        });
      });
    });
    $('#checkout').bind('click', function(e) {
      dropdownOptionClicked(e, $(this), $basicOptionsDropdown);
      return $patchsetContents.slideToggle();
    });
    $('#use_master').bind('click', function(e) {
      var action;
      action = 'branch';
      dropdownOptionClicked(e, $(this), $basicOptionsDropdown);
      if (confirmation('Really use master branch?')) {
        openLoadingScreen(null, action);
        return sendPost("/" + action, 'master');
      } else {
        return setDropdownText($basicOptionsDropdown, dropdownMessage);
      }
    });
    $('#change_version').bind('click', function(e) {
      e.preventDefault();
      return $('#version_form').submit();
    });
    $versionModal.on('hide', function() {
      return setDropdownText($advancedOptionsDropdown, dropdownMessage);
    });
    $versionModal.on('show', function() {
      return $.ajax({
        type: 'GET',
        async: false,
        url: '/ruby_version',
        success: function(data) {
          var $versionText, oneEightSeven, oneNineThree;
          $versionText = $('#version_text');
          oneEightSeven = 'ree-1.8.7-2011.03';
          oneNineThree = '1.9.3-p286';
          if (data.trim() === oneNineThree) {
            $versionText.text(oneEightSeven);
          } else {
            $versionText.text(oneNineThree);
          }
          return $('#version_info').text(data);
        }
      });
    });
    $('#close_version_modal').bind('click', function(e) {
      e.preventDefault();
      return $versionModal.modal('hide');
    });
    $('#dump_db').bind('click', function(e) {
      var action;
      action = 'dcm_initial_data';
      dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
      if (confirmation('Really reset database?')) {
        openLoadingScreen('Database resetting...', action);
        return sendPost("/" + action + "/development", null);
      } else {
        return setDropdownText($advancedOptionsDropdown, dropdownMessage);
      }
    });
    $('#branch_checkout').bind('click', function(e) {
      dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
      return $branchContents.slideToggle();
    });
    $('#plugin_patchset').bind('click', function(e) {
      dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
      return $pluginPatchsetContents.slideToggle();
    });
    $('#generate_documentation').bind('click', function(e) {
      var action;
      action = 'documentation';
      dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
      if (confirmation('Really genereate documentation?')) {
        openLoadingScreen('Documentation generating...', action);
        return sendPost("/" + action, null);
      } else {
        return setDropdownText($advancedOptionsDropdown, dropdownMessage);
      }
    });
    $('#shutdown_portal').bind('click', function(e) {
      var action;
      action = 'shutdown';
      dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
      if (confirmation('Really shutdown your portal?')) {
        openLoadingScreen('Shutting down...', action);
        return $.ajax({
          type: 'POST',
          url: '/shutdown',
          success: function(data) {
            return alert('portal is shutdown, please ask in #QA if you need it started back up again');
          },
          error: function(data) {
            alert('portal could not shutdown');
            return console.log(data);
          }
        });
      } else {
        return setDropdownText($advancedOptionsDropdown, dropdownMessage);
      }
    });
    $('#change_ruby_version').bind('click', function(e) {
      dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
      return $versionModal.modal('show');
    });
    $('#validate_localization').bind('click', function(e) {
      var action;
      action = 'localization';
      dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
      if (confirmation('Validating Localization will run on the current branch, continue?')) {
        openLoadingScreen('Adding Localization Code...', action);
        return sendPost("/" + action, null);
      } else {
        return setDropdownText($advancedOptionsDropdown, dropdownMessage);
      }
    });
    $('#view_error_log').bind('click', function(e) {
      dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
      $.get('/error_log', function(data) {
        return $errorLogHolder.text(data);
      });
      return $errorLogHolder.slideToggle();
    });
    $('#master_canvas_net').bind('click', function(e) {
      var action;
      action = 'master_canvas_net';
      dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
      if (confirmation('Really change to Canvas Network Master?')) {
        openLoadingScreen('Canvas Network Master...', action);
        return sendPost("/" + action, null);
      } else {
        return setDropdownText($advancedOptionsDropdown, dropdownMessage);
      }
    });
    $('#patchset_canvas_net').bind('click', function(e) {});
    $('#multiple_patchsets_option').bind('click', function(e) {
      dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
      return $('#multiple_patchset_contents').slideToggle();
    });
    $('#start_server').bind('click', function(e) {
      var action;
      action = 'start_server';
      dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
      if (confirmation('Do you really want to start the server again? This could result in you having old code and outdated assets. Only do this if you really know what you are doing!')) {
        openLoadingScreen('Starting Server...', action);
        return sendPost("/apache_server/start", null);
      } else {
        return setDropdownText($advancedOptionsDropdown, dropdownMessage);
      }
    });
    $('#one_eight_seven, #one_nine_three').bind('click', function(e) {
      return setDropdownText($('#version_text'), $(this).text());
    });
    $('#option_toggle_link').bind('click', function() {
      var $optionToggleLink, linkText;
      $optionToggleLink = $(this);
      if ($optionToggleLink.text() === 'Advanced Options') {
        setDropdownText($basicOptionsDropdown, dropdownMessage);
        linkText = 'Basic Options';
        $('#basic_options').slideToggle();
        $('#advanced_options').slideToggle();
      } else {
        setDropdownText($advancedOptionsDropdown, dropdownMessage);
        linkText = 'Advanced Options';
        $('#advanced_options').slideToggle();
        $('#basic_options').slideToggle();
      }
      $optionToggleLink.text(linkText);
      $('input[type=text]').val('');
      return hideContents();
    });
    $('.help_button').bind('click', function(e) {
      e.preventDefault();
      return $('#help_pop_up').bPopup();
    });
    return $('.plugins_help_button').bind('click', function(e) {
      var $helpButton, plugins;
      e.preventDefault();
      $helpButton = $(this);
      disableElement($helpButton);
      plugins = $.get('/plugins_list', function(data) {
        return $('#plugins_list').html(generatePluginsHtml(data, 'li'));
      });
      return $('#plugins_help_pop_up').bPopup({
        onClose: function() {
          return enableElement($helpButton);
        }
      });
    });
  });

}).call(this);
