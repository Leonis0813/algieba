@draw = ->
  margin = {top: 50, right: 50, bottom: 50, left: 80}
  width = window.innerWidth- margin.left - margin.right
  height = window.innerHeight - margin.top - margin.bottom - 50

  x = d3.scaleBand().rangeRound([0, width])
  y = d3.scaleLinear().range([height, 0])

  xAxis = d3.axisBottom(x)
  yAxis = d3.axisLeft(y)

  svg = d3.select("body")
    .append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

  d3.json("statistics/settlements", (error, data) ->
    x.domain(data.map((d) ->
      return d.date
    ))
    min = d3.min(data, (d) ->
      return d.price
    )
    max = d3.max(data, (d) ->
      return d.price
    )
    y.domain([min, max])

    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis)

    svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
      .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text("Frequency")

    svg.selectAll(".bar")
      .data(data)
      .enter()
      .append("rect")
      .attr("class", "bar")
      .attr("x", (d) ->
        return x(d.date)
      )
      .attr("width", x.bandwidth())
      .attr("y", (d) ->
        if d.price < 0
          return y(0)
        else
          return y(d.price)
      )
      .attr("height", (d) ->
        if d.price < 0
          return y(d.price) - y(0)
        else
          return y(0) - y(d.price)
      )
      .attr("fill", (d) ->
        if d.price < 0
          return "red"
        else
          return "green"
      )
      .attr("opacity", 0.3)
      .on("mouseover", (d, i) ->
        svg.append("text")
          .attr("id", () ->
            return "price" + i
          )
          .attr("x", () ->
            return x(d.date)
          )
          .attr("y", () ->
            return y(d.price) - 15
          )
          .text(() ->
            return d.price
          )
        return
      )
      .on("mouseout", (d, i) ->
        d3.select("#price" + i).remove()
        return
      )
  )
  return
