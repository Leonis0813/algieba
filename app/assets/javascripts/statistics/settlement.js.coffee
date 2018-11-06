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
          .attr('onclick', (d) -> "settlement.drawDaily('#{d}')")
          .attr('transform', (d, i) -> "translate(0, #{12 * (i % 2)})")
          .style('cursor', 'pointer')

        min = d3.min(bars, (d) -> d.price)
        max = d3.max(bars, (d) -> d.price)
        scale.y.domain([min, max])
        _monthlyBar.drawYAxis({x: 50, y: 0}, scale.y)

        bars = bars.map((d) ->
          {
            x: scale.x(d.date) + 50,
            y: if d.price < 0 then scale.y(0) else scale.y(d.price),
            width: scale.x.bandwidth(),
            height: Math.abs(scale.y(d.price) - scale.y(0)),
            date: d.date,
            price: d.price,
          }
        )
        _monthlyBar.drawBars(bars)

        d3.select('#monthly')
          .selectAll('.bar')
          .attr('fill', (bar) -> if bar.price < 0 then 'red' else 'green')
          .attr('opacity', 0.3)

        d3.select('#monthly')
          .selectAll('rect')
          .on('mouseover', (bar) ->
            d3.select('#monthly')
              .append('text')
              .text(bar.price)
              .attr('x', bar.x)
              .attr('y', if bar.price > 0 then 0.9 * scale.y(bar.price) else scale.y(10000))
              .attr('class', 'price')
            return
          )
          .on('mouseout', () ->
            d3.select('#monthly')
              .select('text.price')
              .remove()
          )
        return
      )

    @drawDaily = (month) ->
      _dailyBar = new Bar('daily', 1200, 300)

      d3.select('#daily').selectAll('*').remove()

      d3.json('api/settlement?interval=daily', (error, data) ->
        bars = data.filter((element, index, array) -> element.date.indexOf(month) == 0)

        scale = {
          x: d3.scaleBand().rangeRound([0, Settlement.WIDTH - 50]),
          y: d3.scaleLinear().range([Settlement.HEIGHT - 50, 0]),
        }

        scale.x.domain(bars.map((d) -> d.date))
        _dailyBar.drawXAxis({x: 50, y: Settlement.HEIGHT - 50}, scale.x)

        d3.select('#daily')
          .selectAll('text')
          .attr('transform', (d, i) -> "translate(0, #{12 * (i % 2)})")

        min = d3.min(bars, (d) -> d.price)
        max = d3.max(bars, (d) -> d.price)
        scale.y.domain([min, max])
        _dailyBar.drawYAxis({x: 50, y: 0}, scale.y)

        bars = bars.map((d) ->
          {
            x: scale.x(d.date) + 50,
            y: if d.price < 0 then scale.y(0) else scale.y(d.price),
            width: scale.x.bandwidth(),
            height: Math.abs(scale.y(d.price) - scale.y(0)),
            date: d.date,
            price: d.price,
          }
        )
        _dailyBar.drawBars(bars)

        d3.select('#daily')
          .selectAll('.bar')
          .attr('fill', (bar) -> if bar.price < 0 then 'red' else 'green')
          .attr('opacity', 0.3)

        d3.select('#daily')
          .selectAll('rect')
          .on('mouseover', (bar) ->
            d3.select('#daily')
              .append('text')
              .text(bar.price)
              .attr('x', bar.x)
              .attr('y', if bar.price > 0 then 0.9 * scale.y(bar.price) else scale.y(10000))
              .attr('class', 'price')
            return
          )
          .on('mouseout', () ->
            d3.select('#daily')
              .select('text.price')
              .remove()
          )
        return
      )
    return
