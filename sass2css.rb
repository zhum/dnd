require 'sassc'

      file = "test.sass"
      data = SassC::Engine.new(File.read(file), syntax: :sass, style: :compact).render
      puts data

