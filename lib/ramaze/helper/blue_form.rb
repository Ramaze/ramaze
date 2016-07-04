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
    #       f.input_password 'Password', :password
    #     end
    #
    # The object comes handy when you want to do server-side form validation:
    # if the form can not be validated, just send back the object with keys
    # containing what the user has filled. The fields will be populated with
    # these values, so the user doesn't have to retype everything.
    #
    # If you don't want to use an object you can simply set the first parameter
    # to nil.
    #
    # ## HTML Output
    #
    # The form helper uses Gestalt, Ramaze's custom HTML builder that works
    # somewhat like Erector. The output is very minimalistic, elements such as
    # legends and fieldsets have to be added manually.
    #
    # If you need to add elements not covered by Form methods (e.g. `<div>`
    # tags), you can access the form Gestalt instance with the g() method and
    # generate your tags like this :
    #
    #     form_for(@result, :method => :post) do |f|
    #       f.g.div(:class => "awesome") do
    #         ...
    #       end
    #     end
    #
    # Each combination of a label and input element will be wrapped in
    # `<p>` tags.
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
    # @example Adding custom elements inside a form
    #  form_for(@result, :method => :post) do |f|
    #    f.fieldset do
    #      f.g.div(:class => "control-group") do
    #        f.input_text 'Text label', :textname, { :placeholder => 'Chunky bacon!',
    #                                                :class       => :bigsize }
    #      end
    #    end
    #  end
    #
    module BlueForm
      ##
      # The form method generates the basic structure of the form. It should be
      # called using a block and it's return value should be manually sent to
      # the browser (since it does not echo the value).
      #
      # @param [Object] form_object Object containing the values for each form
      #  field. If the object contains a hash of the form {:field=>"error"} it
      #  will be used to generate error messages in the BlueForm output.
      # @param [Hash] options Hash containing any additional form attributes
      #  such as the method, action, enctype and so on. To choose an
      #  arrangement of paragraph, table, or none, use
      #  :arrangement=>:paragraph, et.al.
      # @param [Block] block Block containing the elements of the form such as
      #  password fields, textareas and so on.
      #
      def form_for(form_object, options = {}, &block)
        form = Form.new(form_object, options)
        case
        when form_object.nil?
          # There is no form object, therefore, no errors
        when !form_object.respond_to?(:errors)
          # There is a form object, but it has no errors field
        when !form_object.errors.is_a?(Hash)
          # There is an errors object, but it's not a Hash so ignore it
        else
          # There is a form object, and it has a Hash errors field
          form_errors.merge!(form_object.errors)
        end
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
      # Class BlueFormModel contains a mass copy method like Sequel's that
      # can be used to create objects for 'form_for' that are not
      # database models, but have this one mass assignment
      # method in them.
      #
      # @example
      #   class Login < BlueFormModel
      #     :attr_accessor :username, :password, :confirm
      #   end
      #
      #   login = Login.new
      #   login.set_fields(session.request.params, [:username,:password,:confirm])
      #
      # @caveat
      #   Any use of 'BlueFormModel' must FOLLOW the 'helper :blue_form'
      #   statement in your code (which loads it).
      #
      class BlueFormModel
        attr_accessor :errors
        def initialize
          @errors = {}
        end
        def valid?
          @errors.empty?
        end
        def set_fields(hash, fields, opts={})
          fields.each do |f|
            if hash.has_key?(f)
              instance_variable_set("@#{f}", hash[f])
            elsif f.is_a?(Symbol) && hash.has_key?(sf = f.to_s)
              instance_variable_set("@#{sf}", hash[sf])
            else
              raise NoMethodError.new("undefined method `#{f.to_s}=' for #{self.inspect}") \
                if opts[:missing]!=:skip
            end
          end
          self
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
        attr_reader :form_object

        ##
        # Constructor method that generates an instance of the Form class.
        #
        # @param [Object] form_object Object containing the values for each form
        #  field.
        # @param [Hash] options A hash containing any additional form attributes.
        # @return [Object] An instance of the Form class.
        #
        def initialize(form_object, options)
          @form_object  = form_object
          @arrangement = options.delete(:arrangement)
          @arrangement = :paragraph if ([:table,:paragraph,:none].index(@arrangement)).nil?
          @form_args    = options.dup
          @g            = Gestalt.new
        end

        ##
        # Placeholder when no wrapper tag is used
        #
        def nul(*args)
          yield
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
            value = value.first if value.respond_to?(:first)
            @form_errors[key.to_s] = value
          end

          @g.form(@form_args) do
            if block_given?
              case @arrangement
              when :paragraph
                @table_wrapper = self.method('nul')
                @paragraph_wrapper = @g.method('p')
                @label_wrapper = self.method('nul')
                @input_wrapper = self.method('nul')
              when :table
                @table_wrapper = @g.method('table')
                @paragraph_wrapper = @g.method('tr')
                @label_wrapper = @g.method('th')
                @input_wrapper = @g.method('td')
              when :none
                @table_wrapper = self.method('nul')
                @paragraph_wrapper = self.method('nul')
                @label_wrapper = self.method('nul')
                @input_wrapper = self.method('nul')
              end
              @hidden_wrapper = self.method('nul')
              @table_wrapper.call { yield(self) }
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
        # @param [Proc] block The form elements to display inside the fieldset.
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
        # Generate a button tag (without a label). A button tag is a button that
        # once it's clicked will call a javascript function.
        #
        # @param [String] value The text to display in the button.
        # @param [Hash] args Any additional HTML attributes along with their
        #  values.
        # @example
        #  form_for(@data, :method => :post) do |f|
        #    f.input_button 'Press', :onclick=>"msg()"
        #  end
        #
        def input_button(value = nil, args = {})
          args[:value] = value if value
          tag(:button, nil, args)
        end # def input_button
        alias button input_button

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
          opts = {}
          opts[:label] = label if label
          opts[:checked] = checked if checked
          opts[:values] = args.delete(:values) if args.has_key?(:values)
          opts[:show_value] = args.delete(:show_value) if args.has_key?(:show_value)
          opts[:show_label] = args.delete(:show_label) if args.has_key?(:show_label)
          opts[:span_class] = args.delete(:span_class) if args.has_key?(:span_class)
          type = if args[:type]==:radio then :radio else :checkbox end
          tag(type, name, args, opts)
        end
        alias checkbox input_checkbox

        ##
        # Generate an input tag with a type of "color" along with a label tag.
        # This method also has the alias "color" so feel free to use that one
        # instead of input_color.
        #
        # @param [String] label The text to display inside the label tag.
        # @param [String Symbol] name The name of the color field.
        # @param [Hash] args Any additional HTML attributes along with their
        #  values.
        # @example
        #   form_for(@data, :method => :post) do |f|
        #     f.input_color 'Color', :car_color
        #   end
        #
        def input_color(label, name, args = {})
          tag(:color, name, args, :label=>label)
        end # def input_color
        alias color input_color

        ##
        # Generate a select tag with a size=1, along with the option tags
        #  and a label. A size=1 attribute creates a dropdown box; otherwise,
        #  it's the same as a select call.
        #
        # @param [String] label The text to display inside the label tag.
        # @param [String Symbol] name The name of the select tag.
        # @param [Hash] args Hash containing additional HTML attributes.
        # @example
        #  form_for(@data, :method => :post) do |f|
        #    f.dropdown 'Country', :country_list
        #  end
        #
        def input_dropdown(label, name, args = {})
          opts = {}
          opts[:label] = label if label
          opts[:selected] = args.delete(:selected) if args.has_key?(:selected)
          opts[:values] = args.delete(:values) if args.has_key?(:values)
          args[:size] = 1
          tag(:select, name, args, opts)
        end
        alias dropdown input_dropdown

        ##
        # Generate a email text box.
        #
        # @param [String] label The text to display inside the label tag.
        # @param [String Symbol] name The name of the email.
        # @param [Hash] args Any additional HTML attributes along with their
        #  values.
        # @example
        #  form_for(@data, :method => :post) do |f|
        #    f.email 'E-Mail', :email
        #  end
        #
        def input_email(label, name, args = {})
          tag(:email, name, args, :label=>label)
        end # def email
        alias email input_email

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
          tag(:file, name, args, :label=>label)
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
          args[:value] = value unless value.nil?
          tag(:hidden, name, args)
        end
        alias hidden input_hidden

        ##
        # Generate a image tag. An image tag is a submit button that
        # once it's clicked will send the form data to the server.
        #
        # @param [String] value The text to display in the button.
        # @param [Hash] args Any additional HTML attributes along with their
        #  values.
        # @example
        #  form_for(@data, :method => :post) do |f|
        #    f.input_image 'Save'
        #  end
        #
        def input_image(src, args = {})
          args[:src] = src unless src.nil?
          tag(:image, nil, args)
        end
        alias image input_image

        ##
        # Generate a number in a click box.
        #
        # @param [String] label The text to display inside the label tag.
        # @param [String Symbol] name The name of the number.
        # @param [Hash] args Any additional HTML attributes along with their
        #  values.
        # @example
        #  form_for(@data, :method => :post) do |f|
        #    f.number 'Age', :age, :min=>1, :max=>120
        #  end
        #
        def input_number(label, name, args = {})
          tag(:number, name, args, :label=>label)
        end # def number
        alias number input_number

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
          tag(:password, name, args, :label=>label)
        end
        alias password input_password

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
          args[:span_class] = "radio_wrap" unless args[:span_class]
          self.input_checkbox(label, name, checked, args)
        end
        alias radio input_radio

        ##
        # Generate a range with a slider bar.
        #
        # @param [String] label The text to display inside the label tag.
        # @param [String Symbol] name The name of the range.
        # @param [Hash] args Any additional HTML attributes along with their
        #  values.
        # @example
        #  form_for(@data, :method => :post) do |f|
        #    f.range 'Age', :age, :min=>1, :max=>120
        #  end
        #
        def input_range(label, name, args = {})
          tag(:range, name, args, :label=>label)
        end # def range
        alias range input_range

        ##
        # Generate a reset tag (without a label). A reset tag is a button that
        # once it's clicked will reset the form data in the form
        # back to it's initial state.
        #
        # @param [String] value The text to display in the button.
        # @param [Hash] args Any additional HTML attributes along with their
        #  values.
        # @example
        #  form_for(@data, :method => :post) do |f|
        #    f.input_reset 'Reset! Beware: you will lose the data in your form.'
        #  end
        #
        def input_reset(value = nil, args = {})
          args[:value] = value if value
          tag(:reset, nil, args)
        end # def input_reset
        alias reset input_reset

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
        def input_select(label, name, args = {})
          opts = {}
          opts[:label] = label if label
          opts[:selected] = args.delete(:selected) if args.has_key?(:selected)
          opts[:values] = args.delete(:values) if args.has_key?(:values)
          tag(:select, name, args, opts)
        end
        alias select input_select

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
          args[:value] = value unless value.nil?
          tag(:submit, nil, args)
        end
        alias submit input_submit

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
          tag(:text, name, args, :label=>label)
        end
        alias text input_text

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
        def input_textarea(label, name, args = {})
          opts = {}
          opts[:label] = label if label
          opts[:value] = args.delete(:value) if args.has_key?(:value)
          tag(:textarea, name, args, opts)
        end
        alias textarea input_textarea

        ##
        # Method used for converting the results of the BlueForm helper to a
        # string
        #
        # @return [String] The form output
        #
        def to_s
          @g.to_s
        end

        ##
        # Generate a URL.
        #
        # @param [String] label The text to display inside the label tag.
        # @param [String Symbol] name The name of the url.
        # @param [Hash] args Any additional HTML attributes along with their
        #  values.
        # @example
        #  form_for(@data, :method => :post) do |f|
        #    f.url 'Description', :description
        #  end
        #
        def input_url(label, name, args = {})
          tag(:url, name, args, :label=>label)
        end # def url
        alias url input_url

