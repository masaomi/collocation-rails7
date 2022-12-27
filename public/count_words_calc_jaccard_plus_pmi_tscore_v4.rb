#!/usr/bin/env ruby
# encoding: utf-8
# Version = '20221116-090551'

unless wakachi_txt=ARGV[0] and search_word1=ARGV[1] and search_word2=ARGV[2]
  puts <<-eos
  usage:
   #{File.basename(__FILE__)} [chunagon_out_wakatchi.txt] [search_word1] [search_word2]
  option:
   --simple-output: print search words, jaccard, MI score, and T score, and show off warning
   --print-header: purint header
  eos
  exit
end

simple_output = ARGV.index("--simple-output")
if simple_output
  def warn(x)
  end
end
print_header = ARGV.index("--print-header")

all_words = {}
open(wakachi_txt) do |f|
  while line=f.gets
    line_hash = Hash[*line.chomp.split.uniq.map{|word| [word, true]}.flatten]
    #p line_hash.keys[0, 10]
    all_words.merge!(line_hash)
  end
end

#p all_words.keys[0,10]
total_words = all_words.keys.length
#total_words = 104911460 # from chunagon
search_word1_count = {}
search_word2_count = {}
open(wakachi_txt) do |f|
  while line=f.gets
    line_words = line.chomp.split
    line_words.each_cons(10).with_index do |words, i|
      begin
        word = words.first
        if word !~ /\.|\!|\?|\*|\]|\[|\(|\)|\+|\^/ 
          if word.length >= search_word1.length and (search_word1 =~ /#{word}/ or word =~ /#{search_word1}/)
            search_word1_count[words] ||= 0
            search_word1_count[words] += 1
          end
          if word.length >= search_word2.length and (search_word2 =~ /#{word}/ or word =~ /#{search_word2}/) 
            search_word2_count[words] ||= 0
            search_word2_count[words] += 1
          end
        end
      rescue => e
        warn e
        warn "skip: #{words}"
      end
    end
  end
end

warn "# search_word1_count: #{search_word1_count.keys.length}"
warn "# search_word2_count: #{search_word2_count.keys.length}"
warn ""

# require 'pp'
# pp search_word1_count
# pp search_word2_count
# exit

search_word1_contexts = {}
search_word2_contexts = {}
open(wakachi_txt) do |f|
  while line=f.gets
    line_words = line.chomp.split
    total_words_in_line = line_words.length
    line_words.each_cons(10).with_index do |words, i|
      begin
        word = words.first
        if word !~ /\.|\!|\?|\*|\]|\[|\(|\)|\+|\^/ 
          if word.length >= search_word1.length and (search_word1 =~ /#{word}/ or word =~ /#{search_word1}/)
            start_pos = [0, i-500].max
            end_pos = [total_words_in_line, i+500].min
            search_word1_contexts[words] ||= line_words[start_pos..end_pos]
          end
          if word.length >= search_word2.length and (search_word2 =~ /#{word}/ or word =~ /#{search_word2}/) 
            start_pos = [0, i-500].max
            end_pos = [total_words_in_line, i+500].min
            search_word2_contexts[words] ||= line_words[start_pos..end_pos]
          end
        end
      rescue => e
        warn e
        warn "skip: #{words}"
      end
    end
  end
end

warn "# search_word1_contexts: #{search_word1_contexts.keys.length}"
warn "# search_word2_contexts: #{search_word2_contexts.keys.length}"
warn ""

search_word1_count_in_context_of_word2 = {}
search_word2_contexts.values.each do |context|
  context.each_cons(10) do |words|
    begin
      word = words.first
      if word !~ /\.|\!|\?|\*|\]|\[|\(|\)|\+|\^/ 
        if word.length >= search_word1.length and (search_word1 =~ /#{word}/ or word =~ /#{search_word1}/)
          search_word1_count_in_context_of_word2[words] ||= 0
          search_word1_count_in_context_of_word2[words] += 1
        end
      end
    rescue
      #warn "skip: #{words}"
    end
  end
end

search_word2_count_in_context_of_word1 = {}
search_word1_contexts.values.each do |context|
  context.each_cons(10) do |words|
    begin
      word = words.first
      if word !~ /\.|\!|\?|\*|\]|\[|\(|\)|\+|\^/ 
        if word.length >= search_word2.length and (search_word2 =~ /#{word}/ or word =~ /#{search_word2}/)
          search_word2_count_in_context_of_word1[words] ||= 0
          search_word2_count_in_context_of_word1[words] += 1
        end
      end
    rescue
      #warn "skip: #{words}"
    end
  end
end

warn "#"*20
warn "# A: #{search_word1} in #{wakachi_txt}: #{search_word1_count.keys.length}"
a = search_word1_count.keys.length
warn "# B: #{search_word2} in #{wakachi_txt}: #{search_word2_count.keys.length}"
b = search_word2_count.keys.length
warn "# C: #{search_word1} in context of #{search_word2}: #{search_word1_count_in_context_of_word2.keys.length}"
c = search_word1_count_in_context_of_word2.keys.length
warn "# D: #{search_word2} in context of #{search_word1}: #{search_word2_count_in_context_of_word1.keys.length}"
d = search_word2_count_in_context_of_word1.keys.length

warn ""
require 'pp'
warn "# B:"
warn "# #{search_word2_count_in_context_of_word1.sort.each_with_index.map{|x, i| (i+1).to_s + ". " + x.first.join + ": " + x.last.to_s}.pretty_inspect}"
warn "# C:"
warn "# #{search_word1_count_in_context_of_word2.sort.each_with_index.map{|x, i| (i+1).to_s + ". " + x.first.join + ": " + x.last.to_s }.pretty_inspect}"
warn ""

x_and_y = (search_word1_count_in_context_of_word2.keys.length + search_word2_count_in_context_of_word1.keys.length) / 2.0
x_or_y  = (search_word1_count.keys.length + search_word2_count.keys.length) - x_and_y
jaccard = x_and_y / x_or_y

warn "# n(X∩Y) = (B + C)/2.0 = (#{search_word1_count_in_context_of_word2.keys.length} + #{search_word2_count_in_context_of_word1.keys.length})/2.0 = #{x_and_y}"
warn "# n(X∪Y) = (A + D) - n(X∩Y) = (#{search_word1_count.keys.length} + #{search_word2_count.keys.length}) - #{x_and_y} = #{x_or_y}"
warn "# Jaccard = n(X∩Y)/n(X∪Y) = #{x_and_y}/#{x_or_y} = #{"%.3e" % jaccard}"
warn ""

search_word1_frequency = search_word1_count.keys.length / total_words.to_f
search_word2_frequency = search_word2_count.keys.length / total_words.to_f
search_word12_cooccurrence_frequency = x_and_y / total_words.to_f
e = search_word1_frequency
f = search_word2_frequency
g = search_word12_cooccurrence_frequency

warn "# total words: #{total_words}"
warn "# D: #{search_word1} frequency: #{search_word1_count.keys.length} / #{total_words} = #{"%.3e" % search_word1_frequency}"
warn "# E: #{search_word2} frequency: #{search_word2_count.keys.length} / #{total_words} = #{"%.3e" % search_word2_frequency}"
warn "# F: #{search_word1} and #{search_word2} co-occurrence frequency: n(X∩Y)/(total words) = #{x_and_y} / #{total_words} = #{"%.3e" % search_word12_cooccurrence_frequency}"

pmi1 = Math.log2(search_word12_cooccurrence_frequency / (search_word1_frequency * search_word2_frequency))
pmi2 = Math.log2((x_and_y * total_words) / (search_word1_count.keys.length * search_word2_count.keys.length))
raise "something is wrong" if (pmi1 - pmi2) > 1e-10

warn "# MI score (PMI, Pointwise Mutual Information) = log2(C / (A * B)) = log2(#{"%.3e" % search_word12_cooccurrence_frequency} / (#{"%.3e" % search_word1_frequency} * #{"%.3e" % search_word2_frequency})) = #{"%.3f" % pmi2}"
warn ""

tscore = (x_and_y - (search_word1_count.keys.length * search_word2_count.keys.length)/total_words) / Math.sqrt(x_and_y)

warn "# T score = (n(X∩Y) - (A * D)/total_words) / (n(X∩Y))^(-2) = (#{x_and_y} - (#{search_word1_count.keys.length} * #{search_word2_count.keys.length})/#{total_words}) / (#{x_and_y})^(-2) = #{"%.3f" % tscore}"
warn ""

headers = ["word1", "word2", "jaccard", "miscore", "tscore", "A", "B", "C", "D", "E", "F", "G"]
puts headers.join("\t") if print_header
puts [search_word1, search_word2, "%.3e" % jaccard, "%.3e" % pmi1, "%.3e" % tscore, a, b, c, d, "%.3e" % e, "%.3e" % f, "%.3e" % g].join("\t") if simple_output

warn ""
warn "# Ref:"
warn "# 1. 自然言語処理における自己相互情報量 (Pointwise Mutual Information, PMI) https://camberbridge.github.io/2016/07/08/%E8%87%AA%E5%B7%B1%E7%9B%B8%E4%BA%92%E6%83%85%E5%A0%B1%E9%87%8F-Pointwise-Mutual-Information-PMI-%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6/"
warn "# 2. コロケーションと語彙分析 http://www.ic.daito.ac.jp/~mizutani/mining/collocation.html"

