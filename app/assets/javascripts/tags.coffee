$ ->
  $('#btn-tag-create').on 'click', ->
    data = {
      name: $('#name').val()
    }
    console.log(data)
    $.ajax({
      type: 'POST',
      url: '/algieba/api/tags',
      data: JSON.stringify(data),
      contentType: 'application/json',
      dataType: 'json',
    }).done((data) ->
      location.reload()
    ).fail((xhr, status, error) ->
      errorCodes = []
      $.each($.parseJSON(xhr.responseText).errors, (i, error)->
        attribute = error.error_code.match(/.+_param_(.+)/)[1]
        errorCodes.push(I18n.t("views.dictionary.create.#{attribute}"))
        return
      )
      showErrorDialog(errorCodes)
      return
    )
    return
