-module (id3_v1).
-import (lists, [filter/2, map/2, reverse/1]).
-export ([test/0, dir/1, read_id3_tag/1]).

test() -> dir("/Users/duncan/Downloads").

