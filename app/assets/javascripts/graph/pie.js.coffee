class window.Pie
  @COLOR = ["#DC3912", "#3366CC", "#109618", "#FF9900", "#990099"]

  constructor: (id, width, height, radius) ->
    _svg = d3.select("##{id}")
      .attr('width', width)
      .attr('height', height)
    _g = _svg.append('g').attr('transform', "translate(#{width / 2},#{height / 2})")
    _arc = d3.arc().outerRadius(radius).innerRadius(0)
    _pie = d3.pie().value((d) -> d.price)
    _color = d3.scaleOrdinal().range(Pie.COLOR)
    _text = d3.arc().outerRadius(radius - 30).innerRadius(radius - 30)

    @draw = (settlements) ->
      pieGroup = _g.selectAll('.pie')
        .data(_pie(settlements))
        .enter()
        .append('g')
        .attr('class', 'pie')

      pieGroup.append('path')
        .attr('d', _arc)
        .attr('fill', (d) -> _color(d.index))
        .attr('opacity', 0.5)

      pieGroup.append('text')
        .attr('fill', 'black')
        .attr('transform', (d) -> "translate(#{_text.centroid(d)})")
        .attr('dy', '5px')
        .attr('font', '10px')
        .attr('text-anchor', 'middle')
        .text((d) -> d.data.category)
      return
    return
