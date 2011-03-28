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

declare function (:TEST:) isolate_getClosestMatchToSpecificMatch() {
  let $url := "/something/very/specific/"
  let $channels :=
    <channels>
      <channel>
        <name>Something</name>
        <path>/something/</path>
      </channel>
    </channels>
  let $expected :=
    <channels>
      <channel active="true">
        <name>Something</name>
        <path>/something/</path>
      </channel>
    </channels>
  let $actual := channel:isolate($url, $channels)
  return tu:assertEq($actual, $expected, "Hierarchal urls should match at more general levels if url isn't specified")
};

declare function (:TEST:) isolate_buildOneChildLevel() {
  let $url := "/parent/"
  let $channels :=
    <channels>
      <channel>
        <name>Parent</name>
        <path>/parent/</path>
        <channels>
          <channel>
            <name>Child 1</name>
            <path>/parent/child1/</path>
          </channel>
        </channels>
      </channel>
    </channels>
  let $options :=
    <options>
      <child-levels>1</child-levels>
    </options>
  let $expected :=
    <channels>
      <channel active="true">
        <name>Parent</name>
        <path>/parent/</path>
        <channels>
          <channel>
            <name>Child 1</name>
            <path>/parent/child1/</path>
          </channel>
        </channels>
      </channel>
    </channels>
  let $actual := channel:isolate($url, $channels, $options)
  return tu:assertEq($actual, $expected, "Option of inactive child channels gets respect")
};

declare function (:TEST:) isolate_buildTwoChildLevel() {
  let $url := "/parent/"
  let $channels :=
    <channels>
      <channel>
        <name>Parent</name>
        <path>/parent/</path>
        <channels>
          <channel>
            <name>Child 1</name>
            <path>/parent/child1/</path>
            <channels>
              <channel>
                <name>Grandchild 1</name>
                <path>/parent/child/grandchild/</path>
              </channel>
            </channels>
          </channel>
        </channels>
      </channel>
    </channels>
  let $options :=
    <options>
      <child-levels>2</child-levels>
    </options>
  let $expected :=
    <channels>
      <channel active="true">
        <name>Parent</name>
        <path>/parent/</path>
        <channels>
          <channel>
            <name>Child 1</name>
            <path>/parent/child1/</path>
            <channels>
              <channel>
                <name>Grandchild 1</name>
                <path>/parent/child/grandchild/</path>
              </channel>
            </channels>
          </channel>
        </channels>
      </channel>
    </channels>
  let $actual := channel:isolate($url, $channels, $options)
  return tu:assertEq($actual, $expected, "Child-levels can go multiple levels deep")
};

declare function (:TEST:) isolate_buildOneChildLevelWhenTwoExist() {
  let $url := "/parent/"
  let $channels :=
    <channels>
      <channel>
        <name>Parent</name>
        <path>/parent/</path>
        <channels>
          <channel>
            <name>Child 1</name>
            <path>/parent/child1/</path>
            <channels>
              <channel>
                <name>Grandchild 1</name>
                <path>/parent/child/grandchild/</path>
              </channel>
            </channels>
          </channel>
        </channels>
      </channel>
    </channels>
  let $options :=
    <options>
      <child-levels>1</child-levels>
    </options>
  let $expected :=
    <channels>
      <channel active="true">
        <name>Parent</name>
        <path>/parent/</path>
        <channels>
          <channel>
            <name>Child 1</name>
            <path>/parent/child1/</path>
          </channel>
        </channels>
      </channel>
    </channels>
  let $actual := channel:isolate($url, $channels, $options)
  return tu:assertEq($actual, $expected, "Child-levels can go multiple levels deep")
};

declare function (:TEST:) isolate_buildMaxChildLevelsIfSetToMore() {
  let $url := "/parent/"
  let $channels :=
    <channels>
      <channel>
        <name>Parent</name>
        <path>/parent/</path>
        <channels>
          <channel>
            <name>Child 1</name>
            <path>/parent/child1/</path>
          </channel>
        </channels>
      </channel>
    </channels>
  let $options :=
    <options>
      <child-levels>4</child-levels>
    </options>
  let $expected :=
    <channels>
      <channel active="true">
        <name>Parent</name>
        <path>/parent/</path>
        <channels>
          <channel>
            <name>Child 1</name>
            <path>/parent/child1/</path>
          </channel>
        </channels>
      </channel>
    </channels>
  let $actual := channel:isolate($url, $channels, $options)
  return tu:assertEq($actual, $expected, "If the child-levels option is more than what exists, show what exists")
};

