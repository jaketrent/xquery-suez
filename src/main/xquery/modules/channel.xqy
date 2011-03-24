xquery version "1.0-ml";

module namespace channel = "http://missionary.lds.org/audience/cutlass/modules/channel";

declare option xdmp:mapping "false";

declare function render
    ( $url as xs:string?
    , $channels as element()?
    , $renderer as xdmp:function
    ) as element()* {
  render($url, $channels, $renderer, ())
};

declare function render
    ( $url as xs:string?
    , $channels as element()?
    , $renderer as xdmp:function
    , $options as element()?
    ) as element()* {
  let $channels := isolate($url, $channels, $options)
  return xdmp:apply($renderer, $channels)
};

declare function isolate($url as xs:string?, $channels as element()?) as element()? {
  isolate($url, $channels, ())
};

declare function isolate($url as xs:string?, $channels as element()?, $options as element()?) as element()? {
  if (fn:exists($url) and fn:exists($channels)) then
    let $match := findDeepestChannel($url, $channels)
    return if (fn:exists($match)) then
      reverseBuildTree($match, (), $options)
    else
      addChildChannels(element channel { $channels }, 0,
        xdmp:function(xs:QName("channel:lessThanNoMatchLevel")), $options)
  else
    ()
};

declare private function findDeepestChannel($url as xs:string, $channels as element()?) as element()? {
  let $match := $channels//channel[path eq $url]
  return if (fn:exists($match)) then
    $match
  else
    let $shallowerUrl := rmOneUrlLevel($url)
    return if ($shallowerUrl eq "/") then
      ()
    else
      findDeepestChannel($shallowerUrl, $channels)
};

declare private function rmOneUrlLevel($url as xs:string) as xs:string {
  let $extra :=
    if (fn:ends-with($url, "/")) then
      substring-before-last($url, "/")
    else
      $url
  let $once := substring-before-last($extra, "/")
  return fn:concat($once, "/")
};

declare private function reverseBuildTree
    ( $activeChannel as element()?
    , $newTree as element()?
    , $options as element()?
    ) as element()? {
  if (fn:empty($activeChannel)) then
    $newTree
  else
    let $newLevel :=
      element channels {
        getChannelNoSubchannels($activeChannel/preceding-sibling::channel),
        element channel {
          attribute active {
            "true"
          },
          $activeChannel/@*,
          $activeChannel/(* except channels),
          if (fn:exists($newTree)) then
            $newTree
          else
            addChildChannels($activeChannel, 0, xdmp:function(xs:QName("channel:lessThanChildLevel")), $options)
        },
        getChannelNoSubchannels($activeChannel/following-sibling::channel)
      }
    let $shallowerChannel := $activeChannel/../..
    return reverseBuildTree($shallowerChannel, $newLevel, $options)
};

declare function getChannelNoSubchannels($channels as element()*) as element()* {
  for $ch in $channels
  return element channel {
    $ch/@*,
    $ch/(* except channels)
  }
};

declare private function lessThanChildLevel($levelsAdded as xs:int, $options as element()?) as xs:boolean {
  fn:exists($options/child-levels) and $levelsAdded lt xs:int($options/child-levels)
};

declare private function lessThanNoMatchLevel($levelsAdded as xs:int, $options as element()?) as xs:boolean {
  fn:exists($options/no-match-levels) and $levelsAdded lt xs:int($options/no-match-levels)
};

declare private function addChildChannels
    ( $activeChannel as element()?
    , $levelsAdded as xs:int
    , $okToAddLevel as xdmp:function
    , $options as element()?
    ) as element()? {
  if (xdmp:apply($okToAddLevel, $levelsAdded, $options) and fn:exists($activeChannel/channels/channel)) then
    element channels {
      for $channel in $activeChannel/channels/channel
      return element channel {
        $channel/@*,
        $channel/(* except channels),
        addChildChannels($channel, $levelsAdded + 1, $okToAddLevel, $options)
      }
    }
  else
    ()
};

(:~ @see http://www.xqueryfunctions.com/xq/functx_substring-before-last.html ~:)
declare private function substring-before-last($arg as xs:string?, $delim as xs:string) as xs:string {
    if (fn:matches($arg, escape-for-regex($delim))) then
        fn:replace($arg, fn:concat('^(.*)', escape-for-regex($delim), '.*'), '$1')
    else ''
};

(:~ @see http://www.xqueryfunctions.com/xq/functx_escape-for-regex.html ~:)
declare private function escape-for-regex($arg as xs:string?) as xs:string {
    fn:replace($arg, '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))', '\\$1')
} ;