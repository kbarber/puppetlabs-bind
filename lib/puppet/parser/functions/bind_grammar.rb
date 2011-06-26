Puppet::Parser::Functions::newfunction(:bind_grammar, 
  :type => :rvalue, 
  :doc => "Converts Puppet variables to Bind grammar.") do |args|
     
  def puppet2bind (pvar, input = "")
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
          puppet2bind(key, output)
        else
          output << " " + key + ";"
        end
      }
      output << " };"
      return output
    when "String"
      output << " " + pvar + ";"
      return output
    else
      exit("asdf")
    end
  end
  
  puppet2bind(argv[0])
end