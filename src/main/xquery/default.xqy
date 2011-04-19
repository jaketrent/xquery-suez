xquery version "1.0-ml";

import module namespace channel = "http://missionary.lds.org/audience/cutlass/modules/channel" at "/modules/channel.xqy";
import module namespace sidebar = "http://missionary.lds.org/audience/cutlass/modules/sidebar" at "/modules/sidebar.xqy";

declare option xdmp:mapping "false";

let $activeUrl := xdmp:get-request-field("url", "/dress-grooming/grooming/")
let $channels := fn:collection()/channels[@app eq "suez"]
let $options :=
  <options>
    <no-match-levels>3</no-match-levels>
    <limit-shallow-levels>3</limit-shallow-levels>
  </options>
let $sidebar := channel:render($activeUrl, $channels, xdmp:function(xs:QName("sidebar:render")), $options)

return
(
xdmp:set-response-content-type( "text/html" ),
'<!DOCTYPE html>',
<html>
  <head>
    <title>Xquery-suez Demo</title>
    <link rel="stylesheet" href="/media/css/sidebar.css" />
  </head>
  <body>
    <h1>Xquery Suez Demo</h1>
    <div class="sidebar">
      {$sidebar}
    </div>
  </body>
</html>
)
  
