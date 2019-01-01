# encoding: UTF-8

module Sterile
  # @private
  class Data
    def self.smart_format_rules
      [
        ["'tain't", "’tain’t"],
        ["'twere", "’twere"],
        ["'twas", "’twas"],
        ["'tis", "’tis"],
        ["'twill", "’twill"],
        ["'til", "’til"],
        ["'bout", "’bout"],
        ["'nuff", "’nuff"],
        ["'round", "’round"],
        ["'cause", "’cause"],
        ["'cos", "’cos"],
        ["i'm", "i’m"],
        ['--"', "—“"],
        ["--'", "—‘"],
        ["--", "—"],
        ["...", "…"],
        ["(tm)", "™"],
        ["(TM)", "™"],
        ["(c)", "©"],
        ["(r)", "®"],
        ["(R)", "®"],
        [/\'(\d\d)(?!’|\')([\p{P}\p{Z}])/, "’\\1\\2"],
        # [/<p>"/, "<p>\\1″"],
        [/s\'([^a-zA-Z0-9])/, "s’\\1"],
        [/"([:;])/, "”\\1"],
        [/\'s$/, "’s"],
        [/\'(\d\d(?:’|\')?s)/, "’\\1"],
        [/(\s|\A|"|\(|\[)\'/, "\\1‘"],
        # [/(\d+)"/, "\\1″"],
        # [/(\d+)\'/, "\\1′"],
        [/(\S)\'([^\'\s])/, "\\1’\\2"],
        [/(\s|\A|\(|\[)"(?!\s)/, "\\1“\\2"],
        [/"(\s|\S|\Z)/, "”\\1"],
        [/\'([\s.]|\Z)/, "’\\1"],
        [/(\d+)x(\d+)/, "\\1×\\2"],
        [/([a-z])'(t|d|s|ll|re|ve)(\b)/i, "\\1’\\2\\3"],
      ]
    end
  end

  class << self
    private
     def smart_format_rules
       Data.smart_format_rules
     end
  end
end
