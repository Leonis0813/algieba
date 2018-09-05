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
      data = data.filter((element, index, array) -> index > (array.length - 1) - 36)

      _x.domain(setDomainX.call @, data)
      _y.domain(setDomainY.call @, data)

      drawAxisX.call @, svg
      svg.selectAll("text")
        .attr("onclick", (d) -> "settlement.drawDaily('" + d + "')")
      svg.selectAll("text")
        .attr("transform", (d, i) -> "translate(0, " + 12 * (i % 2) + ")")
      drawAxisY.call @, svg
      drawBars.call @, svg, data
      svg.selectAll("rect")
        .on("mouseover", (d) ->
          svg.append("text")
            .text(d.price)
            .attr("x", _x(d.date))
            .attr("y", if d.price > 0 then 0.9 * _y(d.price) else _y(10000))
            .attr("class", "price")
          return
        )
        .on("mouseout", ()->
          svg.select('text.price')
            .remove()
        )

    )
    return

  drawDaily: (month) ->
    interval = "daily"

    d3.select("#settlement-" + interval).remove()
    svg = createSvg.call @, interval

    d3.json("api/settlement?interval=" + interval, (error, data) ->
      data = data.filter((element, index, array) -> element.date.indexOf(month) == 0)

      _x.domain(setDomainX.call @, data)
      _y.domain(setDomainY.call @, data)

      drawAxisX.call @, svg
      svg.selectAll("text")
        .attr("transform", (d, i) -> "translate(0, " + 12 * (i % 2) + ")")
      drawAxisY.call @, svg
      drawBars.call @, svg, data
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
    return data.map((d) -> d.date)

  setDomainY = (data) ->
    min = d3.min(data, (d) -> d.price)
    max = d3.max(data, (d) -> d.price)
    return [min, max]

  drawAxisX = (svg) ->
    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + _height + ")")
      .call(_xAxis)
    return

  drawAxisY = (svg) ->
    svg.append("g")
      .attr("class", "y axis")
      .call(_yAxis)
      .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
    return

  drawBars = (svg, data) ->
    svg.selectAll(".bar")
      .data(data)
      .enter()
      .append("rect")
      .attr("class", "bar")
      .attr("x", (d) -> _x(d.date))
      .attr("y", (d) -> if d.price < 0 then _y(0) else _y(d.price))
      .attr("width", _x.bandwidth())
      .attr("height", (d) -> Math.abs(_y(d.price) - _y(0)))
      .attr("fill", (d) -> if d.price < 0 then "red" else "green")
      .attr("opacity", 0.3)
