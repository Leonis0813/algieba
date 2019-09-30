class window.SettlementByCategory
  @WIDTH = 500
  @HEIGHT = 500
  @RADIUS = Math.min(SettlementByCategory.WIDTH, SettlementByCategory.HEIGHT) / 2 - 10

  constructor: ->
    @draw = (payment_type) ->
      pie = new Pie(
        payment_type,
        SettlementByCategory.WIDTH,
        SettlementByCategory.HEIGHT,
        SettlementByCategory.RADIUS
      )

      d3.json("api/settlements/category?payment_type=#{payment_type}").then((data) ->
        pie.draw(data.settlements)
        return
      )
      return
    return
