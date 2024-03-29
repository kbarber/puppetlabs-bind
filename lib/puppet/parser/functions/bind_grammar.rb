Puppet::Parser::Functions::newfunction(:bind_grammar, 
  :type => :rvalue, 
  :doc => "Converts Puppet variables to Bind grammar.") do |args|

  raise(Puppet::ParseError, "bind_grammar(): Wrong number of arguments " +
      "given (#{args.size} for 2)") if args.size != 2

  def puppet2bind (arg, pvar, input = "")
    output = input

    string_args = ["directory", "file", "journal", "ixfr-base", "ixfr-tmp-file", "database"]

    case pvar.class.to_s
    when "Hash"
      output << " " + pvar.keys[0]
      pvar[pvar.keys[0]].each { |key, value|
        output << " " + key.to_s + " " + value.to_s
      }
      output << ";"
      return output
    when "Array"
      output << " {"
      pvar.each { |key|
        if key.class == Hash then
          puppet2bind(arg, key, output)
        else
          output << " " + key + ";"
        end
      }
      output << " };"
      return output
    when "String"
      if string_args.include?(arg) then
        output << " \"" + pvar + "\";"
      else
        output << " " + pvar + ";"
      end
      return output
    else
      exit("Fail!")
    end
  end
  
  args[0] + puppet2bind(args[0], args[1])
end
