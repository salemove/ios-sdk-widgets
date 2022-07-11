module Fastlane
  module Actions
    module SharedValues
      REPLACE_SWIFT_CONSTANT_VALUE_CUSTOM_VALUE = :REPLACE_SWIFT_CONSTANT_VALUE_CUSTOM_VALUE
    end

    class ReplaceSwiftConstantValueAction < Action
      def self.run(params)
        file_path = params[:file_path]
        constant_name = params[:name]
        constant_value = params[:value]

        temp_file = Tempfile.new('temp')

        begin
          File.open(file_path, 'r') do |file|
            file.each_line do |line|
              if line.include? constant_name
                arr = line.split(" = ")
                arr[1] = constant_value
                temp_file.puts arr.join(" = ")
              else
                temp_file.puts line
              end
            end
          end
          temp_file.close
          FileUtils.mv(temp_file.path, file_path)
        ensure
          temp_file.close
          temp_file.unlink
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Changes the value of a Swift variable to the specified value"
      end

      def self.details
        "This action can be used to change a Swift variable from one value to another. "\
        "The action gets the variable with the specified name (through the variable `name` "\
        "and changes the value to the specified value (through the variable `value`). This "\
        "action will not add double quotes by default, so it can be used with numbers, booleans, "\
        "etc. This action will only be able to exchange a variable name if the variable has been "\
        "declared in the following format: "\
        "`[optional access modifier] [var or let] [variable name] = [variable value]` "\
        "The action splits the variable declaration using ` = ` as a split expression (with a space) "\
        "before and after the equal sign, so if your variable doesn't have these spaces, the "\
        "replacement will not occur. This is to avoid adding unnecessary handling of whitespace."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :file_path,
                                       env_name: "FL_REPLACE_SWIFT_CONSTANT_VALUE_FILE_PATH",
                                       description: "File path for ReplaceSwiftConstantValueAction", # a short description of this parameter
                                       verify_block: proc do |value|
                                          UI.user_error!("No file path for ReplaceSwiftConstantValueAction given, pass using `file_path: 'file_path'`") unless (value and not value.empty?)
                                          # UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :name,
                                       env_name: "FL_REPLACE_SWIFT_CONSTANT_VALUE_NAME",
                                       description: "Constant name for ReplaceSwiftConstantValueAction", # a short description of this parameter
                                       verify_block: proc do |value|
                                          UI.user_error!("No constant name for ReplaceSwiftConstantValueAction given, pass using `file_path: 'file_path'`") unless (value and not value.empty?)
                                          # UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :value,
                                       env_name: "FL_REPLACE_SWIFT_CONSTANT_VALUE_VALUE",
                                       description: "New constant value for ReplaceSwiftConstantValueAction", # a short description of this parameter
                                       verify_block: proc do |value|
                                          UI.user_error!("No constant value for ReplaceSwiftConstantValueAction given, pass using `file_path: 'file_path'`") unless (value and not value.empty?)
                                          # UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                       end),
        ]
      end

      def self.authors
        ["Glia Technologies"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
