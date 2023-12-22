color = false
cache = true
std = 'max+love'
-- globals = {'DEBUGMODE', 'PROJECTNAME', 'VERSION', 'idiv', 'gr' ,'pp', 'issubclass', 'play'}
globals = {'DEBUGMODE', 'PROJECTNAME', 'VERSION', 'idiv', 'gr' ,'pp', 'L', 'issubclass' }
self = false
max_line_length = false
max_code_line_length  = false
ignore = {'122', '142', '143', '212/self', '311/_continue_.*', '431/self', '432/self', '214'}
-- 122: mathなどに対して追加で識別子を定める
-- 142: ioなどに対して追加で識別子を定める
-- 143: 143で定めたものを使う
-- 212: 使っていない引数(ただしselfのみ)を警告しない
-- 311: セットした値が使われない(ただしyueが生成する_continue_0などのみ)
-- 431: shadowing upvalue(ただしyueが生成するselfのみ無視する)
-- max_cyclomatic_complexity = 10
