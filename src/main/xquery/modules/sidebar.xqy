xquery version "1.0-ml";

module namespace sidebar = "http://missionary.lds.org/audience/cutlass/modules/sidebar";

declare option xdmp:mapping "false";

declare function render($channels as element()?) as element()* {
  if (fn:exists($channels) and fn:exists($channels/channel)) then
    renderHeader($channels/channel[1])
  else
    element ul { "&nbsp;" }
};

declare function renderHeader($channel as element()?) as element()* {
  element h2 {
    element a {
      attribute href {
        $channel/path/text()
      },
      $channel/name/text()
    }
  },
  element hr {}
};