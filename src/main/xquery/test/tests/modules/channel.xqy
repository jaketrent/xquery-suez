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

declare function (:TEST:) isolate_unmatchedUrl() {
  let $url := "/some/url/"
  let $channels := <channels />
  let $actual := channel:isolate($url, $channels)
  return tu:assertEmpty($actual, "With url, no channels, no result")
};

declare function (:TEST:) isolate_matchWholeTree() {
  let $url := "/transplant/me/"
  let $channels :=
    <channels>
      <channel>
        <name>Transplant</name>
        <path>/transplant/me/</path>
      </channel>
    </channels>
  let $expected :=
    <channels>
      <channel active="true">
        <name>Transplant</name>
        <path>/transplant/me/</path>
      </channel>
    </channels>
  let $actual := channel:isolate($url, $channels)
  return tu:assertEq($actual, $expected, "Whole tree matched, tree returned")
};

declare function (:TEST:) isolate_matchLevel1() {
  let $url := "/salad/entree/"
  let $channels :=
    <channels>
      <channel>
        <name>Yay!</name>
        <path>/yay/bacon/</path>
      </channel>
      <channel>
        <name>With Bacon</name>
        <path>/salad/entree/</path>
      </channel>
    </channels>
  let $expected :=
    <channels>
      <channel>
        <name>Yay!</name>
        <path>/yay/bacon/</path>
      </channel>
      <channel active="true">
        <name>With Bacon</name>
        <path>/salad/entree/</path>
      </channel>
    </channels>
  let $actual := channel:isolate($url, $channels)
  return tu:assertEq($actual, $expected, "Match found on tree level1, make active")
};
  
declare function (:TEST:) isolate_matchLevel2() {
  let $url := "/bacon/hotpocket/"
  let $channels :=
    <channels>
      <channel>
        <name>Yay!</name>
        <path>/yay/bacon/</path>
      </channel>
      <channel>
        <name>With Bacon</name>
        <path>/salad/entree/</path>
        <channels>
          <channel>
            <name>Bacon Hotpocket</name>
            <path>/bacon/hotpocket/</path>
          </channel>
        </channels>
      </channel>
    </channels>
  let $expected :=
    <channels>
      <channel>
        <name>Yay!</name>
        <path>/yay/bacon/</path>
      </channel>
      <channel active="true">
        <name>With Bacon</name>
        <path>/salad/entree/</path>
        <channels>
          <channel active="true">
            <name>Bacon Hotpocket</name>
            <path>/bacon/hotpocket/</path>
          </channel>
        </channels>
      </channel>
    </channels>
  let $actual := channel:isolate($url, $channels)
  return tu:assertEq($actual, $expected, "Matched level2 channel, active path across levels")
};
