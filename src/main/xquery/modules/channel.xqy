xquery version "1.0-ml";

module namespace channel = "http://missionary.lds.org/audience/cutlass/modules/channel";

declare option xdmp:mapping "false";

declare function isolate($url as xs:string?, $channels as element()?) as element()? {
  if (fn:exists($url) and fn:exists($channels)) then
    let $match := findDeepestChannel($url, $channels)
    return if (fn:exists($match)) then
      reverseBuildTree($match, ())
    else
      ()
  else
    ()
};

declare function findDeepestChannel($url as xs:string, $channels as element()?) as element()? {
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

declare private function reverseBuildTree($activeChannel as element()?, $newTree as element()?) as element()? {
  if (fn:empty($activeChannel)) then
    $newTree
  else
    let $newLevel :=
      element channels {
        $activeChannel/preceding-sibling::channel,
        element channel {
          attribute active {
            "true"
          },
          $activeChannel/@*,
          $activeChannel/(* except channels),
          $newTree
        },
        $activeChannel/following-sibling::channel
      }
    let $shallowerChannel := $activeChannel/../..
    return reverseBuildTree($shallowerChannel, $newLevel)
};

(:~ @see http://www.xqueryfunctions.com/xq/functx_substring-before-last.html ~:)
declare function substring-before-last($arg as xs:string?, $delim as xs:string) as xs:string {
    if (fn:matches($arg, escape-for-regex($delim))) then
        fn:replace($arg, fn:concat('^(.*)', escape-for-regex($delim), '.*'), '$1')
    else ''
};

(:~ @see http://www.xqueryfunctions.com/xq/functx_escape-for-regex.html ~:)
declare function escape-for-regex($arg as xs:string?) as xs:string {
    fn:replace($arg, '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))', '\\$1')
} ;