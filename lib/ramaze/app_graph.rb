require 'set'

module Ramaze
  ##
  # The AppGraph class can be used to generate a graph of all the URLs mapped in
  # a Ramaze application and saves this graph as an image.
  #
  # In order to generate a graph of your application all you need to do is the
  # following:
  #
  #     require 'ramaze/app_graph'
  #
  #     graph = Ramaze::AppGraph.new graph.generate graph.show
  #
  # Once this code is executed you can find the .dot and PNG files in the root
  # directory of your application.
  #
  # @author Michael Fellinger
  #
  class AppGraph
    ##
    # Creates a new instance of the class.
    #
    # @author Michael Fellinger
    #
    def initialize
      @out = Set.new
    end

    ##
    # Generates the graph based on all the current routes. The graph is saved in
    # the application directory.
    #
    # @author Michael Fellinger
    #
    def generate
      Ramaze::AppMap.to_hash.each do |location, app|
        connect(location => app.name)

        app.url_map.to_hash.each do |c_location, c_node|
          connect(app.name => c_node)
          connect(c_node.mapping => c_node)

          c_node.update_template_mappings
          c_node.view_templates.each do |wish, mapping|
            mapping.each do |action_name, template|
              action_path = File.join(c_node.mapping, action_name)
              connect(c_node => action_path, action_path => template)
            end
          end

          c_node.update_method_arities
          c_node.method_arities.each do |method, arity|
            action_path = File.join(c_node.mapping, method.to_s)
            connect(
              action_path => "#{c_node}##{method}[#{arity}]",
              c_node      => action_path
            )
          end
        end
      end
    end

    ##
    # Connects various elements in the graph to each other.
    #
    # @author Michael Fellinger
    #
    def connect(hash)
      hash.each do |from, to|
        @out << ("  %p -> %p;" % [from.to_s, to.to_s])
      end
    end

    ##
    # Writes the dot file containing the graph data.
    #
    # @author Michael Fellinger
    #
    def write_dot
      File.open('graph.dot', 'w+') do |dot|
        dot.puts 'digraph appmap {'
        dot.puts(*@out)
        dot.puts '}'
      end
    end

    ##
    # Generates a PNG file based on the .dot file.
    #
    # @author Michael Fellinger
    #
    def show
      write_dot
      options = {
        'rankdir' => 'LR',
        'splines' => 'true',
        'overlap' => 'false',
      }
      args = options.map{|k,v| "-G#{k}=#{v}" }
      system("dot -O -Tpng #{args.join(' ')} graph.dot")
      system('feh graph.dot.png')
    end
  end # AppGraph
end # Ramaze
