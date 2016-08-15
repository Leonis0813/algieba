$ ->
  $('#new_accounts').on 'ajax:success', (event, data, status, xhr) ->
    $('#accounts').parent().load('/ #accounts');
    return
