define ['GameCanvas', 'GameTools'], (GameCanvas, GameTools) ->

    canvasID = '#' + GameCanvas.DEFAULT_ID

    keyDownHandler = (e) ->
        handled = false

        if e.keyCode == 38
            @up = true
            handled = true
        else if e.keyCode == 40
            @down = true
            handled = true
        else if e.keyCode == 39
            @right = true
            handled = true
        else if e.keyCode == 37
            @left = true
            handled = true

        if handled
            e.preventDefault()

    keyUpHandler = (e) ->
        if e.keyCode == 38
            @up = false
        if e.keyCode == 40
            @down = false
        if e.keyCode == 39
            @right = false
        if e.keyCode == 37
            @left = false


    class InputStatus
        constructor: (map) ->
            @gameTools = new GameTools(map)

            @canvasID = canvasID

            # Tool clicks
            @clickX = -1
            @clickY = -1

            # Keyboard Movement
            @up = false
            @down = false
            @left = false
            @right = false

            # Mouse movement
            @mouseX = -1
            @mouseY = -1

            # Tool buttons
            @toolName = null
            @currentTool = null
            @toolWidth = 0
            @toolColour = ''

            # Other buttons
            @budgetRequested = false
            @evalRequested = false
            @disasterRequested = false

            # Speed
            @speedChangeRequested = false
            @requestedSpeed = null

            # Add the listeners
            $(document).keydown(keyDownHandler.bind(this))
            $(document).keyup(keyUpHandler.bind(this))

            $(@canvasID).on('mouseenter', mouseEnterHandler.bind(this))
            $(@canvasID).on('mouseleave', mouseLeaveHandler.bind(this))

            $('.toolButton').click(toolButtonHandler.bind(this))

            $('#budgetRequest').click(@budgetHandler.bind(this))
            $('#evalRequest').click(@evalHandler.bind(this))
            $('#disasterRequest').click(@disasterHandler.bind(this))
            $('#pauseRequest').click(@speedChangeHandler.bind(this))

        clickHandled: ->
            @clickX = -1
            @clickY = -1
            @currentTool.clear()

        getRelativeCoordinates: ->
            if e.x != undefined and e.y != undefined
                x = e.x
                y = e.y
            else
                x = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft
                y = e.clientY + document.body.scrollTop + document.documentElement.scrollTop

            canvas = $(canvasID)[0]
            x -= canvas.offsetLeft
            y -= canvas.offsetTop
            return {x: x, y: y}

        mouseEnterHandler: (e) ->
            $(@canvasID).on('mousemove', mouseMoveHandler.bind(this))
            $(@canvasID).on('click', canvasClickHandler.bind(this))

        mouseLeaveHandler: (e) ->
            $(@canvasID).off('mousemove')
            $(@canvasID).off('click')

            @mouseX = -1
            @mouseY = -1

        mouseMoveHandler: (e) ->
            coords = getRelativeCoordinates(e)
            @mouseX = coords.x
            @mouseY = coords.y

        canvasClickHandler: (e) ->
            @clickX = @mouseX
            @clickY = @mouseY
            e.preventDefault()

        toolButtonHandler: (e) ->
            # Remove highlight from last tool button
            $('.selected').each ->
                $(this).removeClass('selected')
                $(this).addClass('unselected')

            # Add highlight
            $(e.target).removeClass('unselected')
            $(e.target).addClass('selected')

            @toolName = $(e.target).attr('data-tool')
            @toolWidth = $(e.target).attr('data-size')
            @currentTool = @gameTools[@toolName]
            @toolColour = $(e.target).attr('data-colour')

            e.preventDefault()

        speedChangeHandled: ->
            @speedChangeRequested = false
            @requestedSpeed = null

        speedChangeHandler: (e) ->
            @speedChangeRequested = true
            requestedSpeed = $('#pauseRequest').text()
            newRequest = if requestedSpeed == 'Pause' then 'Play' else 'Pause'
            $('#pauseRequest').text(newRequest)

        disasterHandler: (e) ->
            @disasterRequested = true

        disasterHandled: (e) ->
            @disasterRequested = false

        evalHandler: (e) ->
            @evalRequested = true

        evalHandled: (e) ->
            @evalRequested = false

        budgetHandler: (e) ->
            @budgetRequested = true

        budgetHandled: (e) ->
            @budgetRequested = false
