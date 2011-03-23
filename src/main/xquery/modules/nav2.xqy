xquery version "1.0-ml";

module namespace nav2 = "http://missionary.lds.org/audience/cutlass/modules/nav2";

declare option xdmp:mapping "false";

declare function isolateChannels($url as xs:string?, $channels as element()*) as element()? {
  ()
};