declare function (:TEST:) isolate_buildOneChildLevelMultipleChildren() {
  let $url := "/parent/"
  let $channels :=
    <channels>
      <channel>
        <name>Parent</name>
        <path>/parent/</path>
        <channels>
          <channel>
            <name>Child 1</name>
            <path>/parent/child1/</path>
          </channel>
          <channel>
            <name>Child 2</name>
            <path>/parent/child2/</path>
          </channel>
        </channels>
      </channel>
    </channels>
  let $options :=
    <options>
      <child-levels>1</child-levels>
    </options>
  let $expected :=
    <channels>
      <channel active="true">
        <name>Parent</name>
        <path>/parent/</path>
        <channels>
          <channel>
            <name>Child 1</name>
            <path>/parent/child1/</path>
          </channel>
          <channel>
            <name>Child 2</name>
            <path>/parent/child2/</path>
          </channel>
        </channels>
      </channel>
    </channels>
  let $actual := channel:isolate($url, $channels, $options)
  return tu:assertEq($actual, $expected, "Child-levels must print all children")
};

declare function (:TEST:) isolate_showOnlyActiveChannelsSubchannel() {
  let $url := "/channel/active/subchannel/"
  let $channels :=
    <channels>
      <channel>
        <name>Active Channel</name>
        <path>/channel/active/</path>
        <channels>
          <channel>
            <name>Active Subchannel</name>
            <path>/channel/active/subchannel/</path>
          </channel>
        </channels>
      </channel>
      <channel>
        <name>Inactive Channel</name>
        <path>/channel/inactive/</path>
        <channels>
          <channel>
            <name>Inactive Subchannel</name>
            <path>/channel/inactive/subchannel/</path>
          </channel>
        </channels>
      </channel>
    </channels>
  let $expected :=
    <channels>
      <channel active="true">
        <name>Active Channel</name>
        <path>/channel/active/</path>
        <channels>
          <channel active="true">
            <name>Active Subchannel</name>
            <path>/channel/active/subchannel/</path>
          </channel>
        </channels>
      </channel>
      <channel>
        <name>Inactive Channel</name>
        <path>/channel/inactive/</path>
      </channel>
    </channels>
  let $actual := channel:isolate($url, $channels)
  return tu:assertEq($actual, $expected, "Subchannels should only be shown along active path into the tree")
};

declare function (:TEST:) isolate_noMatch1Level() {
  let $url := "/no/match/"
  let $channels :=
    <channels>
      <channel>
        <name>Still Shown</name>
        <path>/even/without/match/</path>
      </channel>
    </channels>
  let $options :=
    <options>
      <no-match-levels>1</no-match-levels>
    </options>
  let $expected :=
    <channels>
      <channel>
        <name>Still Shown</name>
        <path>/even/without/match/</path>
      </channel>
    </channels>
  let $actual := channel:isolate($url, $channels, $options)
  return tu:assertEq($actual, $expected, "No url match can give you level of inactive children")
};

declare function (:TEST:) isolate_noMatch3Levels2LevelsExists() {
  let $url := "/no/match/"
  let $channels :=
    <channels>
      <channel>
        <name>Still Shown</name>
        <path>/even/without/match/</path>
        <channels>
          <channel>
            <name>Should Show</name>
            <path>/also/shown/</path>
          </channel>
        </channels>
      </channel>
    </channels>
  let $options :=
    <options>
      <no-match-levels>3</no-match-levels>
    </options>
  let $expected :=
    <channels>
      <channel>
        <name>Still Shown</name>
        <path>/even/without/match/</path>
        <channels>
          <channel>
            <name>Should Show</name>
            <path>/also/shown/</path>
          </channel>
        </channels>
      </channel>
    </channels>
  let $actual := channel:isolate($url, $channels, $options)
  return tu:assertEq($actual, $expected, "If the no-match-levels option is more than what exists, show what exists")
};

declare function (:TEST:) isolate_noMatch1Level2Exist() {
  let $url := "/no/match/"
  let $channels :=
    <channels>
      <channel>
        <name>Still Shown</name>
        <path>/even/without/match/</path>
        <channels>
          <channel>
            <name>Not Shown</name>
            <path>/exists/but/too/deep/</path>
          </channel>
        </channels>
      </channel>
    </channels>
  let $options :=
    <options>
      <no-match-levels>1</no-match-levels>
    </options>
  let $expected :=
    <channels>
      <channel>
        <name>Still Shown</name>
        <path>/even/without/match/</path>
      </channel>
    </channels>
  let $actual := channel:isolate($url, $channels, $options)
  return tu:assertEq($actual, $expected, "Show no more child levels than the no-match option specifies")
};

declare function (:TEST:) isolate_limitDeep1Level2Exist() {
  let $url := "/as/deepest/"
  let $channels :=
    <channels>
      <channel>
        <name>Not Shown</name>
        <path>/even/though/shallower/</path>
        <channels>
          <channel>
            <name>Show</name>
            <path>/as/deepest/</path>
          </channel>
        </channels>
      </channel>
    </channels>
  let $options :=
    <options>
      <limit-deep-levels>1</limit-deep-levels>
    </options>
  let $expected :=
    <channels>
      <channel active="true">
        <name>Show</name>
        <path>/as/deepest/</path>
      </channel>
    </channels>
  let $actual := channel:isolate($url, $channels, $options)
  return tu:assertEq($actual, $expected, "Explicitly limit levels shown with limit-levels")
};



