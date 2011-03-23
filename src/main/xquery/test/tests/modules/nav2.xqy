xquery version "1.0-ml";

module namespace t = "http://missionary.lds.org/audience/cutlass/test/tests/modules/nav2";

import module namespace nav2 = "http://missionary.lds.org/audience/cutlass/modules/nav2" at "/modules/nav2.xqy";
import module namespace tu = "http://lds.org/code/shared/xqtest/utils" at "/shared/xqtest/utils.xqy";

declare option xdmp:mapping "false";

declare function (:TEST:) isolateChannels_noUrlNoChannels() {
  let $url := ()
  let $channels := ()
  let $actual := nav2:isolateChannels($url, $channels)
  return tu:assertEmpty($actual, "No url, no channel, no result")
};

declare function (:TEST:) isolateChannels_noUrlWithChannels() {
  let $url := ()
  let $channels := <channels />
  let $actual := nav2:isolateChannels($url, $channels)
  return tu:assertEmpty($actual, "No url, with channels, no result")
};

declare function (:TEST:) isolateChannels_withUrlNoChannels() {
  let $url := "/some/url/"
  let $channels := ()
  let $actual := nav2:isolateChannels($url, $channels)
  return tu:assertEmpty($actual, "With url, no channels, no result")
};
