KrakenPublic = require './local/KrakenPublic'
KrakenPrivate = require './local/KrakenPrivate'

class Kraken

  constructor: (@api_key, @private_key) ->

  ###
  #
  # Public market data
  #
  ###

  time: ->
    krak = new KrakenPublic 'Time'
    krak.api()
    .then (response) =>
      response.result

  assets: (assets...) ->
    options = {}
    if assets?
      assets = assets[0] if Array.isArray assets[0]
      assets = assets.join ','
      options.assets = assets
    krak = new KrakenPublic 'Assets' , options
    krak.api()
    .then (response) =>
      response.result

  assetPairs: (pairs...) ->
    options = {}
    if pairs?
      pairs = pairs[0] if Array.isArray pairs[0]
      pairs = pairs.join ','
      options.pairs = pairs
    krak = new KrakenPublic 'AssetPairs' , options
    krak.api()
    .then (response) =>
      response.result

  ticker: (pairs...) ->
    pairs = pairs[0] if Array.isArray pairs[0]
    pairs = pairs.join ','
    krak = new KrakenPublic 'Ticker' , pair: pairs
    krak.api()
    .then (response) =>
      response.result

  bidAsk: (pairs...) ->
    @ticker (pairs)
    .then (result) ->
      obj = {}
      for pair, data of result
        val = (parseFloat(data.a[0]) + parseFloat(data.b[0])) / 2
        obj[pair] = +val.toFixed 8
      obj


  ohlc: (pair, interval, last) ->
    options = pair: pair
    options.interval = interval if interval
    options.last = last if last
    krak = new KrakenPublic 'OHLC', options
    krak.api()
    .then (response) =>
      response.result

  depth: (pair, count) ->
    options = pair: pair
    options.count = count if count
    krak = new KrakenPublic 'Depth', options
    krak.api()
    .then (response) =>
      response.result

  trades: (pair, since) ->
    options = pair: pair
    options.since = since if since
    krak = new KrakenPublic 'Trades', options
    krak.api()
    .then (response) =>
      response.result

  spread: (pair, since) ->
    options = pair: pair
    options.since = since if since
    krak = new KrakenPublic 'Spread', options
    krak.api()
    .then (response) =>
      response.result

  ###
  #
  # Private user data
  #
  ###

  balance: ->
    krak = new KrakenPrivate 'Balance', @api_key, @private_key
    krak.api()
    .then (response) =>
      response.float().result

  tradeBalance: (currency) ->
    params = {}
    params.asset = currency if currency
    krak = new KrakenPrivate 'TradeBalance', @api_key, @private_key, params
    krak.api()
    .then (response) =>
      response.float().result

  openOrders: (trades, userref) ->
    params = {}
    params.trades = trades if trades?
    params.userref = userref if userref
    krak = new KrakenPrivate 'OpenOrders', @api_key, @private_key, params
    krak.api()
    .then (response) =>
      response.result

  closedOrders: (trades, userref, start, end, ofs, closetime) ->
    params = {}
    params.trades = trades if trades?
    params.userref = userref if userref
    params.start = start if start
    params.end = end if end
    params.ofs = ofs if ofs
    params.closetime = closetime if closetime
    krak = new KrakenPrivate 'ClosedOrders', @api_key, @private_key, params
    krak.api()
    .then (response) =>
      response.result

  queryOrders: (txids, trades, userref) ->
    txids = [ txids ] unless Array.isArray txids
    params = txid: txids.join ','
    params.trades = trades if trades?
    params.userref = userref if userref
    krak = new KrakenPrivate 'QueryOrders', @api_key, @private_key, params
    krak.api()
    .then (response) =>
      response.result

  tradesHistory: (type, trades, start, end, ofs) ->
    params = {}
    params.type = type if type?
    params.trades = trades if trades?
    params.start = start if start
    params.end = end if end
    params.ofs = ofs if ofs
    krak = new KrakenPrivate 'TradesHistory', @api_key, @private_key, params
    krak.api()
    .then (response) =>
      response.result

  queryTrades: (txids, trades) ->
    txids = [ txids ] unless Array.isArray txids
    params = txid: txids.join ','
    params.trades = trades if trades?
    krak = new KrakenPrivate 'QueryTrades', @api_key, @private_key, params
    krak.api()
    .then (response) =>
      response.result

  openPositions: (docalcs, txids) ->
    params = {}
    if txids?
      txids = [ txids ] unless Array.isArray txids
      params.txid = txids.join ','
    params.docalcs = docalcs if docalcs?
    krak = new KrakenPrivate 'OpenPositions', @api_key, @private_key, params
    krak.api()
    .then (response) =>
      response.result

  profitLoss: (bypair) ->
    @openPositions true
    .then (result) =>
      profits = {}
      for key, item of result
        currency = if bypair then item.pair else item.pair.substr -3
        profits[currency] ?= 0
        profits[currency] += parseFloat item.net
      profits

  ledgers: (assets, type, start, end, ofs) ->
    params = {}
    if assets?
      assets = [ assets ] unless Array.isArray assets
      params.asset = assets.join ','
    params.type = type if type
    params.start = start if start
    params.end = end if end
    params.ofs = ofs if ofs
    krak = new KrakenPrivate 'Ledgers', @api_key, @private_key, params
    krak.api()
    .then (response) =>
      response.result

  queryLedgers: (ids...) ->
    ids = ids[0] if Array.isArray ids[0]
    params = id: ids.join ','
    krak = new KrakenPrivate 'QueryLedgers', @api_key, @private_key, params
    krak.api()
    .then (response) =>
      response.result

  tradeVolume: (pairs...) ->
    params = 'fee-info': true
    pairs = pairs[0] if Array.isArray pairs[0]
    params.pair = pairs.join ',' if pairs.length > 0
    krak = new KrakenPrivate 'TradeVolume', @api_key, @private_key, params
    krak.api()
    .then (response) =>
      response.result

  ###
  #
  # Private user trading
  #
  ###

  addOrder: (pair, type, ordertype, volume, price, price2, leverage,
    oflags, starttm, expiretm, userref, valdate,
    closetype, closeprice, closeprice2 ) ->
    # if the first parameter is an abject, use that as params
    if pair is Object pair
      params = pair
    else
      params = {
      pair
      type
      ordertype
      volume
      }
      params.price = price if price?
      params.price2 = price2 if price2?
      params.leverage = leverage if leverage?
      params.oflags = if Array.isArray oflags then oflags.join ',' else oflags
      params.starttm = starttm if starttm?
      params.expiretm = expiretm if expiretm?
      params.userref = userref if userref?
      params.validate = validate if validate?
      if closetype?
        params['close[ordertype]'] = closetype
        params['close[price]'] = closeprice
        params['close[price2]'] = closeprice2 if closeprice2?
    krak = new KrakenPrivate 'AddOrder', @api_key, @private_key, params
    krak.api()
    .then (response) =>
      response.result

  cancelOrder: (txid) ->
    krak = new KrakenPrivate 'CancelOrder', @api_key, @private_key, txid: txid
    krak.api()
    .then (response) =>
      response.result

  ###
  #
  # Private user funding
  #
  ###

  depositMethods: (asset) ->
    krak = new KrakenPrivate 'DepositMethods', @api_key, @private_key, asset: asset
    krak.api()
    .then (response) =>
      response.result

  depositAddresses: (asset, method, newAddress) ->
    params = {
      asset
      method
    }
    params.new = newAddress if newAddress?
    krak = new KrakenPrivate 'DepositAddresses', @api_key, @private_key, params
    krak.api()
    .then (response) =>
      response.result

  depositStatus: (asset, method) ->
    params = {
      asset
      method
    }
    krak = new KrakenPrivate 'DepositStatus', @api_key, @private_key, params
    krak.api()
    .then (response) =>
      response.result

  withdrawInfo: (asset, key, amount) ->
    params = {
      asset
      key
      amount
    }
    krak = new KrakenPrivate 'WithdrawInfo', @api_key, @private_key, params
    krak.api()
    .then (response) =>
      response.result

  withdraw: (asset, key, amount) ->
    params = {
      asset
      key
      amount
    }
    krak = new KrakenPrivate 'Withdraw', @api_key, @private_key, params
    krak.api()
    .then (response) =>
      response.result


  withdrawStatus: (asset, method) ->
    params = asset: asset
    params.method = method if method?
    krak = new KrakenPrivate 'WithdrawStatus', @api_key, @private_key, params
    krak.api()
    .then (response) =>
      response.result

  withdrawCancel: (asset, refid) ->
    params = {
      asset
      refid
    }
    krak = new KrakenPrivate 'WithdrawCancel', @api_key, @private_key, params
    krak.api()
    .then (response) =>
      response.result


module.exports = Kraken
