namespace :test_task do
  desc "test"
  task :test do
    p "W"
  end
  task :test_load_from_txt do
    st = Time.now
    wakachi_txt = "share/TSV_SUW_OT_all_normalized_wakachi.txt"
    open(wakachi_txt) do |f|
      while line=f.gets
      end
    end
    t = Time.now - st
    puts "Time: #{t} [s]"
  end
  task :test_load_from_db => :environment do
    st = Time.now
    Corpu.all.each do |line|
    end
    t = Time.now - st
    puts "Time: #{t} [s]"
  end
end
