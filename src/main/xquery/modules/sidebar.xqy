xquery version "1.0-ml";

module namespace sidebar = "http://missionary.lds.org/audience/cutlass/modules/sidebar";

declare option xdmp:mapping "false";

declare function render($channels as element()?) as element()* {
  if (fn:exists($channels) and fn:exists($channels/channel)) then
    ( renderHeader($channels/channel[1])
    , renderList($channels/channel[1]/channels)
    )
  else
    element ul { "&nbsp;" }
};

declare private function renderHeader($channel as element()) as element()* {
  element h2 {
    renderLink($channel)
  },
  element hr {}
};

declare private function renderList($channels as element()?) as element()? {
  if (fn:exists($channels/channel)) then
    element ul {
      for $ch in $channels/channel
      return element li {
        ( if (isActiveLink($ch)) then
            attribute class {
              "active"
            }
          else
            ()
        , renderLink($ch)
        , renderList($ch/channels)
        ) 
      }
    }
  else
    ()
};

declare function isActiveLink($channel as element()) as xs:boolean {
  fn:empty($channel/channels) and xs:string($channel/@active) eq "true"
};

declare private function renderLink($channel as element()) as element() {
  element a {
    attribute href {
      $channel/path/text()
    },
    $channel/name/text()
  }
};
