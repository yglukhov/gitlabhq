class Diff
  UNFOLD_COUNT = 20
  constructor: ->
    $(document).on('click', '.js-unfold', (event) =>
      target = $(event.target)
      unfoldBottom = target.hasClass('js-unfold-bottom')
      unfold = true

      [old_line, line_number] = @lineNumbers(target.parent())
      offset = line_number - old_line

      if unfoldBottom
        line_number += 1
        since = line_number
        to = line_number + UNFOLD_COUNT
      else
        [prev_old_line, prev_new_line] = @lineNumbers(target.parent().prev())
        line_number -= 1
        to = line_number
        if line_number - UNFOLD_COUNT > prev_new_line + 1
          since = line_number - UNFOLD_COUNT
        else
          since = prev_new_line + 1
          unfold = false

      link = target.parents('.diff-file').attr('data-blob-diff-path')
      params =
        since: since
        to: to
        bottom: unfoldBottom
        offset: offset
        unfold: unfold

      $.get(link, params, (response) =>
        target.parent().replaceWith(response)
      )
    ).ready =>
      diffHeaders = $(".diff-header")
      diffHeaders.stick_in_parent()

    self = @
 
    $("body").on "click", ".js-toggle-diff-expansion", (e) ->
      diffFile = $(@).closest(".diff-file")
      if $(@).is(":checked")
        diffFile.addClass("diff-file-expanded")
        self.updateElementPositions(diffFile)
      else
        diffFile.removeClass("diff-file-expanded")
        diffFile.css("position", "static").css("left", "0px").css("width", "100%")
      $(document.body).trigger("sticky_kit:recalc")

     $(window).resize =>
       @updateElementPositions($(".diff-file-expanded"))
       $(document.body).trigger("sticky_kit:recalc")

  lineNumbers: (line) ->
    return ([0, 0]) unless line.children().length
    lines = line.children().slice(0, 2)
    line_numbers = ($(l).attr('data-linenumber') for l in lines)
    (parseInt(line_number) for line_number in line_numbers)

  updateElementPositions: (e) ->
    e.offset(left: 0)
    e.width($(window).width())


@Diff = Diff
