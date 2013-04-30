module Pushapp

  class Git

    def update_tracked_repos config
      refs         = required_refs(config)
      current_refs = current_refs(config)

      new_refs    = new_refs(refs, current_refs)
      old_refs    = old_refs(refs, current_refs)

      new_refs.each do |r|
        Pipe.run("git config --add remote.#{r[0]}.url #{r[1]}")  
      end

      old_refs.each do |r|
        Pipe.run("git config --unset remote.#{r[0]}.url #{r[1]}")  
      end      
    end

    private

    def new_refs refs, cur_refs
      refs.select do |r|
        cur_refs.all? {|cr| r != cr }
      end
    end

    def old_refs refs, cur_refs
      cur_refs.select do |cr|
        refs.all? {|r| r != cr }
      end
    end

    def current_refs config
      output = Pipe.capture('git remote -v')

      refs     = required_refs(config)
      remotes  = refs.map {|r| r[0]}.uniq
      
      current_refs = output.lines.map do |l|
        l.gsub(/\s\(.*\)?\Z/, "").chomp
      end
      current_refs = current_refs.uniq.map { |line| line.split(/\t/) }
      current_refs.select {|r| remotes.include?(r[0])}
    end

    def required_refs config
      refs = []
      config.remotes.each do |r|
        refs << [r.group, r.location] if r.group
        refs << [r.full_name, r.location]
      end
      refs
    end
  end
end