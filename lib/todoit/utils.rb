module Todoit
  # utility for import function explicitly
  module FunctionExporter
    def export context, *args
      parent_mod = self.dup

      method_of = {};
      case args.first
      when Hash
        args.first.each do |key, val|
          method_of[key.to_s] = val
        end
      else
        args.each do |hash,i| 
          method_of[i.to_s] = true
        end
      end

      no_need_methods = []
      parent_mod.instance_methods.each do |meth|
        unless method_of[meth.to_s]
          no_need_methods.push meth
        end
      end

      parent_mod.module_eval do
        method_of.each do |key, val|
          next if val.kind_of? TrueClass
          alias_method val, key
          undef_method key
          if val.to_s !~ /^_/
            public val
          end
        end
        no_need_methods.each do |meth|
          undef_method meth
        end
      end

      context.module_eval do
        include parent_mod
      end

    end
  end

  module FunctionImporter
    private 

    def import_function mod, *funcs
      mod.export self, *funcs
    end

    def import_module_function mod, *funcs
      eigen_class = class << self; self end
      mod.export( eigen_class, *funcs)
      eigen_class.module_eval do
        case funcs.first
        when Hash
          funcs.first.each do |key, val|
            next if val.to_s =~ /^_/
            public func
          end
        else
          funcs.each do |func|
            next if func.to_s =~ /^_/
            public func
          end
        end
      end
    end
  end
end

