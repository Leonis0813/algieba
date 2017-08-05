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
      id = $(@).children('button').attr('value')
      bootbox.confirm({
        message: '本当に削除しますか？',
        buttons: {
          confirm: {
            label: 'はい',
            className: 'btn-success'
          },
          cancel: {
            label: 'いいえ',
            className: 'btn-danger'
          }
        },
        callback: (result) ->
          if result == true
            $.ajax({
              type: 'DELETE',
              url: '/payments/' + id
            }).done((data) ->
              location.reload()
              return
            )
      });
      return
    return

$ ->
  $('.datepicker').datetimepicker({
    format: 'YYYY-MM-DD',
    locale: 'ja',
    dayViewHeaderFormat: 'YYYY年 MM月'
  })
  return
