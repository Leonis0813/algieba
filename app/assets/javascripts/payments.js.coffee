$ ->
  $('#new_payments')
    .on 'ajax:success', (event, xhr, status, error) ->
      location.reload()
      return
    return

$ ->
  $('#new_payments')
    .on 'ajax:error', (event, xhr, status, error) ->
      ja = {date: '日付', price: '金額'}
      error_codes = []
      $.each($.parseJSON(xhr.responseText), (i, e)->
        error_codes.push(ja[e.error_code.match(/invalid_param_(.+)/)[1]])
        return
      )
      bootbox.alert({
        title: 'エラー',
        message: '<div class="text-center alert alert-danger">' + error_codes.join(', ') + ' が不正です</div>',
      })
      return
    return

$ ->
  $('.delete')
    .on 'click', ->
      $.ajax({
        type: 'DELETE',
        url: '/payments/' + $(@).children('button').attr('value')
      }).done((data) ->
        location.reload()
        return
      )
      return
    return
