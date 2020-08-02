$ ->
  $('#btn-create-dictionary').on 'click', ->
    data = {condition: $('#condition option:selected').val()}
    if $('#phrase').val()
      data['phrase'] = $('#phrase').val()
    if $('#dictionary_categories').val()
      data['categories'] = $('#dictionary_categories').val().split(',')

    $.ajax({
      type: 'POST',
      url: '/algieba/api/dictionaries',
      data: JSON.stringify(data),
      contentType: 'application/json',
      dataType: 'json',
    }).done((data) ->
      location.reload()
      return
    ).fail((xhr, status, error) ->
      showErrorDialog($.parseJSON(xhr.responseText).errors)
      return
    )
    return
