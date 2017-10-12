$ ->
  $('.datepicker').datetimepicker({
    format: I18n.t('views.datepicker.format'),
    locale: I18n.locale,
    dayViewHeaderFormat: I18n.t('views.datepicker.dayViewHeaderFormat')
  })

  $('.category-list').on 'click', ->
    categories = $.map($(@).data('names'), (value) ->
      return {text: value, value: value}
    )
    bootbox.prompt({
      title: I18n.t('views.category-list.title'),
      inputType: 'checkbox',
      inputOptions: categories,
      callback: (result) ->
        if result
          $('#payments_categories').val(result.join(','))
    })
    return

  $('#new_payments').on 'ajax:success', (event, xhr, status, error) ->
    location.reload()
    return

  $('#new_payments').on 'ajax:error', (event, xhr, status, error) ->
    error_codes = []
    $.each($.parseJSON(xhr.responseText), (i, e)->
      error_codes.push(I18n.t("views.payment.#{e.error_code.match(/invalid_param_(.+)/)[1]}"))
      return
    )
    bootbox.alert({
      title: I18n.t('views.create.error.title'),
      message: '<div class="text-center alert alert-danger">' + I18n.t('views.create.error.message', {error_codes: error_codes.join(', ')}) + '</div>',
    })
    return

  $('#search_button').on 'click', ->
    all_queries = $('#new_query').serializeArray()
    queries = $.grep(all_queries, (query) ->
      return query.name != "content_type" && query.name != "utf8" && query.value != ""
    )
    $.each(queries, ->
      if (this.name == "content")
        this.name = "content_" + $('#content_type').val()
      return this.name != "content"
    )
    location.href = '/algieba/payments?' + $.param(queries)
    return

  $('.delete').on 'click', ->
    id = $(@).children('button').attr('value')
    bootbox.confirm({
      message: I18n.t('views.delete.message'),
      buttons: {
        confirm: {
          label: I18n.t('views.delete.confirm'),
          className: 'btn-success'
        },
        cancel: {
          label: I18n.t('views.delete.cancel'),
          className: 'btn-danger'
        }
      },
      callback: (result) ->
        if result == true
          $.ajax({
            type: 'DELETE',
            url: '/algieba/api/payments/' + id
          }).done((data) ->
            location.reload()
            return
          )
    })
    return
  return
