module Jekyll
  class Post
    alias :real_initialize :initialize

    def initialize(site, source, dir, name)
      begin
        real_initialize(site, source, dir, name)
      rescue Exception => ex
        $stderr.puts("*** In #{name}")
        raise ex
      end
    end
  end
end
