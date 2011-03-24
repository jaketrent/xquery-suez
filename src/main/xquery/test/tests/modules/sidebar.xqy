xquery version "1.0-ml";

module namespace t = "http://missionary.lds.org/audience/cutlass/test/tests/modules/sidebar";

import module namespace sidebar = "http://missionary.lds.org/audience/cutlass/modules/sidebar" at "/modules/sidebar.xqy";
import module namespace tu = "http://lds.org/code/shared/xqtest/utils" at "/shared/xqtest/utils.xqy";

declare option xdmp:mapping "false";

declare function (:TEST:) render_noChannels() {
  let $channels := ()
  let $expected := <ul>&nbsp;</ul>
  let $actual := sidebar:render($channels)
  return tu:assertEq($actual, $expected, "No channel, empty ul")
};

declare function (:TEST:) render_channelsNoChannel() {
  let $channels := <channels />
  let $expected := <ul>&nbsp;</ul>
  let $actual := sidebar:render($channels)
  return tu:assertEq($actual, $expected, "No channel data, empty ul")
};