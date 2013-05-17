# encoding: utf-8

module Rubocop
  module Cop
    class NewLambdaLiteral < Cop
      ERROR_MESSAGE = 'The new lambda literal syntax is preferred in Ruby 1.9.'

      def self.portable?
        true
      end

      def inspect(file, source, sexp)
        on_node(:send, sexp) do |s|
          if s.to_a == [nil, :lambda] && s.src.selector.to_source != '->'
            add_offence(:convention, s.src.line, ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
