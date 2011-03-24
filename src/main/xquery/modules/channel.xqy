xquery version "1.0-ml";

module namespace channel = "http://missionary.lds.org/audience/cutlass/modules/channel";

declare option xdmp:mapping "false";

declare function isolate($url as xs:string?, $channels as element()?) as element()? {
  isolate($url, $channels, ())
};

declare function isolate($url as xs:string?, $channels as element()?, $options as element()?) as element()? {
  if (fn:exists($url) and fn:exists($channels)) then
    let $match := findDeepestChannel($url, $channels)
    return if (fn:exists($match)) then
      reverseBuildTree($match, (), $options)
    else
      ()
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
            addChildChannels($activeChannel, 0, $options)
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

declare function addChildChannels
    ( $activeChannel as element()
    , $numLevels as xs:int
    , $options as element()?
    ) as element()? {
  let $childLevels := $options/child-levels
  return if (fn:exists($childLevels) and $numLevels lt xs:int($options/child-levels)) then
    element channels {
      for $channel in $activeChannel/channels/channel
      return element channel {
        $channel/@*,
        $channel/(* except channels),
        addChildChannels($channel, $numLevels + 1, $options)
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