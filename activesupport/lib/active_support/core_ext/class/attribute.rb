require 'active_support/core_ext/object/singleton_class'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/module/remove_method'

class Class
  # Declare a class-level attribute whose value is inheritable and
  # overwritable by subclasses:
  #
  #   class Base
  #     class_attribute :setting
  #   end
  #
  #   class Subclass < Base
  #   end
  #
  #   Base.setting = true
  #   Subclass.setting            # => true
  #   Subclass.setting = false
  #   Subclass.setting            # => false
  #   Base.setting                # => true
  #
  # This matches normal Ruby method inheritance: think of writing an attribute
  # on a subclass as overriding the reader method.
  #
  # For convenience, a query method is defined as well:
  #
  #   Subclass.setting?           # => false
  #
  # Instances may overwrite the class value in the same way:
  #
  #   Base.setting = true
  #   object = Base.new
  #   object.setting          # => true
  #   object.setting = false
  #   object.setting          # => false
  #   Base.setting            # => true
  #
  # To opt out of the instance writer method, pass :instance_writer => false.
  #
  #   object.setting = false  # => NoMethodError
  def class_attribute(*attrs)
    instance_writer = !attrs.last.is_a?(Hash) || attrs.pop[:instance_writer]

    s = singleton_class
    attrs.each do |attr|
      s.send(:define_method, attr) { }
      s.send(:define_method, :"#{attr}?") { !!send(attr) }
      s.send(:define_method, :"#{attr}=") do |value|
        singleton_class.remove_possible_method(attr)
        singleton_class.send(:define_method, attr) { value }
      end

      define_method(attr) { self.singleton_class.send(attr) }
      define_method(:"#{attr}?") { !!send(attr) }
      define_method(:"#{attr}=") do |value|
        singleton_class.remove_possible_method(attr)
        singleton_class.send(:define_method, attr) { value }
      end if instance_writer
    end
  end
end
