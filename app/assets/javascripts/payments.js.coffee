$ ->
  showErrorDialog = (errorCodes)->
    param = {error_codes: errorCodes.join(', ')}
    bootbox.alert({
      title: I18n.t('views.js.form.error.title'),
      message: '<div class="text-center alert alert-danger">' +
      I18n.t('views.js.form.error.message', param) +
      '</div>',
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
      category_names = $.map(data.dictionaries[0].categories, (category) ->
        return category.name
      )
      $('#payment_categories').val(category_names.join(','))
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

  $('#new_payment').on 'submit', ->
    category_array = $('#payment_categories').val().split(',')
    $.each(category_array, (i, e)->
      input = '<input type="hidden" name="categories[]" value="' + e + '">'
      $('#payment_categories').append(input)
      return
    )
    $('#payment_categories').prop('disabled', true)
    return

  $('#new_payment').on 'ajax:success', (event, payment, status) ->
    query = $.param({phrase: payment.content, condition: 'equal'})
    $.ajax({
      type: 'GET',
      url: '/algieba/api/dictionaries?' + query
    }).done((data) ->
      if (data.dictionaries.length == 0)
        category_names = $.map(payment.categories, (category) ->
          return category.name
        ).join(',')
        bootbox.dialog({
          title: '以下の情報を辞書に登録しますか？',
          message: '<div class="form-group">' +
          '<label for="phrase">' +
          I18n.t('views.dictionary.create.phrase') +
          '</label>' +
          '<input value="' +
          payment.content +
          '" id="dialog-phrase" class="form-control">' +
          '<select id="dialog-condition" class="form-control">' +
          '<option value="include">' +
          I18n.t('views.dictionary.create.include') +
          '</option>' +
          '<option selected value="equal">' +
          I18n.t('views.dictionary.create.equal') +
          '</option>' +
          '</select>' +
          '</div>' +
          '<div class="form-group">' +
          '<label for="categories">' +
          I18n.t('views.dictionary.create.categories') +
          '</label><br />' +
          '<input class="form-control" value="' +
          category_names +
          '" id="dialog-categories" disabled>' +
          '</div>',
          buttons: {
            cancel: {
              label: I18n.t('views.dictionary.create.cancel'),
              className: 'btn-default',
              callback: ->
                $("#payment_categories").empty()
                $('#payment_categories').prop('disabled', false)
                location.reload()
                return
            },
            ok: {
              label: I18n.t('views.dictionary.create.submit'),
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
                  $("#payment_categories").empty()
                  $('#payment_categories').prop('disabled', false)
                  location.reload()
                  return
                )
                return
            }
          }
        })
        return
      $("#payment_categories").empty()
      $('#payment_categories').prop('disabled', false)
      location.reload()
      return
    )
    return

  $('#new_payment').on 'ajax:error', (event, xhr, status, error) ->
    $("#payment_categories").empty()
    $('#payment_categories').prop('disabled', false)
    errorCodes = []
    $.each($.parseJSON(xhr.responseText).errors, (i, error) ->
      attribute = error.error_code.match(/^.+_param_(.+)/)[1]
      errorCodes.push(I18n.t("views.common.attribute.#{attribute}"))
      return
    )
    showErrorDialog(errorCodes)
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
      errorCodes = []
      $.each($.parseJSON(xhr.responseText).errors, (i, error) ->
        attribute = error.error_code.match(/invalid_param_(.+)/)[1]
        errorCodes.push(I18n.t("views.search.#{attribute}"))
        return
      )
      showErrorDialog(errorCodes)
      return
    )
    return

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
      bootbox.alert(I18n.t('views.js.form.success.message'))
      $('#phrase').val('')
      $('#dictionary_categories').val('')
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
