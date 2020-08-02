$ ->
  $('#btn-tag-create').on 'click', ->
    $.ajax({
      type: 'POST',
      url: '/algieba/api/tags',
      data: JSON.stringify({name: $('#name').val()}),
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
