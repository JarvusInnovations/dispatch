# Most of this is from https://github.com/basecamp/local_time

App.timestamps = {}

App.timestamps.weekdays = "Sunday Monday Tuesday Wednesday Thursday Friday Saturday".split " "
App.timestamps.months   = "January February March April May June July August September October November December".split " "

if isNaN Date.parse "2011-01-01T12:00:00-05:00"
  parse = Date.parse
  iso8601 = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(Z|[-+]?[\d:]+)$/

  Date.parse = (dateString) ->
    dateString = dateString.toString()
    if matches = dateString.match iso8601
      [_, year, month, day, hour, minute, second, zone] = matches
      offset = zone.replace(":", "") if zone isnt "Z"
      dateString = "#{year}/#{month}/#{day} #{hour}:#{minute}:#{second} GMT#{[offset]}"
    parse dateString

pad = (num) -> ('0' + num).slice -2

strftime = (time, formatString) ->
  day    = time.getDay()
  date   = time.getDate()
  month  = time.getMonth()
  year   = time.getFullYear()
  hour   = time.getHours()
  minute = time.getMinutes()
  second = time.getSeconds()

  formatString.replace /%\-?([%aAbBcdeHIlmMpPSwyYZ])/g, (str) ->
    switch str.replace('%', '')
      when 'a'        then App.timestamps.weekdays[day].slice 0, 3
      when 'A'        then App.timestamps.weekdays[day]
      when 'b'        then App.timestamps.months[month].slice 0, 3
      when 'B'        then App.timestamps.months[month]
      when 'c'        then time.toString()
      when 'd'        then pad date
      when 'e', '-e'  then date
      when 'H'        then pad hour
      when 'I'        then pad strftime time, '%l'
      when 'l', '-l'  then (if hour is 0 or hour is 12 then 12 else (hour + 12) % 12)
      when 'm'        then pad month + 1
      when '-m'       then month + 1
      when 'M'        then pad minute
      when 'p'        then (if hour > 11 then 'PM' else 'AM')
      when 'P'        then (if hour > 11 then 'pm' else 'am')
      when 'S'        then pad second
      when 'w'        then day
      when 'y'        then pad year % 100
      when 'Y'        then year
      when 'Z'        then time.toString().match(/\((\w+)\)$/)?[1] ? ''

App.formatTime = (date, format) ->
  strftime(date, t("time.formats.#{format}"))

$.fn.extend formattedTimestamps: ->
  $(@).find('[data-formatted-timestamp]').each ->
    return if @hasFormattedTimestamp
    @hasFormattedTimestamp = true

    format = $(@).data('formatted-timestamp')

    if format == 'relative'
      return $(@).timeago()

    stamp = new Date(Date.parse($(@).attr('datetime')))
    formatted = App.formatTime stamp, format
    $(@).text formatted
