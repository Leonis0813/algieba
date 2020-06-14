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
