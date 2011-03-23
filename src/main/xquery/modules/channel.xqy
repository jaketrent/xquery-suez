xquery version "1.0-ml";

module namespace channel = "http://missionary.lds.org/audience/cutlass/modules/channel";

declare option xdmp:mapping "false";

declare function isolate($url as xs:string?, $channels as element()*) as element()? {
  if (fn:exists($url)) then
    let $match := $channels//channel[path eq $url]
    return if (fn:exists($match)) then
      reverseBuildTree($match, ())
    else
      ()
  else
    ()
};

declare function reverseBuildTree($activeChannel as element()?, $newTree as element()?) as element()? {
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