#-------------------------------------------------------------------------------#
#--- GENERATE THE HTML HERE ----------------------------------------------------#
#-------------------------------------------------------------------------------#

        def tag(type, name, args={}, opts={})
          paragraph_wrapper = if type==:hidden then @hidden_wrapper else @paragraph_wrapper end
          paragraph_wrapper.call do

            case type

            when :color, :email, :file, :number, :password, :range, :text, :url
              args[:type] = type
              args[:name] = name unless args.has_key?(:name) || name.nil?
              args[:id] = id_for(name) unless args.has_key?(:id) || name.nil?
              value = extract_values_from_object(name, args) unless args.has_key?(:value)
              args[:value] = value if value
              error = if name then @form_errors.delete(name.to_s) else nil end

              @label_wrapper.call { @g.label(opts[:label], :for => args[:id]) } if opts.has_key?(:label)
              @input_wrapper.call do
                if opts.has_key?(:span_class)
                  @g.span(accept(opts, [:span_class])) do
                    @g.input(args)
                  end
                else
                  @g.input(args)
                end
              end
              @label_wrapper.call { @g.span(:class=>"error") { "&nbsp;#{error}" } } if error

            when :button, :image, :reset, :submit
              args[:type] = type
              args[:name] = name unless args.has_key?(:name) || name.nil?
              @input_wrapper.call do
                @g.input(args)
              end

            when :textarea
              args[:name] = name unless args.has_key?(:name) || name.nil?
              args[:id] = id_for(name) unless args.has_key?(:id)
              value = extract_values_from_object(name, args) unless opts.has_key?(:value)
              opts[:value] = value if value
              error = if name then @form_errors.delete(name.to_s) else nil end

              @label_wrapper.call { @g.label(opts[:label], :for => args[:id]) } if opts.has_key?(:label)
              @input_wrapper.call do
                if opts.has_key?(:span_class)
                  @g.span(accept(opts, [:span_class])) do
                    @g.textarea(args) {opts[:value]}
                  end
                else
                  @g.textarea(args) {opts[:value]}
                end
              end
              @label_wrapper.call { @g.span(:class=>"error") { "&nbsp;#{error}" } } if error

            when :hidden
              args[:type] = type
              args[:name] = name unless args.has_key?(:name) || name.nil?
              args[:value] = extract_values_from_object(name, args) unless args.has_key?(:value)
              @g.input(args)

            when :checkbox, :radio
              args[:type] = type
              args[:name] = nil
              args[:id] = "#{id_for(name)}_0" unless args.has_key?(:id)
              error = if name then @form_errors.delete(name.to_s) else nil end

              # Get the options or their defaults
              span_class = if opts.has_key?(:span_class) then opts[:span_class] else "checkbox_wrap" end
              show_label = if opts.has_key?(:show_label) then opts[:show_label] else true end
              show_value = if opts.has_key?(:show_value) then opts[:show_value] else true end

              # Get all the values or checked from the form object
              has_values = opts.has_key?(:values)
              has_checked = opts[:checked]
              if has_values
                values = opts[:values]
                if has_checked
                  checked = opts[:checked]
                else
                  checked = extract_values_from_object(name, args)
                end
              else
                values = extract_values_from_object(name, args)
                values = [] if values.nil?
                if has_checked
                  checked = opts[:checked]
                else
                  checked = []
                end
              end
              values = [values] unless [Array,Hash].index(values.class)
              checked = [checked] unless [Array,Hash].index(checked.class)

              # Loop through all the values. Each checkbox will have an ID of
              # "form-NAME-INDEX". Each name will be NAME followed by [] to
              # indicate it's an array (since multiple values are possible).
              @label_wrapper.call { @g.label(opts[:label], :for => args[:id]) } if opts.has_key?(:label) && show_label
              @input_wrapper.call do
                values.each_with_index do |value,index|
                  args[:id] = "#{id_for(name)}_#{index}"

                  # The id is an array for checkboxes, and elemental for radio buttons
                  checkbox_name = if type == :checkbox then "#{name}[]" else name end
                  args[:name] = checkbox_name

                  # Get the value and text to display for each checkbox
                  if value.class == Array
                    # It's a hash in inverted ([value,key]) order
                    checkbox_text  = value[0]
                    checkbox_value = value[1]
                  else
                    # It's one value of an array
                    checkbox_text = checkbox_value = value
                  end
                  args[:value] = checkbox_value

                  # Let's see if the current item is checked
                  if checked.include?(checkbox_value)
                    args[:checked] = 'checked'
                  else
                    args.delete(:checked)
                  end

                  @g.span(:class=>span_class) do
                    @g.input(args)
                    " #{checkbox_text}" if show_value == true
                  end
                end
              end # @input_wrapper
              @label_wrapper.call { @g.span(:class=>"error") { "&nbsp;#{error}" } } if error

            when :select
              id = args[:id] ? args[:id] : id_for(name)
              multiple, size = args.values_at(:multiple, :size)
              error = if name then @form_errors.delete(name.to_s) else nil end

              # Get all the values or selected from the form object
              has_values = opts.has_key?(:values)
              has_selected = opts[:selected]
              if has_values
                values = opts[:values]
                if has_selected
                  selected = opts[:selected]
                else
                  selected = extract_values_from_object(name, args)
                end
              else
                values = extract_values_from_object(name, args)
                values = [] if values.nil?
                if has_selected
                  selected = opts[:selected]
                else
                  selected = []
                end
              end
              values = [values] unless [Array,Hash].index(values.class)
              selected = [selected] unless [Array,Hash].index(selected.class)

              args[:multiple] = 'multiple' if multiple
              args[:size]     = (size || values.count || 1).to_i
              args[:name]     = multiple ? "#{name}[]" : name
              args            = args.merge(:id => id)

              @label_wrapper.call { @g.label(opts[:label], :for => args[:id]) } if opts.has_key?(:label)
              @input_wrapper.call do
                @g.select(args) do
                  values.each do |value, option_name|
                    option_name ||= value
                    option_args = {:value => value}
                    option_args[:selected] = 'selected' if selected.include?(value)
                    @g.option(option_args){ option_name }
                  end # opts[:values].each
                end # @g.select
              end # @input_wrapper.call
              @label_wrapper.call { @g.span(:class=>"error") { "&nbsp;#{error}" } } if error

            else
              raise ArgumentError.new("Blueform doesn't support HTML5 type '#{type}'")
            end # case

          end # paragraph_wrapper.call
        end # tag

        private

        ##
        # If possible, extract the data from the form object.
        #
        # @param  [String] field_name The name of the field.
        # @return [Array] The args parameter. Extract looks
        #   for the :value=>:name parameter in order to
        #   extract data from the form object.
        #
        def extract_values_from_object(name, args)
          # If conditions are right, get the value from the input object.
          case
          when name.nil?
            # This control doesn't use value look up
          when args.has_key?(:value)
            # Don't override given value.
          when @form_object.nil?
            # No structure to look up a value.
          when @form_object.respond_to?(name)
            # There's a data element, so get the value.
            @form_object.send(name)
          end
        end # extract_values_from_object

        ##
        # Generate a value for an ID tag based on the field's name.
        #
        # @param  [String] field_name The name of the field.
        # @return [String] The ID for the specified field name.
        #
        def id_for(field_name)
          raise ArgumentError.new("No field name passed to id_for") if field_name.nil?
          if name = @form_args[:name]
            "#{name}_#{field_name}".downcase.gsub(/-/, '_')
          else
            "form_#{field_name}".downcase.gsub(/-/, '_')
          end
        end # id_for

        ##
        # Create a new hash with only the elements which have listed keys
        #
        def accept(hash, keys=[])
          hash.select { |k,v| keys.index(k) }
        end # accept

      end # Form
    end # BlueForm
  end # Helper
end # Ramaze
