xquery version "1.0-ml";

module namespace t = "http://missionary.lds.org/audience/cutlass/test/tests/modules/sidebar";

import module namespace sidebar = "http://missionary.lds.org/audience/cutlass/modules/sidebar" at "/modules/sidebar.xqy";
import module namespace assert = "http://lds.org/code/shared/xqtest/assert" at "/shared/xqtest/assert.xqy";

declare option xdmp:mapping "false";

declare function (:TEST:) render_noChannels() {
  let $channels := ()
  let $expected := <ul>&nbsp;</ul>
  let $actual := sidebar:render($channels)
  return assert:equal($actual, $expected, "No channel, empty ul")
};

declare function (:TEST:) render_channelsNoChannel() {
  let $channels := <channels />
  let $expected := <ul>&nbsp;</ul>
  let $actual := sidebar:render($channels)
  return assert:equal($actual, $expected, "No channel data, empty ul")
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
  return assert:equal($actual, $expected/*, "One top level channel should render only header")
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
  return assert:equal($actual, $expected/*, "Multiple channels, default to 1st for header")
};

declare function (:TEST:) render_level2ListNoActive() {
  let $channels :=
    <channels>
      <channel>
        <name>Header</name>
        <path>/header/</path>
        <channels>
          <channel>
            <name>List Item 1</name>
            <path>/list/item/1/</path>
          </channel>
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
  return assert:equal($actual, $expected/*, "Level 2 channels go to level 1 list, no active if not set")
};
  
declare function (:TEST:) render_level3ListNoActive() {
  let $channels :=
    <channels>
      <channel>
        <name>Header</name>
        <path>/header/</path>
        <channels>
          <channel>
            <name>List Item 1</name>
            <path>/list/item/1/</path>
            <channels>
              <channel>
                <name>Indented Item 1</name>
                <path>/list/item/1/indented/1/</path>
              </channel>
            </channels>
          </channel>
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
  return assert:equal($actual, $expected/*, "Level 3 channels go to indented level 2 list, no active if not set")
};

declare function (:TEST:) render_activePathOver3Levels() {
  let $channels :=
    <channels>
      <channel active="true">
        <name>Header</name>
        <path>/header/</path>
        <channels>
          <channel>
            <name>List Item 1</name>
            <path>/list/item/1/</path>
          </channel>
          <channel active="true">
            <name>List Item 2</name>
            <path>/list/item/2/</path>
            <channels>
              <channel active="true">
                <name>Indented Item 2 - 1</name>
                <path>/list/item/2/indented/1/</path>
              </channel>
              <channel>
                <name>Indented Item 2 - 2</name>
                <path>/list/item/2/indented/2/</path>
              </channel>
            </channels>
          </channel>
        </channels>
      </channel>
    </channels>
  let $expected :=
    <expected>
      <h2><a href="/header/">Header</a></h2>
      <hr />
      <ul>
        <li><a href="/list/item/1/">List Item 1</a></li>
        <li>
          <a href="/list/item/2/">List Item 2</a>
          <ul>
            <li class="active"><a href="/list/item/2/indented/1/">Indented Item 2 - 1</a></li>
            <li><a href="/list/item/2/indented/2/">Indented Item 2 - 2</a></li>
          </ul>
        </li>
      </ul>
    </expected>
  let $actual := sidebar:render($channels)
  return assert:equal($actual, $expected/*, "Level 3 (lowest) link only gets the active class")
};