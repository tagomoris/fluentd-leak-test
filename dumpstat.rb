require 'objspace'
require 'mallinfo'

def dump_process_stat h
  # {count_objects: ObjectSpace.count_objects, gc_stat: GC.stat}
  GC.start
  GC.stat(h)
  "#{h[:total_allocated_object]}\t#{h[:total_freed_object]}\t#{h[:heap_used]}\t#{h[:heap_length]}\t" + 
  "#{ObjectSpace.memsize_of_all()}\t" +
  #"#{GC.malloc_allocated_size}\t" +
  "#{ObjectSpace.mallinfo.values.join("\t")}\t" + 
  "#{File.read("/proc/self/statm").split(/\s+/).join("\t")}"
end

require 'pp'
Thread.new do
  Thread.current.abort_on_exception = true
  h = {}
  while true
    puts dump_process_stat(h); STDOUT.flush
    sleep 1
  end
end
