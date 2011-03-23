xquery version "1.0-ml";

module namespace channel = "http://missionary.lds.org/audience/cutlass/modules/channel";

declare option xdmp:mapping "false";

declare function isolate($url as xs:string?, $channels as element()*) as element()? {
  if (fn:exists($url)) then
    let $match := $channels/channel[path eq $url]
    return if (fn:exists($match)) then
      element channels {
        $match/preceding-sibling::channel,
        element channel {
          attribute active {
            "true"
          },
          $match/@*,
          $match/*
        },
        $match/following-sibling::channel
      }
    else
      ()
  else
    ()
};