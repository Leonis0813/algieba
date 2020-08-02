$ ->
  window.showErrorDialog = (errors, disabledFormIds = []) ->
    li = ''
    $.each(errors, (i, error) ->
      key = "views.js.form.error.message.#{error.error_code}"
      i18nPath = "views.js.form.resource.#{error.resource}"
      params = {
        parameter: I18n.t("#{i18nPath}.attribute.#{error.parameter}"),
        resource: I18n.t("#{i18nPath}.name"),
      }
      li += "<li>#{I18n.t(key, params)}</li>"
      return
    )
    bootbox.alert({
      title: I18n.t('views.js.form.error.title'),
      message: '<div class="text-center alert alert-danger">' +
      '<ul>' +
      li +
      '</ul>' +
      '</div>',
      callback: () ->
        $.each(disabledFormIds, (i, id) ->
          $("##{id}").empty()
          $("##{id}").prop('disabled', false)
          return
        )
        return
    })
    return

  window.reloadTable = ->
    $.ajax({
      url: location.href,
      dataType: 'script',
    })
    return

  window.createResource = (resource_name, params) ->
    $.ajax({
      type: 'POST',
      url: "/algieba/api/#{resource_name}",
      data: JSON.stringify(params),
      contentType: 'application/json',
      dataType: 'json',
    }).done((data) ->
      reloadTable()
      return
    ).fail((xhr, status, error) ->
      showErrorDialog($.parseJSON(xhr.responseText).errors)
      return
    )
    return
