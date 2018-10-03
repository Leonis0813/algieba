 class window.Settlement
  _margin = {top: 50, right: 50, bottom: 50, left: 80}
  _width = window.innerWidth - _margin.left - _margin.right
  _height = (window.innerHeight / 2) - _margin.top - _margin.bottom - 50

  _xMonthly = d3.scaleBand().rangeRound([0, _width])
  _yMonthly = d3.scaleLinear().range([_height, 0])

  _xDaily = d3.scaleBand().rangeRound([0, _width])
  _yDaily = d3.scaleLinear().range([_height, 0])

  _xAxisMonthly = d3.axisBottom(_xMonthly)
  _yAxisMonthly = d3.axisLeft(_yMonthly)

  _xAxisDaily = d3.axisBottom(_xDaily)
  _yAxisDaily = d3.axisLeft(_yDaily)

  drawMonthly: ->
    interval = 'monthly'
    svg = createSvg.call @, interval

    d3.json("api/settlement?interval=#{interval}", (error, data) ->
      data = data.filter((element, index, array) -> index > (array.length - 1) - 36)

      _xMonthly.domain(setDomainX.call @, data)
      _yMonthly.domain(setDomainY.call @, data)

      drawAxisX.call @, svg, _xAxisMonthly
      svg.selectAll('text')
        .attr('onclick', (d) -> "settlement.drawDaily('#{d}')")
      svg.selectAll('text')
        .attr('transform', (d, i) -> "translate(0, #{12 * (i % 2)})")
      drawAxisY.call @, svg, _yAxisMonthly
      drawBars.call @, svg, data, _xMonthly, _yMonthly
      svg.selectAll('rect')
        .on('mouseover', (d) ->
          svg.append('text')
            .text(d.price)
            .attr('x', _xMonthly(d.date))
            .attr('y', if d.price > 0 then 0.9 * _yMonthly(d.price) else _yMonthly(10000))
            .attr('class', 'price')
          return
        )
        .on('mouseout', ()->
          svg.select('text.price')
            .remove()
        )

    )
    return

  drawDaily: (month) ->
    interval = 'daily'

    d3.select("#settlement-#{interval}").remove()
    svg = createSvg.call @, interval

    d3.json("api/settlement?interval=#{interval}", (error, data) ->
      data = data.filter((element, index, array) -> element.date.indexOf(month) == 0)

      _xDaily.domain(setDomainX.call @, data)
      _yDaily.domain(setDomainY.call @, data)

      drawAxisX.call @, svg, _xAxisDaily
      svg.selectAll('text')
        .attr('transform', (d, i) -> "translate(0, #{12 * (i % 2)})")
      drawAxisY.call @, svg, _yAxisDaily
      drawBars.call @, svg, data, _xDaily, _yDaily
    )
    return

  createSvg = (interval) ->
    svg = d3.select('body')
      .append('svg')
      .attr('id', "settlement-#{interval}")
      .attr('width', _width + _margin.left + _margin.right)
      .attr('height', _height + _margin.top + _margin.bottom)
      .append('g')
      .attr('transform', "translate(#{_margin.left}, #{_margin.top})")
    return svg

  setDomainX = (data) ->
    return data.map((d) -> d.date)

  setDomainY = (data) ->
    min = d3.min(data, (d) -> d.price)
    max = d3.max(data, (d) -> d.price)
    return [min, max]

  drawAxisX = (svg, xAxis) ->
    svg.append('g')
      .attr('class', 'x axis')
      .attr('transform', "translate(0, #{_height})")
      .call(xAxis)
    return

  drawAxisY = (svg, yAxis) ->
    svg.append('g')
      .attr('class', 'y axis')
      .call(yAxis)
      .append('text')
      .attr('transform', 'rotate(-90)')
      .attr('y', 6)
      .attr('dy', '.71em')
      .style('text-anchor', 'end')
    return

  drawBars = (svg, data, x, y) ->
    svg.selectAll('.bar')
      .data(data)
      .enter()
      .append('rect')
      .attr('class', 'bar')
      .attr('x', (d) -> x(d.date))
      .attr('y', (d) -> if d.price < 0 then y(0) else y(d.price))
      .attr('width', x.bandwidth())
      .attr('height', (d) -> Math.abs(y(d.price) - y(0)))
      .attr('fill', (d) -> if d.price < 0 then 'red' else 'green')
      .attr('opacity', 0.3)
