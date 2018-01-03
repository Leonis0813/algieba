class window.Settlement
  _margin = {top: 50, right: 50, bottom: 50, left: 80}
  _width = window.innerWidth - _margin.left - _margin.right
  _height = (window.innerHeight / 2) - _margin.top - _margin.bottom - 50

  _x = d3.scaleBand().rangeRound([0, _width])
  _y = d3.scaleLinear().range([_height, 0])

  _xAxis = d3.axisBottom(_x)
  _yAxis = d3.axisLeft(_y)

  drawMonthly: ->
    interval = "monthly"

    svg = createSvg.call @, interval

    d3.json("api/settlement?interval=" + interval, (error, data) ->
      data = data.filter((element, index, array) ->
        return index > (array.length - 1) - 36
      )

      _x.domain(setDomainX.call @, data)
      _y.domain(setDomainY.call @, data)

      drawAxisX.call @, svg
      drawAxisY.call @, svg

      svg.selectAll(".bar")
        .data(data)
        .enter()
        .append("rect")
        .attr("class", "bar")
        .attr("x", setX.call @)
        .attr("width", _x.bandwidth())
        .attr("y", setY.call @)
        .attr("height", setHeight.call @)
        .attr("fill", setColor.call @)
        .attr("opacity", 0.3)
        .attr("onclick", (d) ->
          return "new Settlement().drawDaily('" + d.date + "')"
        )
        .on("mouseover", setMouseoverEvent.call @, svg)
        .on("mouseout", setMouseoutEvent.call @)
    )
    return

  drawDaily: (month) ->
    interval = "daily"

    d3.select("#settlement-" + interval).remove()

    svg = createSvg.call @, interval

    d3.json("api/settlement?interval=" + interval, (error, data) ->
      data = data.filter((element, index, array) ->
        return element.date.indexOf(month) == 0
      )

      _x.domain(setDomainX.call @, data)
      _y.domain(setDomainY.call @, data)

      drawAxisX.call @, svg
      svg.selectAll("text")
        .attr("transform", "rotate(-20) translate(0, 10)")
      drawAxisY.call @, svg

      svg.selectAll(".bar")
        .data(data)
        .enter()
        .append("rect")
        .attr("class", "bar")
        .attr("x", setX.call @)
        .attr("width", _x.bandwidth())
        .attr("y", setY.call @)
        .attr("height", setHeight.call @)
        .attr("fill", setColor.call @)
        .attr("opacity", 0.3)
        .on("mouseover", setMouseoverEvent.call @, svg)
        .on("mouseout", setMouseoutEvent.call @)
    )
    return

  createSvg = (interval) ->
    svg = d3.select("body")
      .append("svg")
      .attr("id", "settlement-" + interval)
      .attr("width", _width + _margin.left + _margin.right)
      .attr("height", _height + _margin.top + _margin.bottom)
      .append("g")
      .attr("transform", "translate(" + _margin.left + "," + _margin.top + ")")
    return svg

  setDomainX = (data) ->
    return data.map((d) ->
      return d.date
    )

  setDomainY = (data) ->
    min = d3.min(data, (d) ->
      return d.price
    )
    max = d3.max(data, (d) ->
      return d.price
    )
    return [min, max]

  drawAxisX = (svg) ->
    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + _height + ")")
      .call(_xAxis)

  drawAxisY = (svg) ->
    svg.append("g")
      .attr("class", "y axis")
      .call(_yAxis)
      .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")

  setX = ->
    return (d) ->
      return _x(d.date)

  setY = ->
    return (d) ->
      return if d.price < 0 then _y(0) else _y(d.price)

  setHeight = ->
   return (d) ->
     return Math.abs(_y(d.price) - _y(0))

  setColor = ->
    return (d) ->
      return if d.price < 0 then "red" else "green"

  setMouseoverEvent = (svg) ->
    return (d, i) ->
      svg.append("text")
        .attr("id", "price" + i)
        .attr("x", _x(d.date))
        .attr("y", _y(d.price) - 15)
        .text(d.price)
      return

  setMouseoutEvent = ->
    return (d, i) ->
      d3.select("#price" + i).remove()
      return
