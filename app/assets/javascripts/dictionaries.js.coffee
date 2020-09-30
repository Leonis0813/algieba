$ ->
  $('#form-dictionary-create').on 'submit', ->
    params = {condition: $('#condition option:selected').val()}
    if $('#phrase').val()
      params['phrase'] = $('#phrase').val()
    if $('#dictionary_categories').val()
      params['categories'] = $('#dictionary_categories').val().split(',')
    createResource('dictionaries', params)
    return false
  return
