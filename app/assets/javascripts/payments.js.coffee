$ ->
  $('.date-form').datetimepicker({
    format: I18n.t('views.js.datepicker.format'),
    locale: I18n.locale,
    dayViewHeaderFormat: I18n.t('views.js.datepicker.dayViewHeaderFormat')
  })

  $('.category-list').on 'click', ->
    categories = $.map($(@).data('names'), (value) ->
      return {text: value, value: value}
    )
    category_form = $(@).parent().find('.category-form')
    bootbox.prompt({
      title: I18n.t('views.js.category-list.title'),
      inputType: 'checkbox',
      inputOptions: categories,
      callback: (result) ->
        if result
          category_form.val(result.join(','))
    })
    return

  $('#new_payments').on 'ajax:success', (event, xhr, status, error) ->
    location.reload()
    return

  $('#new_payments').on 'ajax:error', (event, xhr, status, error) ->
    error_codes = []
    $.each($.parseJSON(xhr.responseText), (i, e)->
      error_codes.push(I18n.t("views.common.attribute.#{e.error_code.match(/invalid_param_(.+)/)[1]}"))
      return
    )
    bootbox.alert({
      title: I18n.t('views.js.form.error.title'),
      message: '<div class="text-center alert alert-danger">' + I18n.t('views.js.form.error.message', {error_codes: error_codes.join(', ')}) + '</div>',
    })
    return

  $('#search-button').on 'click', ->
    all_queries = $('#new_query').serializeArray()
    queries = $.grep(all_queries, (query) ->
      return query.name != "content_type" && query.name != "utf8" && query.value != ""
    )
    $.each(queries, ->
      if (this.name == "content")
        this.name = "content_" + $('#content-type').val()
      return this.name != "content"
    )

    per_page = $('#per_page').val()
    if (per_page != '')
      queries.push({'name': 'per_page', 'value': per_page})

    $.ajax({
      type: 'GET',
      url: '/algieba/payments?' + $.param(queries)
    }).done((data) ->
      location.href = '/algieba/payments?' + $.param(queries)
      return
    ).fail((xhr, status, error) ->
      error_codes = []
      $.each($.parseJSON(xhr.responseText), (i, e)->
        error_codes.push(I18n.t("views.search.#{e.error_code.match(/invalid_param_(.+)/)[1]}"))
        return
      )
      bootbox.alert({
        title: I18n.t('views.js.form.error.title'),
        message: '<div class="text-center alert alert-danger">' + I18n.t('views.js.form.error.message', {error_codes: error_codes.join(', ')}) + '</div>',
      })
    )
    return

  $('#per_page_form').on 'submit', ->
    query = location.search.replace(/&?per_page=\d+/, '').substring(1)
    per_page = $('#per_page').val()

    url = ''
    if (query == '')
      url = '/algieba/payments?per_page=' + per_page
    else
      url = '/algieba/payments?' + query + '&per_page=' + per_page
    $.ajax({
      type: 'GET',
      url: url
    }).done((data) ->
      location.href = url
      return
    ).fail((xhr, status, error) ->
      bootbox.alert({
        title: I18n.t('views.js.pagination.error.title'),
        message: '<div class="text-center alert alert-danger">' + I18n.t('views.js.pagination.error.message') + '</div>',
      })
      $('#per_page').val('')
    )
    return

  $('#payment_table').DataTable({
    paging: false,
    info: false,
    filter: false,
    order: [[1, "desc"]],
    columnDefs: [
      {
        "targets": [0, 5],
        "sorting": false,
      },
    ]
  })

  $('.delete').on 'click', ->
    id = $(@).children('button').attr('value')
    bootbox.confirm({
      message: I18n.t('views.js.delete.message'),
      buttons: {
        confirm: {
          label: I18n.t('views.js.delete.confirm'),
          className: 'btn-success'
        },
        cancel: {
          label: I18n.t('views.js.delete.cancel'),
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
