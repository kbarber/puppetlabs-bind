Puppet::Parser::Functions::newfunction(:bind_grammar, 
  :type => :rvalue, 
  :doc => "Converts Puppet variables to Bind grammar.") do |args|

  def puppet2bind (arg, pvar, input = "")
    output = input
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
      if ["file", "journal", "ixfr-base", "ixfr-tmp-file", "database"].include?(arg) then
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
