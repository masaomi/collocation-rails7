#!/usr/bin/env ruby
# encoding: utf-8
# Version = '20221111-110341'

require 'parallel'
require 'ruby-progressbar'

unless word_list_txt=ARGV[0]
  puts <<-eos
  usage:
   #{File.basename(__FILE__)} [word_list.txt]
  required:
   * scripts/count_words_calc_jaccard_plus_pmi_tscore_v4.rb
  option:
   * --threads: number of threads (default: 1)
   * --wakachi-txt: wakachi.txt (default: wakachi/TSV_SUW_OT_all_normalized_wakachi.txt)
  eos
  exit
end

wakachi_txt = if i=ARGV.index("--wakachi-txt")
                ARGV[i+1]
              else
                "wakachi/TSV_SUW_OT_all_normalized_wakachi.txt"
              end
threads = if i=ARGV.index("--threads")
            ARGV[i+1].to_i
          else
            1
          end

raise "#{wakachi_txt} not found" unless File.exist?(wakachi_txt)

commands = File.readlines(word_list_txt).to_a.map{|line| 
  word = line.chomp
  "ruby scripts/count_words_calc_jaccard_plus_pmi_tscore_v4.rb #{wakachi_txt} 差別 #{word} --simple-output"
  }
#require 'pp'
#pp commands

progress = ProgressBar.create(title: "Progress", total: commands.length, format: '%a %B %p%% %t', output: $stderr)
result = Parallel.map(commands, in_threads: threads, finish: -> (item, i, res){ progress.increment }) do |command|
  `#{command}`
end


headers = ["word1", "word2", "jaccard", "miscore", "tscore"]
puts headers.join("\t")
puts result.join

