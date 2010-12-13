module Jekyll

  TAG_NAME_MAP = {
    "#"  => "sharp",
    "/"  => "slash",
    "\\" => "backslash",
    "."  => "dot",
    "+"  => "plus",
    " "  => "-"
  }

  # Holds tag information
  class Tag

    attr_accessor :dir, :name

    # ----------------------------------------------------------------------
    # Constructor
    # ----------------------------------------------------------------------

    def initialize(name)
      @name = name.downcase.strip
      @dir = name_to_dir(@name)
    end

    # ----------------------------------------------------------------------
    # Instance Methods
    # ----------------------------------------------------------------------

    def to_s
      @name
    end

    def eql?(tag)
      self.class.equal?(tag.class) && (name == tag.name)
    end

    def hash
      name.hash
    end

    def <=>(o)
      self.class == o.class ? (self.name <=> o.name) : nil
    end

    def inspect
      self.class.name + "[" + @name + ", " + @dir + "]"
    end

    def to_liquid
      # Liquid wants a hash, not an object.

      { "name" => @name, "dir" => @dir }
    end

    # ----------------------------------------------------------------------
    # Class Methods
    # ----------------------------------------------------------------------

    def self.sort(tags)
      tags.sort { |t1, t2| t1 <=> t2 }
    end

    # ----------------------------------------------------------------------
    # Private definitions
    # ----------------------------------------------------------------------

    private

    def name_to_dir(name)
      s = ""
      name.each_char do |c|
        if (c =~ /[-A-Za-z0-9_]/) != nil
          s += c
        else
          c2 = TAG_NAME_MAP[c]
          if not c2
            msg = "Bad character '#{c}' in tag '#{name}'"
            puts("*** #{msg}")
            raise FatalException.new(msg)
          end
          s += c2
        end
      end
      s
    end
  end
end
