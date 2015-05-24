require 'readline'
require 'irb/completion'
require 'irb/ext/save-history'
require 'wirb'

IRB.conf[:USE_READLINE] = true
IRB.conf[:SAVE_HISTORY] = 10_000
IRB.conf[:HISTORY_FILE] = File.expand_path('~/.irb_history')
IRB.conf[:AUTO_INDENT] = true
Wirb.start
