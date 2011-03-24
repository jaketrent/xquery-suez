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
  
declare function (:TEST:) render_headerOnly() {
  let $channels :=
    <channels>
      <channel>
        <name>Header</name>
        <path>/header/</path>
      </channel>
    </channels>
  let $expected :=
    <expected>
      <h2><a href="/header/">Header</a></h2>
      <hr />
    </expected>
  let $actual := sidebar:render($channels)
  return tu:assertEq($actual, $expected/*, "One top level channel should render only header")
};
  
declare function (:TEST:) render_headerOnlyMultipleLevel1Channel() {
  let $channels :=
    <channels>
      <channel>
        <name>Header</name>
        <path>/header/</path>
      </channel>
      <channel>
        <name>My renderer</name>
        <path>/will/take/the first/</path>
      </channel>
    </channels>
  let $expected :=
    <expected>
      <h2><a href="/header/">Header</a></h2>
      <hr />
    </expected>
  let $actual := sidebar:render($channels)
  return tu:assertEq($actual, $expected/*, "Multiple channels, default to 1st for header")
};

declare function (:TEST:) render_level2ListNoActive() {
  let $channels :=
    <channels>
      <channel>
        <name>Header</name>
        <path>/header/</path>
        <channels>
          <name>List Item 1</name>
          <path>/list/item/1/</path>
        </channels>
      </channel>
    </channels>
  let $expected :=
    <expected>
      <h2><a href="/header/">Header</a></h2>
      <hr />
      <ul>
        <li><a href="/list/item/1/">List Item 1</a></li>
      </ul>
    </expected>
  let $actual := sidebar:render($channels)
  return tu:assertEq($actual, $expected/*, "Level 2 channels go to level 1 list, no active if not set")
};
  
declare function (:TEST:) render_level3ListNoActive() {
  let $channels :=
    <channels>
      <channel>
        <name>Header</name>
        <path>/header/</path>
        <channels>
          <name>List Item 1</name>
          <path>/list/item/1/</path>
          <channels>
            <channel>
              <name>Indented Item 1</name>
              <path>/list/item/1/indented/1/</path>
            </channel>
          </channels>
        </channels>
      </channel>
    </channels>
  let $expected :=
    <expected>
      <h2><a href="/header/">Header</a></h2>
      <hr />
      <ul>
        <li>
          <a href="/list/item/1/">List Item 1</a>
          <ul>
            <li>
              <a href="/list/item/1/indented/1/">Indented Item 1</a>
            </li>
          </ul>
        </li>
      </ul>
    </expected>
  let $actual := sidebar:render($channels)
  return tu:assertEq($actual, $expected/*, "Level 3 channels go to indented level 2 list, no active if not set")
};