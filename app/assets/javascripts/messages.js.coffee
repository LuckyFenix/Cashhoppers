$(document).ready ->
  $("#hop").click (e) ->
    $.post "close_grid",
      close: "1"
  $("#close").click (e) ->
    $.post "close_grid",
      close: "0"

#$(".menuitem").click ->
#  $("this").load "wice_grid"
#
#$(document).ready ->
#  $("#example-1").load "wice_grid.html"
#  $("#example-1").click ->
#    $(this).load "wice_grid.html"
#  $(".pagination ul li a").click (e) ->
#    attribute = $(this).attr('href')  #.replace('email_too','wice_grid');
#    $("#example-1").load attribute
#    false
#

