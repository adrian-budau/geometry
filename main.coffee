$ ->
    redraw = (polygon = window.polygon, element = $("#draw")[0], color = "black", clear = true) =>
        if polygon.length <= 1
            return
        points = []
        control = (point.position() for point in polygon)
        control = ({top : point.top + 11, left : point.left + 11 } for point in control)
        for r in [0..1000]
            currentControl = control
            N = control.length
            ratio = 1.0 / 1000.0 * r
            for i in [2..N]
                newControl = []
                for j in [2..(currentControl.length)]
                    first = currentControl[j - 2]
                    second = currentControl[j - 1]
                    newPoint =
                        top : first.top * (1 - ratio) + second.top * ratio
                        left: first.left * (1 - ratio) + second.left * ratio
                    newControl.push(newPoint)
                currentControl = newControl
            points.push(currentControl[0])

        ctx = element.getContext("2d")
        ctx.clear() if clear
        ctx.beginPath()
        ctx.strokeStyle = color;
        ctx.moveTo points[0].left, points[0].top

        for point in points.slice 1
            ctx.lineTo point.left, point.top
        ctx.stroke()
        if polygon is window.polygon
            window.requestAnimationFrame(() -> do redraw)

    $(document).on 'touchstart', '.circle-start', (event) ->
        orig = event.originalEvent
        touch = orig.touches[0]
        $(this).appendTo document.body
        $(this).css {
            position : 'absolute'
            top : touch.pageY + "px"
            left : touch.pageX + "px"
        }

    $(document).on 'touchmove', '.circle-start', (event) ->
        orig = event.originalEvent
        touch = orig.touches[0]

        $(this).css {
            top : touch.pageY + "px"
            left : touch.pageX + "px"
        }
        orig.preventDefault()

    $(document).on 'touchend', '.circle-start', (event) ->
        { top: top, left: left } = $(this).css ['top', 'left']
        [top, left] = [parseInt(top, 10), parseInt(left, 10)]

        if top + 22 < $('.main').height() and $("#draw").is(":visible")

            newElement = $('<div class="circle-end circle"></div>').css {
                position: 'absolute',
                top: top,
                left: left
            }
            $('.main').append newElement
            window.polygon.push(newElement)
            do redraw
            

        $(this).css 'position', 'static'
        $(this).appendTo '.source'

    $(document).on 'touchmove', '.circle-end', (event) ->
        orig = event.originalEvent
        touch = orig.touches[0]

        top = if touch.pageY < 395 then touch.pageY else 394
        $(this).css {
            top: top + "px",
            left: touch.pageX + "px"
        }
        orig.preventDefault()

    $(document).on 'touchend', '.circle-end', (event) ->
        do redraw
    window.polygon = []

    window.requestAnimationFrame(redraw)

    drawCircle = (className, coords) ->
        { top : top, left : left} = coords
        top -= 11
        left -= 11
        newCircle = $('<div class="circle"></div>')
        newCircle.addClass className
        newCircle.css {
            top: top + "px"
            left: left + "px"
            position: "absolute"
        }
        newCircle.appendTo $(".main")

    splitPolygon = (alpha) ->
        if (window.polygon <= 1)
            return [window.polygon, window.polygon]

        control = (point.position() for point in window.polygon)
        control = ({top : point.top + 11, left: point.left + 11} for point in control)


        P = []
        P.push(control)
        currentControl = P[P.length - 1]
        N = control.length - 1
        ratio = alpha
        for i in [1..N]
            newControl = []
            for j in [2..(currentControl.length)]
                first = currentControl[j - 2]
                second = currentControl[j - 1]
                newPoint =
                    top : first.top * (1 - ratio) + second.top * ratio
                    left: first.left * (1 - ratio) + second.left * ratio
                newControl.push(newPoint)
            currentControl = newControl
            P.push(currentControl)

        # now let's just make the two sets
        left = []
        right = []
        for i in [0..N]
            left.push drawCircle((if i == N then "first second" else "first"), P[i][0])
            right.push drawCircle((if i == 0 then "first second" else "second"), P[N - i][i])
        [left, right]

    $(".wrapper").on "dblclick", () ->
        $(".first").remove();
        $(".second").remove();

        if $("#draw").is(":visible")
            $("#draw").hide()
            $("#view").show()
            [first, second] = splitPolygon $(".slider-number").val()
            $(".circle-end").hide();
            redraw first, $("#view")[0], "green"
            redraw second, $("#view")[0], "purple", false

        else
            $("#draw").show()
            $("#view").hide()
            $(".circle-end").show();

    updateIfNecessary = ->
        if $("#draw").is ":visible"
            return
        $(".first").remove();
        $(".second").remove();
        $(".circle-end").show();

        [first, second] = splitPolygon $(".slider-number").val()

        $(".circle-end").hide();
        redraw first, $("#view")[0], "green"
        redraw second, $("#view")[0], "purple", false

    $(".slider").on "change", () ->
        $(".slider-number").val($(this).val() / 100.0)
        do updateIfNecessary
    $(".slider-number").on "change", () ->
        value = $(this).val()
        value = parseFloat(value, 10)
        if value < 0 then value = 0
        if value > 1 then value = 1
        $(this).val value
        $(".slider").val value * 100
        do updateIfNecessary