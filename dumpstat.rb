def dump_process_stat
  {count_objects: ObjectSpace.count_objects, gc_stat: GC.stat}
end

require 'pp'
Thread.new do
  while true
    pp dump_process_stat
    sleep 10
  end
end
