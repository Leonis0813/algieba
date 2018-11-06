class window.Settlement
  @WIDTH = 1200
  @HEIGHT = 300

  constructor: ->
    _monthlyBar = null
    _dailyBar = null

    @drawMonthly = ->
      _monthlyBar = new Bar('monthly', Settlement.WIDTH, Settlement.HEIGHT)

      d3.json('api/settlement?interval=monthly', (error, data) ->
        bars = data.filter((element, index, array) -> index > (array.length - 1) - 36)

        scale = {
          x: d3.scaleBand().rangeRound([0, Settlement.WIDTH - 50]),
          y: d3.scaleLinear().range([Settlement.HEIGHT - 50, 0]),
        }

        scale.x.domain(bars.map((d) -> d.date))
        _monthlyBar.drawXAxis({x: 50, y: Settlement.HEIGHT - 50}, scale.x)

        d3.select('#monthly')
          .selectAll('text')
          .attr('onclick', (month) -> "settlement.drawDaily('#{month}')")
          .style('cursor', 'pointer')

        min = d3.min(bars, (bar) -> bar.price)
        max = d3.max(bars, (bar) -> bar.price)
        scale.y.domain([min, max])
        _monthlyBar.drawYAxis({x: 50, y: 0}, scale.y)

        bars = _createBars(bars, scale)
        _monthlyBar.drawBars(bars)
        _setColor('monthly')
        _setEvent('monthly', scale)
        return
      )
      return

    @drawDaily = (month) ->
      _dailyBar = new Bar('daily', 1200, 300)

      d3.json('api/settlement?interval=daily', (error, data) ->
        bars = data.filter((element, index, array) -> element.date.indexOf(month) == 0)

        scale = {
          x: d3.scaleBand().rangeRound([0, Settlement.WIDTH - 50]),
          y: d3.scaleLinear().range([Settlement.HEIGHT - 50, 0]),
        }

        scale.x.domain(bars.map((bar) -> bar.date))
        d3.select('#daily').selectAll('*').remove()
        _dailyBar.drawXAxis({x: 50, y: Settlement.HEIGHT - 50}, scale.x)

        min = d3.min(bars, (bar) -> bar.price)
        max = d3.max(bars, (bar) -> bar.price)
        scale.y.domain([min, max])
        _dailyBar.drawYAxis({x: 50, y: 0}, scale.y)

        bars = _createBars(bars, scale)
        _dailyBar.drawBars(bars)
        _setColor('daily')
        _setEvent('daily', scale)
        return
      )
      return

    _createBars = (bars, scale) ->
      bars.map((bar) ->
          {
            x: scale.x(bar.date) + 50,
            y: if bar.price < 0 then scale.y(0) else scale.y(bar.price),
            width: scale.x.bandwidth(),
            height: Math.abs(scale.y(bar.price) - scale.y(0)),
            date: bar.date,
            price: bar.price,
          }
        )

    _setColor = (id) ->
      d3.select("##{id}")
        .selectAll('.bar')
        .attr('fill', (bar) -> if bar.price < 0 then 'red' else 'green')
        .attr('opacity', 0.3)
      return

    _setEvent = (id, scale) ->
      d3.select("##{id}")
        .selectAll('rect')
        .on('mouseover', (bar) ->
          d3.select("##{id}")
            .append('text')
            .text(bar.price)
            .attr('x', bar.x)
            .attr('y', if bar.price > 0 then 0.9 * scale.y(bar.price) else scale.y(10000))
            .attr('class', 'price')
          return
        )
        .on('mouseout', () ->
          d3.select("##{id}")
            .select('text.price')
            .remove()
        )
      return
    return
