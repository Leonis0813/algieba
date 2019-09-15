class window.Pie
  constructor: (id, width, height, radius) ->
    _svg = d3.select("##{id}")
      .attr('width', width)
      .attr('height', height)
    _g = _svg.append('g').attr('transform', "translate(#{width / 2},#{height / 2})")
    _arc = d3.arc().outerRadius(radius).innerRadius(0)
    _pie = d3.pie().value((d) -> d.price)
    _text = d3.arc().outerRadius(radius - 30).innerRadius(radius - 30)

    @draw = (settlements) ->
      colors = _generateColors(settlements.length)

      pieGroup = _g.selectAll('.pie')
        .data(_pie(settlements))
        .enter()
        .append('g')
        .attr('class', 'pie')

      pieGroup.append('path')
        .attr('d', _arc)
        .attr('fill', (d) -> colors[d.index])
        .attr('opacity', 0.5)

      pieGroup.append('text')
        .attr('fill', 'black')
        .attr('transform', (d) -> "translate(#{_text.centroid(d)})")
        .attr('dy', '5px')
        .attr('font', '10px')
        .attr('text-anchor', 'middle')
        .text((d) -> d.data.category)
      return

    _generateColors = (size) ->
      deg = Math.round( 320 / size );
      h = 0
      s = 0.8
      v = 0.8
      colors = []
      for i in [0...size]
        hi = Math.floor(h / 60) % 6
        f = h / 60 - hi
        p = v * (1 - s)
        q = v * (1 - f * s)
        t = v * (1 - (1 - f) * s)
        h += deg
        [r, g, b] = [0, 0, 0]

        switch hi
          when 0
            [r, g, b] = [v, t, p]
          when 1
            [r, g, b] = [q, v, p]
          when 2
            [r, g, b] = [p, v, t]
          when 3
            [r, g, b] = [p, q, v]
          when 4
            [r, g, b] = [t, p, v]
          when 5
            [r, g, b] = [v, p, q]

        colors[i] = "##{_hex(r)}#{_hex(g)}#{_hex(b)}"
      return colors

    _hex = (x) ->
      tmp = Math.round(x * 255).toString(16)
      if(tmp.length < 2)
        return "0#{tmp}"
      else
        return tmp
    return
