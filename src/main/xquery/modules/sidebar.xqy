xquery version "1.0-ml";

module namespace sidebar = "http://missionary.lds.org/audience/cutlass/modules/sidebar";

declare option xdmp:mapping "false";

declare function render($channels as element()?) as element()? {
  if (fn:exists($channels)) then
    ()
  else
    element ul { "&nbsp;" }
};