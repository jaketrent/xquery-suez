xquery version "1.0-ml";

module namespace channel = "http://missionary.lds.org/audience/cutlass/modules/channel";

declare option xdmp:mapping "false";

declare function isolateChannels($url as xs:string?, $channels as element()*) as element()? {
  ()
};