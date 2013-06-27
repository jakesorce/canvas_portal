// Generated by CoffeeScript 1.6.2
(function() {
  $(function() {
    var $advancedOptionsDropdown, $basicOptionsDropdown, $branchContents, $branches, $canvasnetPatchsetContents, $errorLogHolder, $loadingDiv, $multiplePatchsetContents, $multiplePluginsContents, $patchsetAndPluginContents, $patchsetContents, $pluginPatchsetContents, $portalForm, $versionModal, branchLinkClickHandler, closePatchset, closePlugin, confirmation, disableBeforeUnload, disableElement, dropdownMessage, dropdownOptionClicked, enableBeforeUnload, enableElement, generateBranchHtml, generatePluginsHtml, hideContents, isUnique, isUniquePlugin, isValidPlugin, openLoadingScreen, poll, progressbar, sendPost, setDropdownText, setLoadingText, validatePatchset, validatePlugin;

    $loadingDiv = $('#loading');
    $portalForm = $('#portal_form');
    $branches = $('#branches');
    $basicOptionsDropdown = $('#basic_option_dropdown_text');
    $advancedOptionsDropdown = $('#advanced_option_dropdown_text');
    $branchContents = $('#branch_contents');
    $patchsetContents = $('#patchset_contents');
    $multiplePatchsetContents = $('#multiple_patchset_contents');
    $patchsetAndPluginContents = $('#patchset_and_plugin_contents');
    $multiplePluginsContents = $('#multiple_plugins_contents');
    $pluginPatchsetContents = $('#plugin_patchset_contents');
    $versionModal = $('#version_modal');
    $errorLogHolder = $('#error_log_holder');
    $canvasnetPatchsetContents = $('#canvasnet_patchset_contents');
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
    closePlugin = function() {
      return $('.remove_plugin').bind('click', function() {
        var $addPlugin;

        $addPlugin = $('#add_plugin');
        $(this).parent().parent().remove();
        if ($addPlugin.is(':disabled')) {
          return enableElement($addPlugin);
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
      if ($multiplePluginsContents.is(':visible')) {
        $multiplePluginsContents.slideToggle();
      }
      if ($errorLogHolder.is(':visible')) {
        $errorLogHolder.slideToggle();
      }
      if ($canvasnetPatchsetContents.is(':visible')) {
        return $canvasnetPatchsetContents.slideToggle();
      }
    };
    dropdownOptionClicked = function(e, elementClicked, dropdown) {
      hideContents();
      e.preventDefault();
      return setDropdownText(dropdown, elementClicked.text());
    };
    validatePlugin = function(pluginElement) {
      var isValid, pattern, regex;

      isValid = 0;
      if (pluginElement.val().length > 0) {
        regex = /^git\s(fetch|pull)\sssh:\/\/[a-zA-Z]*@gerrit.instructure.com:29418\/\S*\srefs\/changes\/\d+\/\d+\/\d+/;
        pattern = new RegExp(regex);
        if (pattern.test(pluginElement.val().trim()) === false) {
          alert('invalid plugin');
          pluginElement.val('');
          isValid = 1;
        }
      } else {
        alert('cannot have an empty plugin');
        isValid = 1;
      }
      return isValid;
    };
    validatePatchset = function(patchsetElement) {
      var digitRegEx, isValid, pattern, urlRegEx;

      isValid = 0;
      if (patchsetElement.val().length > 0) {
        digitRegEx = /^\d+\/\d+\/\d+$/;
        urlRegEx = /^git\s(fetch|pull)\sssh:\/\/[a-zA-Z]*@gerrit.instructure.com:29418\/\D*\d+\/\d+\/\d+\s&&\sgit\s\w*\sFETCH_HEAD/;
        if (patchsetElement.val().length < 13) {
          pattern = new RegExp(digitRegEx);
        } else {
          pattern = new RegExp(urlRegEx);
        }
        if (pattern.test(patchsetElement.val().trim()) === false) {
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
    poll = function() {
      console.log("Poll");
      return $.ajax({
        type: 'GET',
        url: '/stage',
        success: function(data) {
          setLoadingText(data);
          console.log("Success");
          return console.log(data);
        },
        complete: poll,
        timeout: 10000,
        error: function(data) {
          console.log("Error");
          return console.log(data);
        }
      });
    };
    openLoadingScreen = function(loadingText, action) {
      setLoadingText(loadingText);
      $('#game').prepend('<iframe src="http://ryanflorence.com/snake" width="800" height="600"></iframe>');
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
      if (actionTime !== '') {
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
      }
    };
    sendPost = function(postUrl, postData) {
      enableBeforeUnload();
      if ($('#documentation_check').is(':checked')) {
        postData.push({
          name: 'docs',
          value: true
        });
      }
      if ($('#localization_check').is(':checked')) {
        postData.push({
          name: 'localization',
          value: true
        });
      }
      return $.ajax({
        type: 'POST',
        url: postUrl,
        data: postData,
        timeout: 600000,
        success: function(data) {
          disableBeforeUnload();
          if (postUrl === '/backup_db' || postUrl === '/restore_db') {
            return window.location.reload();
          } else {
            return window.location.replace(window.location.toString().split(':')[1]);
          }
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
              return sendPost("/" + action, [
                {
                  name: 'oneNine',
                  value: oneNine
                }
              ]);
            } else {
              return sendPost("/" + action, [
                {
                  name: 'oneEight',
                  value: oneEight
                }
              ]);
            }
          } else {
            console.log(data);
            alert("ajax failure: " + data.responseText);
            $loadingDiv.close();
            return location.reload();
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
    isValidPlugin = function(plugins) {
      var regex, valid;

      valid = false;
      regex = /^git\s(fetch|pull)\sssh:\/\/[a-zA-Z]*@gerrit.instructure.com:29418\/[\S]*\S*\srefs\/changes\/\d+\/\d+\/\d+\s&&\sgit\scheckout\sFETCH_HEAD/;
      plugins.each(function(idx, el) {
        return valid = regex.test($(el).val());
      });
      if (!valid) {
        alert('invalid plugin');
      }
      return valid;
    };
    isUniquePlugin = function(plugins) {
      var i, last, projects, valid;

      valid = true;
      projects = [];
      plugins.each(function(idx, el) {
        var project;

        console.log("VAL " + $(el).val());
        project = $(el).val().split(":29418/")[1].split(" ")[0];
        return projects.push(project);
      });
      projects.sort();
      last = projects[0];
      i = 1;
      while (i < projects.length) {
        if (projects[i] === last) {
          valid = false;
        }
        last = projects[i];
        i++;
      }
      if (!valid) {
        alert("can't have duplicate plugin patchsets");
      }
      return valid;
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
    $('#error_file_link').bind('click', function(e) {
      var $link;

      e.preventDefault();
      $link = $(this);
      if ($errorLogHolder.is(':visible')) {
        $link.text('Show Error File Contents');
        return $errorLogHolder.slideToggle();
      } else {
        $link.text('Hide Error File Contents');
        return $.get('/error_file_text', function(data) {
          $errorLogHolder.html(data);
          return $errorLogHolder.slideToggle();
        });
      }
    });
    $('#docs').bind('click', function(e) {
      var action;

      action = 'documentation';
      e.preventDefault();
      if (confirmation('Really generate documentation?')) {
        $('#documentation_check').attr('checked', false);
        openLoadingScreen('Generating Docs...', action);
        return sendPost("/" + action, [
          {
            name: 'documentation',
            value: 'true'
          }
        ]);
      } else {
        return setDropdownText($advancedOptionsDropdown, dropdownMessage);
      }
    });
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
    $('#add_plugin').bind('click', function() {
      var pluginCount, template;

      pluginCount = $('.plugin_patchset:visible').length;
      if (pluginCount !== 5) {
        if (pluginCount === 4) {
          disableElement($(this));
        }
        template = $('#plugin_template').html();
        if (pluginCount === 1) {
          $('#initial_plugin_group').after(template);
        } else {
          $('.additional_plugin:visible:last').after(template);
        }
        return closePlugin();
      }
    });
    $portalForm.bind('submit', function(e) {
      var action;

      action = 'checkout';
      e.preventDefault();
      if (validatePatchset($('#portal_form_patchset')) === 0) {
        openLoadingScreen(null, action);
        return sendPost("/" + action, $(this).serializeArray());
      }
    });
    $('#branch_form').bind('submit', function(e) {
      var action;

      e.preventDefault();
      if ($('#branch_name').val() === '') {
        return alert('branch name cannot be empty');
      } else {
        action = 'branch';
        if (confirmation('Checking out a branch will reset your database, do you really want to do this?')) {
          openLoadingScreen(null, action);
          return sendPost("/" + action, $(this).serializeArray());
        } else {
          return setDropdownText($advancedOptionsDropdown, dropdownMessage);
        }
      }
    });
    $('#patchset_and_plugin_form').bind('submit', function(e) {
      var action, isValid;

      action = 'patchset_and_plugin';
      e.preventDefault();
      isValid = 0;
      isValid = validatePatchset($('.patchset:visible'));
      isValid = validatePlugin($('.plugin_patchset:visible'));
      if (isValid === 0) {
        openLoadingScreen(null, action);
        return sendPost("/" + action, $(this).serializeArray());
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
          return sendPost("/" + action, [
            {
              name: 'patchsets',
              value: formattedPatchsets.join('*')
            }
          ]);
        }
      } else {
        return alert('you have the same patchset more than once');
      }
    });
    $('#multiple_plugins').bind('submit', function(e) {
      var $plugins, action, formattedPlugins, pluginValue;

      action = 'checkout_multiple_plugins';
      e.preventDefault();
      $plugins = $('.plugin_patchset:visible');
      if ($plugins.length === 1) {
        return alert('this option is for checking out multiple plugin patchsets only');
      } else {
        if (isValidPlugin($plugins) && isUniquePlugin($plugins)) {
          formattedPlugins = (function() {
            var _i, _len, _results;

            _results = [];
            for (_i = 0, _len = $plugins.length; _i < _len; _i++) {
              pluginValue = $plugins[_i];
              _results.push(pluginValue.value);
            }
            return _results;
          })();
          openLoadingScreen(null, action);
          return sendPost("/" + action, [
            {
              name: 'plugins',
              value: formattedPlugins.join('*')
            }
          ]);
        }
      }
    });
    $('#plugin_form').bind('submit', function(e) {
      var action;

      action = 'plugin_patchset';
      e.preventDefault();
      if ($('#patchset_url').val() !== '') {
        openLoadingScreen(null, action);
        return sendPost("/" + action, $(this).serializeArray());
      }
    });
    $('#canvasnet_patchset_form').bind('submit', function(e) {
      var action;

      action = 'canvasnet_patchset';
      e.preventDefault();
      if (validatePatchset($('#canvasnet_patchset')) === 0) {
        openLoadingScreen(null, action);
        return sendPost("/" + action, $(this).serializeArray());
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
      alert("only Ruby 1.9.3 is currently supported");
      return $versionModal.modal('hide');
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
    $('#action_flags_toggle').bind('click', function(e) {
      var $actionFlags;

      $actionFlags = $('#action_flags');
      e.preventDefault();
      $actionFlags.slideToggle();
      if ($actionFlags.is(':visible')) {
        return $actionFlags.find('input').attr('checked', false);
      }
    });
    $('#use_master').bind('click', function(e) {
      var action;

      action = 'branch';
      dropdownOptionClicked(e, $(this), $basicOptionsDropdown);
      if (confirmation('Really use master branch?')) {
        openLoadingScreen(null, action);
        return sendPost("/" + action, [
          {
            name: 'branch',
            value: 'master'
          }
        ]);
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
          oneEightSeven = '---';
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
        return sendPost("/" + action, [
          {
            name: 'reset_database',
            value: 'production'
          }
        ]);
      } else {
        return setDropdownText($advancedOptionsDropdown, dropdownMessage);
      }
    });
    $('#backup_db').bind('click', function(e) {
      var action;

      action = 'backup_db';
      console.log("backup db");
      dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
      if (confirmation('Really backup database? This will overwrite any existing backup.')) {
        openLoadingScreen('Backing up database...', action);
        return sendPost("/" + action, [
          {
            name: 'backup_database',
            value: 'production'
          }
        ]);
      } else {
        return setDropdownText($advancedOptionsDropdown, dropdownMessage);
      }
    });
    $('#restore_db').bind('click', function(e) {
      var action;

      action = 'restore_db';
      dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
      if (confirmation('Really restore database?  This will overwrite your current database.')) {
        openLoadingScreen('Restoring database...', action);
        return sendPost("/" + action, [
          {
            name: 'restore_database',
            value: 'production'
          }
        ]);
      } else {
        return setDropdownText($advancedOptionsDropdown, dropdownMessage);
      }
    });
    $('#branch_checkout').bind('click', function(e) {
      dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
      return $branchContents.slideToggle();
    });
    $('#patchset_and_plugin').bind('click', function(e) {
      dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
      return $patchsetAndPluginContents.slideToggle();
    });
    $('#plugin_patchset').bind('click', function(e) {
      dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
      return $pluginPatchsetContents.slideToggle();
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
    $('#restart_jobs_canvas').bind('click', function(e) {
      var action;

      action = 'restart_jobs_canvas';
      dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
      if (confirmation("Really restart jobs for Canvas LMS? This option assumes that you are on a branch of Canvas LMS. If you aren't sure what branch you are on, click cancel and hover over the canvas logo at the bottom")) {
        openLoadingScreen('Restarting Jobs Canvas...', action);
        return sendPost("/" + action, []);
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
        return sendPost("/" + action, []);
      } else {
        return setDropdownText($advancedOptionsDropdown, dropdownMessage);
      }
    });
    $('#patchset_canvas_net').bind('click', function(e) {
      var action;

      action = 'plugin_canvas_net';
      dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
      return $canvasnetPatchsetContents.slideToggle();
    });
    $('#restart_jobs_canvasnet').bind('click', function(e) {
      var action;

      action = 'restart_jobs_canvasnet';
      dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
      if (confirmation("Really restart jobs for Canvas Network? This option assumes that you are on a branch of Canvas Network. If you aren't sure what branch you are on, click cancel and hover over the canvas logo at the bottom")) {
        openLoadingScreen('Restarting Jobs Canvasnet...', action);
        return sendPost("/" + action, []);
      } else {
        return setDropdownText($advancedOptionsDropdown, dropdownMessage);
      }
    });
    $('#multiple_patchsets_option').bind('click', function(e) {
      dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
      return $('#multiple_patchset_contents').slideToggle();
    });
    $('#multiple_plugins_option').bind('click', function(e) {
      dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
      return $('#multiple_plugins_contents').slideToggle();
    });
    $('#start_server').bind('click', function(e) {
      var action;

      action = 'start_server';
      dropdownOptionClicked(e, $(this), $advancedOptionsDropdown);
      if (confirmation('Do you really want to start the server again? This could result in you having old code and outdated assets. Only do this if you really know what you are doing!')) {
        openLoadingScreen('Starting Server...', action);
        return sendPost("/apache_server/start", []);
      } else {
        return setDropdownText($advancedOptionsDropdown, dropdownMessage);
      }
    });
    $('#one_eight_seven, #one_nine_three').bind('click', function(e) {
      return setDropdownText($('#version_text'), $(this).text());
    });
    $('#option_toggle_link').bind('click', function(e) {
      var $optionToggleLink, linkText;

      e.preventDefault();
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
