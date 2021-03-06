###!
* jQuery POP'n SocialButton v0.1.5 - custom
*
* http://github.com/ktty1220/jquery.popn-socialbutton
*
* 参考: http://q.hatena.ne.jp/1320898356
* 参考: http://stackoverflow.com/questions/5699270/how-to-get-share-counts-using-graph-api
*
* Copyright (c) 2013 ktty1220 ktty1220@gmail.com
* Licensed under the MIT license
###
#jshint jquery:true, forin:false

do (jQuery) ->
  'use strict'
  $ = jQuery

  $.fn.popnSocialButton = (services, options = {}) ->
    exOptions = $.extend {},
      url: location.href
      text: $('title').html()
      imgDir: './img'
      buttonSpace: 24
      countPosition:
        top: 32
        right: -12
      countColor:
        text: '#ffffff'
        bg: '#cc0000'
        textHover: '#ffffff'
        bgHover: '#ff6666'
        border: '#ffffff'
      countSize: 10
    , options
    exOptions.urlOrg = exOptions.url
    exOptions.url = encodeURIComponent exOptions.url
    exOptions.text = encodeURIComponent exOptions.text

    iconSize = 44
    popnUp = 4

    servicesProp =
      twitter:
        img: 'twitter_2x.png'
        alt: 'Twitter Share Button'
        shareUrl: "https://twitter.com/share?url=#{exOptions.url}&text=#{exOptions.text}"
        commentUrl: "https://twitter.com/search/?q=#{exOptions.url}"
        countUrl: "http://urls.api.twitter.com/1/urls/count.json?url=#{exOptions.url}"
        jsonpFunc: (json, cb) -> cb(json.count ? 0)

      facebook:
        img: 'facebook_2x.png'
        alt: 'Facebook Share Button'
        shareUrl: "http://www.facebook.com/sharer.php?u=#{exOptions.url}&t=#{exOptions.text}"
        countUrl: "https://graph.facebook.com/#{exOptions.url}"
        jsonpFunc: (json, cb) ->
          ###
          * - Graph APIでsharesが取得できない場合はFQLでtotal_countを取得する
          * - Graph APIのlikes + FQLのtotal_countでいいねボタンと同じ件数になる模様(いくつかのケースを調べた結果)
          * - ほとんどのサイトではFQLのtotal_countだけでいいねボタンと同じ件数になる
          ###
          return cb(json.shares) if json.shares?
          graphLikes = json.likes ? 0
          $.ajax
            url: "https://graph.facebook.com/fql?q=#{encodeURIComponent "SELECT total_count FROM link_stat WHERE url='#{exOptions.url}'"}"
            dataType: 'jsonp'
          .done (json) ->
            fqlTotal = json.data[0]?.total_count ? 0
            cb(graphLikes + fqlTotal)

      hatebu:
        img: 'hatena_bookmark_2x.png'
        alt: 'Hatena Bookmark Share Button'
        shareUrl: "http://b.hatena.ne.jp/add?mode=confirm&url=#{exOptions.url}&title=#{exOptions.text}&mode=confirm"
        commentUrl: "http://b.hatena.ne.jp/entry/#{exOptions.urlOrg}"
        countUrl: "http://api.b.st-hatena.com/entry.count?url=#{exOptions.url}"
        jsonpFunc: (json, cb) -> cb(json ? 0)

      github:
        img: 'github_alt@2x.png'
        alt: 'GitHub Repository'
        shareUrl: "https://github.com/#{exOptions.githubRepo}"
        commentUrl: "https://github.com/#{exOptions.githubRepo}/stargazers"
        countUrl: "https://api.github.com/repos/#{exOptions.githubRepo}"
        jsonpFunc: (json, cb) -> cb(json.data.watchers ? 0)

    _addLink = (name, prop, idx) =>
      wrapTag = $('<div/>').attr(
        class: "popn-socialbutton-wrap #{name}"
      ).css
        'float': 'left'
        position: 'relative'
        width: iconSize
        height: iconSize
        marginTop: popnUp
      wrapTag.css marginLeft: exOptions.buttonSpace if idx > 0

      shareTag = $('<a/>').attr(
        href: prop.shareUrl
        class: 'popn-socialbutton-share'
        target: '_blank'
      ).css
        outline: 'none'
        display: 'block'
        width: '100%'
        height: '100%'

      imgTag = $('<img/>').attr(
        src: "#{exOptions.imgDir}/#{prop.img}"
        alt: prop.alt
      ).css
        border: 'none'

      countTagType = if prop.commentUrl then 'a' else 'span'
      countTag = $("<#{countTagType}/>").attr class: 'popn-socialbutton-count'
      if countTagType is 'a'
        countTag.attr
          href: prop.commentUrl
          target: '_blank'
      else
        countTag.css cursor: 'default'

      countTag.css $.extend {},
        display: 'none'
        position: 'absolute'
        color: exOptions.countColor.text
        backgroundColor: exOptions.countColor.bg
        border: "solid 2px #{exOptions.countColor.border}"
        fontSize: exOptions.countSize
        textDecoration: 'none'
        outline: 'none'
        fontWeight: 'bold'
        #lineHeight: 1.5
        padding: '0 4px'
        borderRadius: 6
        boxShadow: '0 1px 2px rgba(0, 0, 0, 0.8)'
        zIndex: 1
      , exOptions.countPosition

      wrapTag.append(shareTag.append(imgTag)).append countTag
      $(@).append wrapTag

      $.ajax
        url: prop.countUrl
        dataType: 'jsonp'
      .done (json) -> prop.jsonpFunc json, (count) -> countTag.show().text count

    for sName, idx in services
      _addLink sName, servicesProp[sName], idx if servicesProp[sName]?
    $(@).height iconSize + popnUp

    $(@).find('.popn-socialbutton-share').click () ->
      top = (screen.height / 2) - 180
      left = (screen.width / 2) - 240
      window.open @href, '', "width=520, height=400, top=#{top}, left=#{left}"
      false

    $(@).find('a.popn-socialbutton-count').mouseenter () ->
      $(@).css
        color: exOptions.countColor.textHover
        backgroundColor: exOptions.countColor.bgHover
    .mouseleave () ->
      $(@).css
        color: exOptions.countColor.text
        backgroundColor: exOptions.countColor.bg

    $(@).find('.popn-socialbutton-wrap').mouseenter () ->
      $(@).stop().animate marginTop: 0, 100, 'swing'
    .mouseleave () ->
      $(@).stop().animate marginTop: 4, 100, 'swing'
