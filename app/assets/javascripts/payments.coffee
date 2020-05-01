$ ->
  showErrorDialog = (errorCodes, disabledFormIds = []) ->
    param = {error_codes: errorCodes.join(', ')}
    bootbox.alert({
      title: I18n.t('views.js.form.error.title'),
      message: '<div class="text-center alert alert-danger">' +
      I18n.t('views.js.form.error.message', param) +
      '</div>',
      callback: () ->
        $.each(disabledFormIds, (i, id) ->
          $('#' + id).empty()
          $('#' + id).prop('disabled', false)
          return
        return
    })
    return

  $('.date-form').datetimepicker({
    format: I18n.t('views.js.datepicker.format'),
    locale: I18n.locale,
    dayViewHeaderFormat: I18n.t('views.js.datepicker.dayViewHeaderFormat')
  })

  $('#payment_content').on 'focusout', ->
    query = {content: $('#payment_content').val()}
    $.ajax({
      type: 'GET',
      url: '/algieba/api/dictionaries?' + $.param(query)
    }).done((data) ->
      if data.dictionaries.length > 0
        dictionaries = $.grep(data.dictionaries, (dictionary) ->
          return dictionary.condition == 'equal'
        )
        if dictionaries.length == 0
          dictionaries = data.dictionaries
          dictionaries.sort((a, b) ->
            if a.phrase.length > b.phrase.length
              return -1
            if a.phrase.length < b.phrase.length
              return 1
            return 0
          )
        category_names = $.map(dictionaries[0].categories, (category) ->
          return category.name
        )
        $('#payment_categories').val(category_names.join(','))
        return
      return
    )
    return

  $('.category-list').on 'click', ->
    categories = $.map($(@).data('names'), (value) ->
      return {text: value, value: value}
    )
    category_form = $(@).parent().find('.category-form')
    bootbox.prompt({
      title: I18n.t('views.js.category-list.title'),
      inputType: 'checkbox',
      inputOptions: categories,
      callback: (results) ->
        if results
          category_form.val(results.join(','))
          return
    })
    return

  $('.tag-list').on 'click', ->
    tags = $.map($(@).data('names'), (value) ->
      return {text: value, value: value}
    )
    tag_form = $(@).parent().find('.tag-form')
    bootbox.prompt({
      title: I18n.t('views.js.tag-list.title'),
      inputType: 'checkbox',
      inputOptions: tags,
      callback: (results) ->
        if results
          tag_form.val(results.join(','))
          return
    })
    return

  $('#new_payment').on 'submit', ->
    category_array = $('#payment_categories').val().split(',')
    $.each(category_array, (i, e)->
      input = '<input type="hidden" name="categories[]" value="' + e + '">'
      $('#payment_categories').append(input)
      return
    )
    if $('#payment_tags').val() != ''
      tag_array = $('#payment_tags').val().split(',')
      $.each(tag_array, (i, e)->
        input = '<input type="hidden" name="tags[]" value="' + e + '">'
        $('#payment_tags').append(input)
        return
      )
    $('#payment_categories').prop('disabled', true)
    $('#payment_tags').prop('disabled', true)
    return

  $('#new_payment').on 'ajax:success', (event, payment, status) ->
    $.ajax({
      type: 'GET',
      url: '/algieba/api/dictionaries',
      data: {phrase: payment.content}
    }).done((data) ->
      if (data.dictionaries.length == 0)
        category_names = $.map(payment.categories, (category) ->
          return category.name
        ).join(',')
        bootbox.dialog({
          title: '以下の情報を辞書に登録しますか？',
          message: '<div class="form-group">' +
          '<label for="phrase">' +
          I18n.t('views.management.dictionaries.attribute.phrase') +
          '</label>' +
          '<input value="' +
          payment.content +
          '" id="dialog-phrase" class="form-control">' +
          '<select id="dialog-condition" class="form-control">' +
          '<option value="include">' +
          I18n.t('views.management.dictionaries.form.create.condition.include') +
          '</option>' +
          '<option selected value="equal">' +
          I18n.t('views.management.dictionaries.form.create.condition.equal') +
          '</option>' +
          '</select>' +
          '</div>' +
          '<div class="form-group">' +
          '<label for="categories">' +
          I18n.t('views.management.dictionaries.attribute.categories') +
          '</label><br />' +
          '<input class="form-control" value="' +
          category_names +
          '" id="dialog-categories" disabled>' +
          '</div>',
          buttons: {
            cancel: {
              label: I18n.t('views.management.payments.dialog.dictionary.cancel'),
              className: 'btn-default',
              callback: ->
                location.reload()
                return
            },
            ok: {
              label: I18n.t('views.management.payments.dialog.dictionary.submit'),
              className: 'btn-primary',
              callback: ->
                data = {
                  phrase: $('#dialog-phrase').val(),
                  condition: $('#dialog-condition option:selected').val(),
                  categories: $('#dialog-categories').val().split(','),
                }
                $.ajax({
                  type: 'POST',
                  url: '/algieba/api/dictionaries',
                  data: JSON.stringify(data),
                  contentType: 'application/json',
                  dataType: 'json',
                }).always((xhr, status, error) ->
                  location.reload()
                  return
                )
                return
            }
          }
        })
        return
      location.reload()
      return
    )
    return

  $('#new_payment').on 'ajax:error', (event, xhr, status, error) ->
    errorCodes = []
    $.each($.parseJSON(xhr.responseText).errors, (i, error) ->
      attribute = error.error_code.match(/^.+_param_(.+)/)[1]
      errorCodes.push(I18n.t("views.management.payments.attribute.#{attribute}"))
      return
    )
    showErrorDialog(errorCodes, ['payment_categories', 'payment_tags'])
    return

  $('#btn-payment-search').on 'click', ->
    all_queries = $('#new_payment_query').serializeArray()
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
      url: '/algieba/management/payments?' + $.param(queries)
    }).done((data) ->
      location.href = '/algieba/management/payments?' + $.param(queries)
      return
    ).fail((xhr, status, error) ->
      errorCodes = []
      $.each($.parseJSON(xhr.responseText).errors, (i, error) ->
        attribute = error.error_code.match(/invalid_param_(.+)_.*$/)[1]
        errorCodes.push(I18n.t("views.management.payments.attribute.#{attribute}"))
        return
      )
      showErrorDialog($.unique(errorCodes))
      return
    )
    return

  $('#per_page_form').on 'submit', ->
    query = location.search.replace(/&?per_page=\d+/, '').substring(1)
    per_page = $('#per_page').val()

    url = ''
    if (query == '')
      url = '/algieba/management/payments?per_page=' + per_page
    else
      url = '/algieba/management/payments?' + query + '&per_page=' + per_page
    $.ajax({
      type: 'GET',
      url: url
    }).done((data) ->
      location.href = url
      return
    ).fail((xhr, status, error) ->
      bootbox.alert({
        title: I18n.t('views.js.pagination.error.title'),
        message: '<div class="text-center alert alert-danger">' +
        I18n.t('views.js.pagination.error.message') +
        '</div>',
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
        "targets": [0, 6],
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
