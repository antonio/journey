module Journey
  module Definition
    class Node < Struct.new(:type, :children) # :nodoc:
      include Enumerable

      class Visitor # :nodoc:
        def accept node
          visit node
        end

        private

        def visit node
          send "visit_#{node.type}", node
        end

        def nary node
          node.children.each { |x| visit x }
        end
        alias :visit_GROUP :nary
        alias :visit_CAT :nary
        alias :visit_STAR :nary

        def terminal node; end
        alias :visit_LITERAL :terminal
        alias :visit_SYMBOL :terminal
        alias :visit_SLASH :terminal
      end

      ##
      # Loop through the requirements AST
      class Each < Visitor # :nodoc:
        attr_reader :block

        def initialize block
          @block = block
        end

        def visit node
          block.call node
          super
        end
      end

      class String < Visitor
        private

        def visit_CAT node
          node.children.map { |x| visit x }.join
        end

        def visit_STAR node
          "*" + visit_CAT(node)
        end

        def visit_SLASH node
          node.children
        end

        def visit_LITERAL node
          node.children
        end

        def visit_SYMBOL node
          node.children
        end

        def visit_GROUP node
          "(#{node.children.map { |x| accept x }.join})"
        end
      end

      def initialize type, children = []
        super
      end

      def each(&block)
        Each.new(block).accept(self)
      end

      def to_s
        String.new.accept(self)
      end

      def to_sym
        children.tr(':', '').to_sym
      end
    end
  end
end
