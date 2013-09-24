require 'java'

java_import 'java.util.concurrent.Callable'
java_import 'java.util.concurrent.FutureTask'
java_import 'java.util.concurrent.LinkedBlockingQueue'
java_import 'java.util.concurrent.ThreadPoolExecutor'
java_import 'java.util.concurrent.TimeUnit'
java_import 'java.util.concurrent.ExecutionException'
java_import 'java.util.concurrent.ExecutorService'
java_import 'java.util.concurrent.Executors'

module Threadable

  attr_accessor :executor
  attr_accessor :thread_count
  
  def initialize()
    puts "creating thread pool"
    @thread_count = 2
    @executor = Executors.new_fixed_thread_pool(@thread_count);
  end
  
  def run_task(o_task)
    o_future_task = FutureTask.new(o_task)
    @executor.execute(o_future_task);
  end
  
  def release()
    puts "releasing executor"
    @executor.shutdown()
  end

end