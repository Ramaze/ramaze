require 'ramaze'
require 'ramaze/gestalt'

module Ramaze
  module Helper
    ##
    # The BlueForm helper tries to be an even better way to build forms
    # programmatically. By using a simple block you can quickly create all the
    # required elements for your form.
    #
    # See {Ramaze::Helper::BlueForm::Form} for all the available methods.
    #
    # ## Form Data
    #
    # As stated earlier it's possible to pass an object to the form_for()
    # method. What kind of object this is, a database result object or an
    # OpenStruct object doesn't matter as long as the attributes can be accessed
    # outside of the object (this can be done using attr_readers). This makes it
    # extremely easy to directly pass a result object from your favourite ORM.
    # Example:
    #
    #     @data = User[1]
    #
    #     form_for(@data, :method => :post) do |f|
    #       f.input_text 'Username', :username
    #     end
    #
    # If you don't want to use an object you can simply set the first parameter
    # to nil.
    #
    # ## HTML Output
    #
    # The form helper uses Gestalt, Ramaze's custom HTML builder that works
    # somewhat like Erector. The output is very minimalistic, elements such as
    # legends and fieldsets have to be added manually. Each combination of a
    # label and input element will be wrapped in `<p>` tags.
    #
    # When using the form helper as a block in your templates it's important to
    # remember that the result is returned and not displayed in the browser
    # directly. When using Etanni this would result in something like the
    # following:
    #
    #     #{form_for(@result, :method => :post) do |f|
    #       f.input_text 'Text label', :textname, 'Chunky bacon!'
    #     end}
    #
    # @example Creating a basic form
    #  form_for(@data, :method => :post) do |f|
    #    f.input_text 'Username', :username
    #  end
    #
    module BlueForm
      ##
      # The form method generates the basic structure of the form. It should be
      # called using a block and it's return value should be manually sent to
      # the browser (since it does not echo the value).
      #
      # @param [Object] form_values Object containing the values for each form
      #  field.
      # @param [Hash] options Hash containing any additional form attributes
      #  such as the method, action, enctype and so on.
      # @param [Block] block Block containing the elements of the form such as
      #  password fields, textareas and so on.
      #
      def form_for(form_values, options = {}, &block)
        form = Form.new(form_values, options)
        form.build(form_errors, &block)
        form
      end

      ##
      # Manually add a new error to the form_errors key in the flash hash. The
      # first parameter is the name of the form field and the second parameter
      # is the custom message.
      #
      # @param [String] name The name of the form field to which the error
      #  belongs.
      # @param [String] message The custom error message to show.
      #
      def form_error(name, message)
        if respond_to?(:flash)
          old = flash[:form_errors] || {}
          flash[:form_errors] = old.merge(name.to_s => message.to_s)
        else
          form_errors[name.to_s] = message.to_s
        end
      end

      ##
      # Returns the hash containing all existing errors and allows other methods
      # to set new errors by using this method as if it were a hash.
      #
      # @return [Array] All form errors.
      #
      def form_errors
        if respond_to?(:flash)
          flash[:form_errors] ||= {}
        else
          @form_errors ||= {}
        end
      end

      ##
      # Retrieve all the form errors for the specified model and add them to the
      # flash hash.
      #
      # @param [Object] obj An object of a model that contains form errors.
      #
      def form_errors_from_model(obj)
        if obj.respond_to?(:errors)
          obj.errors.each do |key, value|
            if value.respond_to?(:first)
              value = value.first
            end

            form_error(key.to_s, value % key)
          end
        end
      end

      ##
      # Main form class that contains all the required methods to generate form
      # specific tags, such as textareas and select boxes. Do note that this
      # class is not thread-safe so you should modify it only within one thread
      # of execution.
      #
      class Form
        attr_reader :g
        attr_reader :form_values

        ##
        # Constructor method that generates an instance of the Form class.
        #
        # @param [Object] form_values Object containing the values for each form
        #  field.
        # @param [Hash] options A hash containing any additional form attributes.
        # @return [Object] An instance of the Form class.
        #
        def initialize(form_values, options)
          @form_values  = form_values
          @form_args    = options.dup
          @g            = Gestalt.new
        end

        ##
        # Builds the form by generating the opening/closing tags and executing
        # the methods in the block.
        #
        # @param [Hash] form_errors Hash containing all form errors (if any).
        #
        def build(form_errors = {})
          # Convert all the keys in form_errors to strings and
          # retrieve the correct values in case
          @form_errors = {}

          form_errors.each do |key, value|
            if value.respond_to?(:first)
              value = value.first
            end

            @form_errors[key.to_s] = value
          end

          @g.form(@form_args) do
            if block_given?
              yield self
            end
          end
        end

        ##
        # Generate a `<legend>` tag.
        #
        # @param [String] text The text to display inside the legend tag.
        # @example
        #   form_for(@data, :method => :post) do |f|
        #     f.legend 'Ramaze rocks!'
        #   end
        #
        def legend(text)
          @g.legend(text)
        end

        ##
        # Generate a fieldset tag.
        #
        # @param [Block] &block The form elements to display inside the fieldset.
        # @example
        #  form_for(@data, :method => :post) do |f|
        #    f.fieldset do
        #      f.legend 'Hello, world!'
        #    end
        #  end
        #
        def fieldset(&block)
          @g.fieldset(&block)
        end

        ##
        # Generate an input tag with a type of "text" along with a label tag.
        # This method also has the alias "text" so feel free to use that one
        # instead of input_text.
        #
        # @param [String] label The text to display inside the label tag.
        # @param [String Symbol] name The name of the text field.
        # @param [Hash] args Any additional HTML attributes along with their
        #  values.
        # @example
        #   form_for(@data, :method => :post) do |f|
        #     f.input_text 'Username', :username
        #   end
        #
        def input_text(label, name, args = {})
          # The ID can come from 2 places, id_for and the args hash
          id   = args[:id] ? args[:id] : id_for(name)
          args = args.merge(:type => :text, :name => name, :id => id)

          if !args[:value] and @form_values.respond_to?(name)
            args[:value] = @form_values.send(name)
          end

          @g.p do
            label_for(id, label, name)
            @g.input(args)
          end
        end
        alias text input_text

        ##
        # Generate an input tag with a type of "password" along with a label.
        # Password fields are pretty much the same as text fields except that
        # the content of these fields is replaced with dots. This method has the
        # following alias: "password".
        #
        # @param [String] label The text to display inside the label tag.
        # @param [String Symbol] name The name of the password field.
        # @param [Hash] args Any additional HTML attributes along with their
        #  values.
        # @example
        #  form_for(@data, :method => :post) do |f|
        #    f.input_password 'My password', :password
        #  end
        #
        def input_password(label, name, args = {})
          # The ID can come from 2 places, id_for and the args hash
          id   = args[:id] ? args[:id] : id_for(name)
          args = args.merge(:type => :password, :name => name, :id => id)

          if !args[:value] and @form_values.respond_to?(name)
            args[:value] = @form_values.send(name)
          end

          @g.p do
            label_for(id, label, name)
            @g.input(args)
          end
        end
        alias password input_password

        ##
        # Generate a submit tag (without a label). A submit tag is a button that
        # once it's clicked will send the form data to the server.
        #
        # @param [String] value The text to display in the button.
        # @param [Hash] args Any additional HTML attributes along with their
        #  values.
        # @example
        #  form_for(@data, :method => :post) do |f|
        #    f.input_submit 'Save'
        #  end
        #
        def input_submit(value = nil, args = {})
          args         = args.merge(:type => :submit)
          args[:value] = value unless value.nil?

          @g.p do
            @g.input(args)
          end
        end
        alias submit input_submit

        ##
        # Generate an input tag with a type of "checkbox".
        #
        # If you want to have multiple checkboxes you can either use an array or
        # a hash.  In the case of an array the values will also be used as text
        # for each checkbox.  When using a hash the key will be displayed and
        # the value will be the value of the checkbox. Example:
        #
        #     @data = Class.new
        #       attr_reader :gender_arr
        #       attr_reader :gender_hash
        #
        #       def initialize
        #         @gender_arr  = ['male', 'female']
        #         @gender_hash = {"Male" => "male", "Female" => "female"}
        #       end
        #     end.new
        #
        #     form_for(@data, :method => :post) do |f|
        #       f.input_checkbox "Gender", :gender_arr
        #       f.input_checkbox "Gender", :gender_hash
        #     end
        #
        # @example
        #  form_for(@data, :method => :post) do |f|
        #    f.input_checkbox 'Remember me', :remember_user
        #  end
        #
        # @param [String] label The text to display inside the label tag.
        # @param [String Symbol] name The name of the checkbox.
        # @param [String/Array] checked String or array that indicates which
        #  value(s) should be checked.
        # @param [Hash] args Any additional HTML attributes along with their
        #  values.
        # @option args [String/Symbol] :id The value to use for the ID attribute.
        # @option args [Array] :values An array containing the possible values
        #  for the checkboxes.
        # @option args [String/Symbol] :span_class The class to use for the
        #  `<span>` element that's wrapped around the checkbox.
        # @option args [TrueClass/FalseClass] :show_value When set to false the
        #  value of each checkbox won't be displayed to the right of the
        #  checkbox. This option is set to true by default.
        # @option args [TrueClass/FalseClass] :show_label When set to true
        #  (default) the label for the checkbox will be displayed. Setting this
        #  to false will hide it.
        #
        def input_checkbox(label, name, checked = nil, args = {})
          id = args[:id] ? args[:id] : "#{id_for(name)}_0"

          # Determine whether or not to show the value of the checkbox
          if args.key?(:show_value)
            show_value = args.delete(:show_value)
          else
            show_value = true
          end

          # Determine whether or not to show the label
          if args.key?(:show_label)
            show_label = args.delete(:show_label)
          else
            show_label = true
          end

          # Get the checkbox value from either the args hash or from
          # the form object (as specified in the form_for() method).
          if !args[:values] and @form_values.respond_to?(name)
            args[:values] = @form_values.send(name)
          end

          # That class for each element wrapper (a span tag) can be customized
          # using :span_class => "a_class".
          if args[:span_class]
            span_class = args[:span_class]
            args.delete(:span_class)
          else
            span_class = "checkbox_wrap"
          end

          # Get the type from the args hash instead of pre-defining it. Doing so
          # means we can use this method for the input_radio method.
          args[:type] = :checkbox if !args[:type]

          # Convert the values to an array if it's something we can't use in a loop
          # (e.g. a string).
          if args[:values].class != Hash and args[:values].class != Array
            args[:values] = [args[:values]]
          end

          # Create a checkbox for each value
          if !args[:values].empty?
            @g.p do
              # Let's create the label and the hidden field
              if show_label === true
                label_for(id, label, name)
              end

              # Loop through all the values. Each checkbox will have an ID of
              # "form-NAME-INDEX". Each name will be NAME followed by [] to
              # indicate it's an array (since multiple values are possible).
              args[:values].each_with_index do |value, index|
                id = args[:id] ? args[:id] : "#{id_for(name)}_#{index}"

                if args[:type] == :checkbox
                  checkbox_name = "#{name}[]"
                else
                  checkbox_name = name
                end

                # Copy all additional attributes and their values except the
                # values array.
                opts = args.clone
                opts.delete(:values)

                # Get the value and text to display for each checkbox
                if value.class == Array
                  checkbox_text  = value[0]
                  checkbox_value = value[1]
                else
                  checkbox_text = checkbox_value = value
                end

                # Let's see if the current item is checked
                if checked.class == Array
                  if checked.include?(checkbox_value)
                    opts[:checked] = 'checked'
                  end
                else
                  if checkbox_value == checked
                    opts[:checked] = 'checked'
                  end
                end

                # And we're done, easy wasn't it?
                opts = opts.merge(
                  :name => checkbox_name, :id => id, :value => checkbox_value
                )

                # Generate the following HTML:
                #
                # <span class="#{span_class}">
                #   <input type="checkbox" name="#{checkbox_name}" id="#{id}"
                #   value="#{value}" /> #{value}
                # </span>
                #
                @g.span(:class => span_class) do
                  @g.input(opts)
                  " #{checkbox_text}" if show_value === true
                end
              end
            end
          end
        end
        alias checkbox input_checkbox

        ##
        # Generate an input tag with a type of "radio".
        #
        # If you want to generate multiple radio buttons you can use an array
        # just like you can with checkboxes. Example:
        #
        #     @data = Class.new
        #       attr_reader :gender_arr
        #       attr_reader :gender_hash
        #
        #       def initialize
        #         @gender_arr  = ['male', 'female']
        #         @gender_hash = {"Male" => "male", "Female" => "female"}
        #       end
        #     end.new
        #
        #     form_for(@data, :method => :post) do |f|
        #       f.input_radio "Gender", :gender_arr
        #       f.input_radio "Gender", :gender_hash
        #     end
        #
        # For more information see the input_checkbox() method.
        #
        # @param [String] label The text to display inside the label tag.
        # @param [String Symbol] name The name of the radio button.
        # @param [String] checked String that indicates if (and which) radio
        #  button should be checked.
        # @param [Hash] args Any additional HTML attributes along with their
        #  values.
        # @see input_checkbox()
        # @example
        #  form_for(@data, :method => :post) do |f|
        #    f.input_radio 'Gender', :gender
        #  end
        #
        def input_radio(label, name, checked = nil, args = {})
          # Force a type of "radio"
          args[:type] = :radio

          if !args[:span_class]
            args[:span_class] = "radio_wrap"
          end

          self.input_checkbox(label, name, checked, args)
        end
        alias radio input_radio

        ##
        # Generate a field for uploading files.
        #
        # @param [String] label The text to display inside the label tag.
        # @param [String Symbol] name The name of the radio tag.
        # @param [Hash] args Any additional HTML attributes along with their
        #  values.
        # @example
        #  form_for(@data, :method => :post) do |f|
        #    f.input_file 'Image', :image
        #  end
        #
        def input_file(label, name, args = {})
          id   = args[:id] ? args[:id] : id_for(name)
          args = args.merge(:type => :file, :name => name, :id => id)

          @g.p do
            label_for(id, label, name)
            @g.input(args)
          end
        end
        alias file input_file

        ##
        # Generate a hidden field. Hidden fields are essentially the same as
        # text fields except that they aren't displayed in the browser.
        #
        # @param [String Symbol] name The name of the hidden field tag.
        # @param [String] value The value of the hidden field
        # @param [Hash] args Any additional HTML attributes along with their
        #  values.
        # @example
        #  form_for(@data, :method => :post) do |f|
        #    f.input_hidden :user_id
        #  end
        #
        def input_hidden(name, value = nil, args = {})
          args = args.merge(:type => :hidden, :name => name)

          if !value and @form_values.respond_to?(name)
            args[:value] = @form_values.send(name)
          else
            args[:value] = value
          end

          @g.input(args)
        end
        alias hidden input_hidden

        ##
        # Generate a text area.
        #
        # @param [String] label The text to display inside the label tag.
        # @param [String Symbol] name The name of the textarea.
        # @param [Hash] args Any additional HTML attributes along with their
        #  values.
        # @example
        #  form_for(@data, :method => :post) do |f|
        #    f.textarea 'Description', :description
        #  end
        #
        def textarea(label, name, args = {})
          id = args[:id] ? args[:id] : id_for(name)

          # Get the value of the textarea
          if !args[:value] and @form_values.respond_to?(name)
            value = @form_values.send(name)
          else
            value = args[:value]
            args.delete(:value)
          end

          args = args.merge(:name => name, :id => id)

          @g.p do
            label_for(id, label, name)
            @g.textarea(args){ value }
          end
        end

        ##
        # Generate a select tag along with the option tags and a label.
        #
        # @param [String] label The text to display inside the label tag.
        # @param [String Symbol] name The name of the select tag.
        # @param [Hash] args Hash containing additional HTML attributes.
        # @example
        #  form_for(@data, :method => :post) do |f|
        #    f.select 'Country', :country_list
        #  end
        #
        def select(label, name, args = {})
          id              = args[:id] ? args[:id] : id_for(name)
          multiple, size  = args.values_at(:multiple, :size)

          # Get all the values
          if !args[:values] and @form_values.respond_to?(name)
            values = @form_values.send(name)
          else
            values = args[:values]
            args.delete(:values)
          end

          args[:multiple] = 'multiple' if multiple
          args[:size]     = (size || values.count || 1).to_i
          args[:name]     = multiple ? "#{name}[]" : name
          args            = args.merge(:id => id)

          # Retrieve the selected value
          has_selected, selected = args.key?(:selected), args[:selected]
                        selected = [selected] if !selected.is_a?(Array)
          args.delete(:selected)

          @g.p do
            label_for(id, label, name)
            @g.select args do
              values.each do |value, o_name|
                o_name ||= value
                o_args = {:value => value}

                if has_selected and selected.include?(value)
                  o_args[:selected] = 'selected'
                end

                @g.option(o_args){ o_name }
              end
            end
          end
        end

        ##
        # Method used for converting the results of the BlueForm helper to a
        # string
        #
        # @return [String] The form output
        #
        def to_s
          @g.to_s
        end

        private

        ##
        # Generate a label based on the id and value.
        #
        # @param [String] id The ID to which the label belongs.
        # @param [String] value The text to display inside the label tag.
        # @param [String] name The name of the field to which the label belongs.
        #
        def label_for(id, value, name)
          if error = @form_errors.delete(name.to_s)
            @g.label("#{value} ", :for => id){ @g.span(:class => :error){ error } }
          else
            @g.label(value, :for => id)
          end
        end

        ##
        # Generate a value for an ID tag based on the field's name.
        #
        # @param  [String] field_name The name of the field.
        # @return [String] The ID for the specified field name.
        #
        def id_for(field_name)
          if name = @form_args[:name]
            "#{name}_#{field_name}".downcase.gsub(/-/, '_')
          else
            "form_#{field_name}".downcase.gsub(/-/, '_')
          end
        end
      end # Form
    end # BlueForm
  end # Helper
end # Ramaze
