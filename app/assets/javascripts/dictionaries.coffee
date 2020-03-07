$ ->
  $('#btn-create-dictionary').on 'click', ->
    category_string = $('#dictionary_categories').val()
    data = {
      phrase: if !$('#phrase').val() then null else $('#phrase').val(),
      condition: $('#condition option:selected').val(),
      categories: if !category_string then null else category_string.split(','),
    }
    $.ajax({
      type: 'POST',
      url: '/algieba/api/dictionaries',
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
