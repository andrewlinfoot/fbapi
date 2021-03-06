class FbApi
  constructor: (fbAuth) ->
    if fbAuth
      @auth = fbAuth
    else
      # Auth current user
      fbAuth = new FbAuth()
      fbAuth.authCurrentUser()
      @auth = fbAuth

  baseApiUrl: 'https://graph.facebook.com'
  version: 'v2.6'
  api: ->
    return "#{@baseApiUrl}/#{@version}"

  call: (type, urlFragment, params = {}) ->
    url = @api() + urlFragment
    @_call type, url, params

  _call: (type, url, params = {}) ->
    params.access_token = @auth?.accessToken
    options =
      params: params
    response = HTTP.call type, url, options
    return response.data

  get: (urlFragment, params) ->
    @call 'GET', urlFragment, params

  post: (urlFragment, params) ->
    @call 'POST', urlFragment, params

  pageThroughResults: (response, data = []) ->
    data = data.concat response.data
    next = response.paging?.next
    if next isnt undefined
      response = @_call 'GET', next
      return @pageThroughResults response, data
    else
      return data

  # Docs:
  # https://developers.facebook.com/docs/graph-api/reference/user/accounts/
  getUserPages: (params = {}) ->
    url = '/me/accounts'
    response = @get url, params
    @pageThroughResults response

  # Docs:
  # https://developers.facebook.com/docs/marketing-api/reference/ad-account
  getUserAdAccounts: (params = {}) ->
    url = '/me/adaccounts'
    response = @get url, params
    @pageThroughResults response

  # Docs:
  # https://developers.facebook.com/docs/graph-api/reference/v2.4/page/feed
  createPagePost: (pageId, params = {}) ->
    url = "/#{pageId}/feed"
    # Defaults to unpublished if not specified
    params.published or= 0
    @post url, params

  # Docs:
  # https://developers.facebook.com/docs/marketing-api/generatepreview/v2.4
  generateAdPreview: (adAccount, params = {}) ->
    url = "/#{adAccount}/generatepreviews"
    response = @get url, params
    return response.data[0].body

  # Docs:
  # https://developers.facebook.com/docs/marketing-api/adcreative/v2.4
  createAdCreative: (adAccount, params = {}) ->
    url = "/#{adAccount}/adcreatives"
    @post url, params

  # Docs:
  # https://developers.facebook.com/docs/marketing-api/reference/ad-campaign-group
  createAdCampaign: (adAccount, params = {}) ->
    url = "/#{adAccount}/campaigns"
    @post url, params

  # Docs:
  # https://developers.facebook.com/docs/marketing-api/reference/ad-campaign
  createAdSet: (adAccount, params = {}) ->
    url = "/#{adAccount}/adsets"
    @post url, params

  # Docs:
  # https://developers.facebook.com/docs/marketing-api/adgroup/v2.4
  createAd: (adAccount, params = {}) ->
    url = "/#{adAccount}/ads"
    @post url, params

  # Docs:
  # https://developers.facebook.com/docs/marketing-api/targeting-search/v2.4
  search: (params = {}) ->
    url = "/search"
    @get(url, params).data

  updateObject: (objectId, params = {}) ->
    url = "/#{objectId}"
    @post url, params

  getObject: (objectId, params = {}) ->
    url = "/#{objectId}"
    @get url, params

  ###
  # Edges
  #   Valid objectIds:
  #
  #   Docs:
  #   https://developers.facebook.com/docs/marketing-api/reference/ad-campaign-group
  #   AdCampaign: adcampaigns(ad sets), adgroups(ads), insights, stats
  #
  #   Docs:
  #   https://developers.facebook.com/docs/marketing-api/reference/ad-campaign
  #   AdSets: activities, adcreatives, adgroups(ads), asyncadgrouprequests,
  #     reachestimate, targetingsentencelines, insights, conversions, stats
  #
  #   Docs:
  #   https://developers.facebook.com/docs/marketing-api/adgroup/v2.4
  #   Ad: adcreatives, keywordstats, previews, reachestimate, stats,
  #     targetingsentencelines, trackingtag, conversions, insights
  #
  ###
  getAdsEdge: (objectId, params = {}, pageThroughResults = false) ->
    url = "/#{objectId}/adgroups"
    response = @get url, params
    if pageThroughResults
      return @pageThroughResults response
    else
      return response.data


  getAdSetsEdge: (objectId, params = {}, pageThroughResults = false) ->
    url = "/#{objectId}/adcampaigns"
    response = @get url, params
    if pageThroughResults
      return @pageThroughResults response
    else
      return response.data

  getInsightsEdge: (objectId, params = {}, pageThroughResults = false) ->
    url = "/#{objectId}/insights"
    response = @get url, params
    if pageThroughResults
      return @pageThroughResults response
    else
      return response.data

  getReachEstimateEdge: (objectId, params = {}) ->
    url = "/#{objectId}/reachestimate"
    @get(url, params).data
