xquery version "1.0-ml";

module namespace t = "http://missionary.lds.org/audience/cutlass/test/tests/modules/channel";

import module namespace channel = "http://missionary.lds.org/audience/cutlass/modules/channel" at "/modules/channel.xqy";
import module namespace tu = "http://lds.org/code/shared/xqtest/utils" at "/shared/xqtest/utils.xqy";

declare option xdmp:mapping "false";

declare function (:TEST:) isolate_noUrlNoChannels() {
  let $url := ()
  let $channels := ()
  let $actual := channel:isolate($url, $channels)
  return tu:assertEmpty($actual, "No url, no channel, no result")
};

declare function (:TEST:) isolate_noUrlWithChannels() {
  let $url := ()
  let $channels := <channels />
  let $actual := channel:isolate($url, $channels)
  return tu:assertEmpty($actual, "No url, with channels, no result")
};

declare function (:TEST:) isolate_withUrlNoChannels() {
  let $url := "/some/url/"
  let $channels := ()
  let $actual := channel:isolate($url, $channels)
  return tu:assertEmpty($actual, "With url, no channels, no result")
};
  
