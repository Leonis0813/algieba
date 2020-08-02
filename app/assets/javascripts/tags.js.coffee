$ ->
  $('#form-tag-create').on 'submit', ->
    params = {}
    if $('#name').val()
      params['name'] = $('#name').val()
    createResource('tags', params)
    return false
  return
