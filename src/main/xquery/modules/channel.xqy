xquery version "1.0-ml";

module namespace channel = "http://missionary.lds.org/audience/cutlass/modules/channel";

declare option xdmp:mapping "false";

declare function isolate($url as xs:string?, $channels as element()*) as element()? {
  if (fn:exists($url)) then
    if (fn:exists($channels/channel[path eq $url])) then
      $channels
    else
      ()
  else
    ()
};