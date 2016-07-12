require File.expand_path('../../../../spec/helper', __FILE__)
require 'ramaze/helper/blue_form'

describe BF = Ramaze::Helper::BlueForm do # original tests
  extend BF

  # Generate some dummy data
  @data = Class.new do
    attr_accessor :person
    attr_reader :username
    attr_reader :password
    attr_reader :assigned
    attr_reader :assigned_hash
    attr_reader :message
    attr_accessor :server
    attr_reader :servers_hash
    attr_reader :servers_array
    attr_accessor :errors

    def initialize
      @username     = 'mrfoo'
      @password     = 'super-secret-password'
      @assigned     = ['bacon', 'steak']
      @assigned_hash= {'Bacon' => 'bacon', 'Steak' => 'steak'}
      @message      = 'Hello, textarea!'
      @servers_hash = {
        :webrick => 'WEBrick',
        :mongrel => 'Mongrel',
        :thin    => 'Thin',
      }
      @servers_array  = ['WEBrick', 'Mongrel', 'Thin']
    end
  end.new

  class BlueFormModel
    attr_accessor :errors
    def set_fields(hash, fields, opts={})
      @errors = {}
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

  class UserX < BlueFormModel
    attr_accessor :username, :password, :gender, :country, :errors
    def initialize
      @errors={}
    end
  end

  # very strange comparision, sort all characters and compare, so we don't have
  # order issues.
  def assert(expected, output)
    left  = expected.to_s.gsub(/\s+/, ' ').gsub(/>\s+</, '><').strip
    right = output.to_s.gsub(/\s+/, ' ').gsub(/>\s+</, '><').strip
    lsort = left.scan(/./).sort
    rsort = right.scan(/./).sort
    lsort.should == rsort
  end

  # ------------------------------------------------
  # Basic forms
  it 'Make a basic form' do
    out = form_for(@data, :method => :post)
    assert(<<-FORM, out)
<form method="post"></form>
    FORM
  end

  it 'Make a form with the method and action attributes specified' do
    out = form_for(@data, :method => :post, :action => '/')
    assert(<<-FORM, out)
<form method="post" action="/"></form>
    FORM
  end

  it 'Make a form with a method, action and a name attribute' do
    out = form_for(@data, :method => :post, :action => '/', :name => :spec)
    assert(<<-FORM, out)
    <form method="post" action="/" name="spec">
    </form>
    FORM
  end

  it 'Make a form with a class and an ID' do
    out = form_for(@data, :class => :foo, :id => :bar)
    assert(<<-FORM, out)
    <form class="foo" id="bar">
    </form>
    FORM
  end

  it 'Make a form with a fieldset and a legend' do
    out = form_for(@data, :method => :get) do |f|
      f.fieldset do
        f.legend('The Form')
      end
    end

    assert(<<-FORM, out)
<form method="get">
  <fieldset>
    <legend>The Form</legend>
  </fieldset>
</form>
    FORM
  end

  #
  # ------------------------------------------------
  # tag forms
  it '1. Make a :text form with name and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:text, :username, {}, {:label=>"Username"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_username">Username</label>
    <input type="text" name="username" id="form_username" value="mrfoo" />
  </p>
</form>
    FORM
  end

  it '2. Make a :text form with name, args, and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:text, :username, {:value=>"mrboo"}, {:label=>"Username"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_username">Username</label>
    <input type="text" name="username" id="form_username" value="mrboo" />
  </p>
</form>
    FORM
  end

  it '3. Make a :text form with name, args, and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:text, :username, {:size=>10, :id=>"my_id"}, {:label=>"Username"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="my_id">Username</label>
    <input size="10" type="text" name="username" id="my_id" value="mrfoo" />
  </p>
</form>
    FORM
  end

  it '4. Make a :password form with name and opts' do
    out = form_for(nil, :method => :get) do |f|
      f.tag(:password, :password, {}, {:label=>"Password"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_password">Password</label>
    <input type="password" name="password" id="form_password" />
  </p>
</form>
    FORM
  end

  it '5. Make a :password form with name, args, and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:password, :password, {:value=>"super-secret-password", :class=>"password_class"}, {:label=>"Password"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_password">Password</label>
    <input class="password_class" type="password" name="password" id="form_password" value="super-secret-password" />
  </p>
</form>
    FORM
  end

  it '6. Make a :submit form' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:submit, nil, {}, {})
    end

    assert(<<-FORM, out)
<form method="get">
    <p>
      <input type="submit" />
    </p>
</form>
    FORM
  end

  it '7. Make a :submit form with args' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:submit, nil, {:value=>"Send"}, {})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <input type="submit" value="Send" />
  </p>
</form>
    FORM
  end

  it '8. Make a :checkbox form with name and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:checkbox, :assigned, {}, {:label=>"Assigned"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_assigned_0">Assigned</label>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned[]" id="form_assigned_0" value="bacon" /> bacon</span>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned[]" id="form_assigned_1" value="steak" /> steak</span>
  </p>
</form>
    FORM
  end

  it '9. Make a :checkbox form with name and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:checkbox, :assigned, {}, {:label=>"Assigned", :checked=>"bacon"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_assigned_0">Assigned</label>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned[]" id="form_assigned_0" checked="checked" value="bacon" /> bacon</span>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned[]" id="form_assigned_1" value="steak" /> steak</span>
  </p>
</form>
    FORM
  end

  it '10. Make a :checkbox form with name and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:checkbox, :assigned, {}, {:label=>"Assigned", :checked=>"boo", :values=>["boo"]})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_assigned_0">Assigned</label>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned[]" id="form_assigned_0" checked="checked" value="boo" /> boo</span>
  </p>
</form>
    FORM
  end

  it '11. Make a :checkbox form with name and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:checkbox, :assigned, {}, {:label=>"Assigned", :checked=>["boo"], :values=>["boo", "foo"]})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_assigned_0">Assigned</label>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned[]" id="form_assigned_0" checked="checked" value="boo" /> boo</span>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned[]" id="form_assigned_1" value="foo" /> foo</span>
  </p>
</form>
    FORM
  end

  it '12. Make a :checkbox form with name and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:checkbox, :assigned, {}, {:label=>"Assigned", :checked=>["boo"], :values=>{"Boo"=>"boo"}})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_assigned_0">Assigned</label>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned[]" id="form_assigned_0" checked="checked" value="boo" /> Boo</span>
  </p>
</form>
    FORM
  end

  it '13. Make a :checkbox form with name and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:checkbox, :assigned, {}, {:label=>"Assigned", :show_value=>false})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_assigned_0">Assigned</label>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned[]" id="form_assigned_0" value="bacon" /></span>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned[]" id="form_assigned_1" value="steak" /></span>
  </p>
</form>
    FORM
  end

  it '14. Make a :checkbox form with name and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:checkbox, :assigned, {}, {:label=>"Assigned", :show_label=>false})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned[]" id="form_assigned_0" value="bacon" /> bacon</span>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned[]" id="form_assigned_1" value="steak" /> steak</span>
  </p>
</form>
    FORM
  end

  it '15. Make a :checkbox form with name and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:checkbox, :assigned_hash, {}, {:label=>"Assigned"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_assigned_hash_0">Assigned</label>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned_hash[]" id="form_assigned_hash_0" value="bacon" /> Bacon</span>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned_hash[]" id="form_assigned_hash_1" value="steak" /> Steak</span>
  </p>
</form>
    FORM
  end

  it '16. Make a :checkbox form with name and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:checkbox, :assigned_hash, {}, {:label=>"Assigned", :checked=>"bacon"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_assigned_hash_0">Assigned</label>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned_hash[]" id="form_assigned_hash_0" checked="checked" value="bacon" /> Bacon</span>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned_hash[]" id="form_assigned_hash_1" value="steak" /> Steak</span>
  </p>
</form>
    FORM
  end

  it '17. Make a :radio form with name, args, and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:radio, :assigned, {:type=>:radio}, {:label=>"Assigned", :span_class=>"radio_wrap"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_assigned_0">Assigned</label>
    <span class="radio_wrap"><input type="radio" name="assigned" id="form_assigned_0" value="bacon" /> bacon</span>
    <span class="radio_wrap"><input type="radio" name="assigned" id="form_assigned_1" value="steak" /> steak</span>
  </p>
</form>
    FORM
  end

  it '18. Make a :radio form with name, args, and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:radio, :assigned, {:type=>:radio}, {:label=>"Assigned", :checked=>"bacon", :span_class=>"radio_wrap"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_assigned_0">Assigned</label>
    <span class="radio_wrap"><input type="radio" name="assigned" id="form_assigned_0" checked="checked" value="bacon" /> bacon</span>
    <span class="radio_wrap"><input type="radio" name="assigned" id="form_assigned_1" value="steak" /> steak</span>
  </p>
</form>
    FORM
  end

  it '19. Make a :radio form with name, args, and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:radio, :assigned, {:type=>:radio}, {:label=>"Assigned", :checked=>"boo", :values=>["boo"], :span_class=>"radio_wrap"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_assigned_0">Assigned</label>
    <span class="radio_wrap"><input type="radio" name="assigned" id="form_assigned_0" checked="checked" value="boo" /> boo</span>
  </p>
</form>
    FORM
  end

  it '20. Make a :radio form with name, args, and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:radio, :assigned, {:type=>:radio}, {:label=>"Assigned", :show_value=>false, :span_class=>"radio_wrap"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_assigned_0">Assigned</label>
    <span class="radio_wrap"><input type="radio" name="assigned" id="form_assigned_0" value="bacon" /></span>
    <span class="radio_wrap"><input type="radio" name="assigned" id="form_assigned_1" value="steak" /></span>
  </p>
</form>
    FORM
  end

  it '21. Make a :radio form with name, args, and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:radio, :assigned, {:type=>:radio}, {:label=>"Assigned", :show_label=>false, :span_class=>"radio_wrap"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <span class="radio_wrap"><input type="radio" name="assigned" id="form_assigned_0" value="bacon" /> bacon</span>
    <span class="radio_wrap"><input type="radio" name="assigned" id="form_assigned_1" value="steak" /> steak</span>
  </p>
</form>
    FORM
  end

  it '22. Make a :radio form with name, args, and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:radio, :assigned_hash, {:type=>:radio}, {:label=>"Assigned", :span_class=>"radio_wrap"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_assigned_hash_0">Assigned</label>
    <span class="radio_wrap"><input type="radio" name="assigned_hash" id="form_assigned_hash_0" value="bacon" /> Bacon</span>
    <span class="radio_wrap"><input type="radio" name="assigned_hash" id="form_assigned_hash_1" value="steak" /> Steak</span>
  </p>
</form>
    FORM
  end

  it '23. Make a :radio form with name, args, and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:radio, :assigned_hash, {:type=>:radio}, {:label=>"Assigned", :checked=>"bacon", :span_class=>"radio_wrap"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_assigned_hash_0">Assigned</label>
    <span class="radio_wrap"><input type="radio" name="assigned_hash" id="form_assigned_hash_0" checked="checked" value="bacon" /> Bacon</span>
    <span class="radio_wrap"><input type="radio" name="assigned_hash" id="form_assigned_hash_1" value="steak" /> Steak</span>
  </p>
</form>
    FORM
  end

  it '24. Make a :file form with name and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:file, :file, {}, {:label=>"File"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_file">File</label>
    <input type="file" name="file" id="form_file" />
  </p>
</form>
    FORM
  end

  it '24. Make a :file form with name, args, and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:file, :file, {:id=>"awesome_file"}, {:label=>"File"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="awesome_file">File</label>
    <input type="file" name="file" id="awesome_file" />
  </p>
</form>
    FORM
  end

  it '25. Make a :hidden form with name' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:hidden, :username, {}, {})
    end

    assert(<<-FORM, out)
<form method="get">
  <input type="hidden" name="username" value="mrfoo" />
</form>
    FORM
  end

  it '26. Make a :hidden form with name and args' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:hidden, :username, {:value=>"Bob Ross"}, {})
    end

    assert(<<-FORM, out)
<form method="get">
  <input type="hidden" name="username" value="Bob Ross" />
</form>
    FORM
  end

  it '27. Make a :hidden form with name and args' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:hidden, :username, {:id=>"test", :value=>"Bob Ross"}, {})
    end

    assert(<<-FORM, out)
<form method="get">
  <input type="hidden" name="username" value="Bob Ross" id="test" />
</form>
    FORM
  end

  it '28. Make a :textarea form with name and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:textarea, :message, {}, {:label=>"Message"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_message">Message</label>
    <textarea name="message" id="form_message">Hello, textarea!</textarea>
  </p>
</form>
    FORM
  end

  it '29. Make a :textarea form with name and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:textarea, :message, {}, {:label=>"Message", :value=>"stuff"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_message">Message</label>
    <textarea name="message" id="form_message">stuff</textarea>
  </p>
</form>
    FORM
  end

  it '30. Make a :select form with name and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:select, :servers_hash, {}, {:label=>"Server"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_servers_hash">Server</label>
    <select id="form_servers_hash" size="3" name="servers_hash">
      <option value="webrick">WEBrick</option>
      <option value="mongrel">Mongrel</option>
      <option value="thin">Thin</option>
    </select>
  </p>
</form>
    FORM
  end

  it '31. Make a :select form with name and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:select, :servers_hash, {}, {:label=>"Server", :selected=>:mongrel})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_servers_hash">Server</label>
    <select id="form_servers_hash" size="3" name="servers_hash">
      <option value="webrick">WEBrick</option>
      <option value="mongrel" selected="selected">Mongrel</option>
      <option value="thin">Thin</option>
    </select>
  </p>
</form>
    FORM
  end

  it '32. Make a :select form with name and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:select, :servers_array, {}, {:label=>"Server"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_servers_array">Server</label>
    <select id="form_servers_array" size="3" name="servers_array">
      <option value="WEBrick">WEBrick</option>
      <option value="Mongrel">Mongrel</option>
      <option value="Thin">Thin</option>
    </select>
  </p>
</form>
    FORM
  end

  it '33. Make a :select form with name and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:select, :servers_array, {}, {:label=>"Server", :selected=>"Mongrel"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_servers_array">Server</label>
    <select id="form_servers_array" size="3" name="servers_array">
      <option value="WEBrick">WEBrick</option>
      <option value="Mongrel" selected="selected">Mongrel</option>
      <option value="Thin">Thin</option>
    </select>
  </p>
</form>
    FORM
  end

  it '34. Make a :select form with name and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:select, :people_hash, {}, {:label=>"People", :values=>{:chuck=>"Chuck", :bob=>"Bob"}})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_people_hash">People</label>
    <select id="form_people_hash" size="2" name="people_hash">
      <option value="chuck">Chuck</option>
      <option value="bob">Bob</option>
    </select>
  </p>
</form>
    FORM
  end

  it '35. Make a :select form with name and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:select, :people_hash, {}, {:label=>"People", :selected=>:chuck, :values=>{:chuck=>"Chuck", :bob=>"Bob"}})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_people_hash">People</label>
    <select id="form_people_hash" size="2" name="people_hash">
      <option value="chuck" selected="selected">Chuck</option>
      <option value="bob">Bob</option>
    </select>
  </p>
</form>
    FORM
  end

  it '36. Make a :select form with name and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:select, :people_array, {}, {:label=>"People", :values=>["Chuck", "Bob"]})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_people_array">People</label>
    <select id="form_people_array" size="2" name="people_array">
      <option value="Chuck">Chuck</option>
      <option value="Bob">Bob</option>
    </select>
  </p>
</form>
    FORM
  end

  it '37. Make a :select form with name and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:select, :people_array, {}, {:label=>"People", :selected=>"Chuck", :values=>["Chuck", "Bob"]})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_people_array">People</label>
    <select id="form_people_array" size="2" name="people_array">
      <option value="Chuck" selected="selected">Chuck</option>
      <option value="Bob">Bob</option>
    </select>
  </p>
</form>
    FORM
  end

  it '38. Make a :select form with name, args, and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:select, :servers_hash, {:multiple=>:multiple}, {:label=>"Server"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_servers_hash">Server</label>
    <select id="form_servers_hash" size="3" name="servers_hash[]" multiple="multiple">
      <option value="webrick">WEBrick</option>
      <option value="mongrel">Mongrel</option>
      <option value="thin">Thin</option>
    </select>
  </p>
</form>
    FORM
  end

  it '39. Make a :select form with name, args, and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:select, :servers_hash, {:multiple=>:multiple}, {:label=>"Server", :selected=>:webrick})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_servers_hash">Server</label>
    <select id="form_servers_hash" size="3" name="servers_hash[]" multiple="multiple">
      <option value="webrick" selected="selected">WEBrick</option>
      <option value="mongrel">Mongrel</option>
      <option value="thin">Thin</option>
    </select>
  </p>
</form>
    FORM
  end

  it '40. Make a :select form with name, args, and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:select, :servers_hash, {:multiple=>:multiple}, {:label=>"Server", :selected=>[:webrick, :mongrel]})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_servers_hash">Server</label>
    <select id="form_servers_hash" size="3" name="servers_hash[]" multiple="multiple">
      <option value="webrick" selected="selected">WEBrick</option>
      <option value="mongrel" selected="selected">Mongrel</option>
      <option value="thin">Thin</option>
    </select>
  </p>
</form>
    FORM
  end

  it '41. Make a :button form with args' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:button, nil, {:onclick=>"fcn()", :value=>"Accept"}, {})
    end

    assert(<<-FORM, out)
<form method="get">
  <p><input value="Accept" type="button" onclick="fcn()" /></p>
</form>
    FORM
  end

  it '42. Make a :color form with name and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:color, :my_color, {}, {:label=>"Choose a color"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_my_color">Choose a color</label>
    <input id="form_my_color" name="my_color" type="color" />
  </p>
</form>
    FORM
  end

  it '43. Make a :email form with name and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:email, :email, {}, {:label=>"Email"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_email">Email</label>
    <input id="form_email" name="email" type="email" />
  </p>
</form>
    FORM
  end

  it '44. Make a :image form with args' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:image, nil, {:alt=>"Submit", :src=>"http://www.w3schools.com/tags/img_submit.gif"}, {})
    end

    assert(<<-FORM, out)
<form method="get">
    <p>
      <input alt="Submit" src="http://www.w3schools.com/tags/img_submit.gif" type="image" />
    </p>
</form>
    FORM
  end

  it '45. Make a :number form with name, args, and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:number, :age, {:min=>1, :max=>120}, {:label=>"Age"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_age">Age</label>
    <input min="1" max="120" id="form_age" name="age" type="number" />
  </p>
</form>
    FORM
  end

  it '46. Make a :range form with name, args, and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:range, :cost, {:min=>0, :max=>100}, {:label=>"Cost"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_cost">Cost</label>
    <input min="0" max="100" id="form_cost" name="cost" type="range" />
  </p>
</form>
    FORM
  end

  it '47. Make a :reset form' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:reset, nil, {}, {})
    end

    assert(<<-FORM, out)
<form method="get">
    <p>
      <input type="reset" />
    </p>
</form>
    FORM
  end

  it '48. Make a :reset form with args' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:reset, nil, {:value=>"Reset"}, {})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <input type="reset" value="Reset" />
  </p>
</form>
    FORM
  end

  it '49. Make a :url form with name and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:url, :url, {}, {:label=>"URL"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_url">URL</label>
    <input id="form_url" name="url" type="url" />
  </p>
</form>
    FORM
  end

  it '50. Make a :select form with name and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:select, :person, {}, {:label=>"Person", :selected=>"chuck", :values=>{"chuck"=>"Chuck", "bob"=>"Bob"}})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_person">Person</label>
    <select size="2" name="person" id="form_person">
      <option value="chuck" selected="selected">Chuck</option>
      <option value="bob">Bob</option>
    </select>
  </p>
</form>
    FORM
  end

  it '51. Make a :select form with name and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:select, :person, {}, {:label=>"Person", :selected=>"chuck",:values=>{"chuck"=>"Chuck", "bob"=>"Bob"}})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_person">Person</label>
    <select size="2" name="person" id="form_person">
      <option value="chuck" selected="selected">Chuck</option>
      <option value="bob">Bob</option>
    </select>
  </p>
</form>
    FORM
  end

  it '60. Make a :text/:password form with name and opts' do
    params = {:username=>"gladys", :password=>"abc", :gender=>"F", :country=>"SV"}
    user = UserX.new
    user.set_fields(params, [:username, :password, :gender, :country], :missing=>:skip)
    user.errors[:username] = "User not in system"
    user.errors[:password] = "The username/password combination is not on our system"
    out = form_for(user, :method => :post, :action=>"login2") do |f|
      f.tag(:text, :username, {}, {:label=>"Username: "})
      f.tag(:password, :password, {}, {:label=>"Password: "})
    end

    assert(<<-FORM, out)
<form method="post" action="login2">
  <p>
    <label for="form_username">Username: </label>
    <input id="form_username" name="username" value="gladys" type="text" />
    <span class="error">&nbsp;User not in system</span>
  </p>
  <p>
    <label for="form_password">Password: </label>
    <input id="form_password" name="password" value="abc" type="password" />
    <span class="error">&nbsp;The username/password combination is not on our system</span>
  </p>
</form>
    FORM
  end

  it '98. Make a :text form with name and opts' do
    form_error :username, 'May not be empty'
    out = form_for(@data, :method => :get) do |f|
      f.tag(:text, :username, {}, {:label=>"Username"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_username">Username</label>
    <input id="form_username" name="username" value="mrfoo" type="text" />
    <span class="error">&nbsp;May not be empty</span>
  </p>
</form>
    FORM
  end

  it '99. Make a :text form with name and opts' do
    out = form_for(@data, :method => :get) do |f|
      f.tag(:text, :username, {}, {:label=>"Username"})
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_username">Username</label>
    <input id="form_username" name="username" value="mrfoo" type="text" />
    <span class="error">&nbsp;May not be empty</span>
  </p>
</form>
    FORM
  end


  # ------------------------------------------------
  # Clear out previous simulated errors
  @form_errors = {}

  # ------------------------------------------------
  # Text fields

  it '101. Make a form with input_text(label, value)' do
    out = form_for(@data, :method => :get) do |f|
      f.input_text 'Username', :username
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_username">Username</label>
    <input type="text" name="username" id="form_username" value="mrfoo" />
  </p>
</form>
    FORM
  end

  it '102. Make a form with input_text(username, label, value)' do
    out = form_for(@data, :method => :get) do |f|
      f.input_text 'Username', :username, :value => 'mrboo'
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_username">Username</label>
    <input type="text" name="username" id="form_username" value="mrboo" />
  </p>
</form>
    FORM
  end

  it '103. Make a form with input_text(label, name, size, id)' do
    out = form_for(@data, :method => :get) do |f|
      f.input_text 'Username', :username, :size => 10, :id => 'my_id'
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="my_id">Username</label>
    <input size="10" type="text" name="username" id="my_id" value="mrfoo" />
  </p>
</form>
    FORM
  end

  # ------------------------------------------------
  # Password fields

  it '104. Make a form with input_password(label, name)' do
    out = form_for(nil , :method => :get) do |f|
      f.input_password 'Password', :password
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_password">Password</label>
    <input type="password" name="password" id="form_password" />
  </p>
</form>
    FORM
  end

  it '105. Make a form with input_password(label, name, value, class)' do
    out = form_for(@data, :method => :get) do |f|
      f.input_password 'Password', :password, :value => 'super-secret-password', :class => 'password_class'
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_password">Password</label>
    <input class="password_class" type="password" name="password" id="form_password" value="super-secret-password" />
  </p>
</form>
    FORM
  end

  # ------------------------------------------------
  # Submit buttons

  it '106. Make a form with input_submit()' do
    out = form_for(@data, :method => :get) do |f|
      f.input_submit
    end

    assert(<<-FORM, out)
<form method="get">
    <p>
      <input type="submit" />
    </p>
</form>
    FORM
  end

  it '107. Make a form with input_submit(value)' do
    out = form_for(@data, :method => :get) do |f|
      f.input_submit 'Send'
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <input type="submit" value="Send" />
  </p>
</form>
    FORM
  end

  # ------------------------------------------------
  # Checkboxes

  it '108. Make a form with input_checkbox(label, name)' do
    out = form_for(@data, :method => :get) do |f|
      f.input_checkbox 'Assigned', :assigned
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_assigned_0">Assigned</label>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned[]" id="form_assigned_0" value="bacon" /> bacon</span>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned[]" id="form_assigned_1" value="steak" /> steak</span>
  </p>
</form>
    FORM
  end

  it '109. Make a form with input_checkbox(label, name, checked)' do
    out = form_for(@data, :method => :get) do |f|
      f.input_checkbox 'Assigned', :assigned, 'bacon'
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_assigned_0">Assigned</label>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned[]" id="form_assigned_0" checked="checked" value="bacon" /> bacon</span>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned[]" id="form_assigned_1" value="steak" /> steak</span>
  </p>
</form>
    FORM
  end

  it '110. Make a form with input_checkbox(label, name, checked, values, default)' do
    out = form_for(@data, :method => :get) do |f|
      f.input_checkbox 'Assigned', :assigned, 'boo', :values => ['boo']
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_assigned_0">Assigned</label>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned[]" id="form_assigned_0" checked="checked" value="boo" /> boo</span>
  </p>
</form>
    FORM
  end

  it '111. Make a form with input_checkbox and check multiple values using an array' do
    out = form_for(@data, :method => :get) do |f|
      f.input_checkbox 'Assigned', :assigned, ['boo'], :values => ['boo', 'foo']
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_assigned_0">Assigned</label>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned[]" id="form_assigned_0" checked="checked" value="boo" /> boo</span>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned[]" id="form_assigned_1" value="foo" /> foo</span>
  </p>
</form>
    FORM
  end

  it '112. Make a form with input_checkbox and check multiple values using a hash' do
    out = form_for(@data, :method => :get) do |f|
      f.input_checkbox 'Assigned', :assigned, ['boo'], :values => {'Boo' => 'boo'}
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_assigned_0">Assigned</label>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned[]" id="form_assigned_0" checked="checked" value="boo" /> Boo</span>
  </p>
</form>
    FORM
  end

  it '113. Make a form with input_checkbox(label, name) but hide the value of the checkbox' do
    out = form_for(@data, :method => :get) do |f|
      f.input_checkbox 'Assigned', :assigned, nil, :show_value => false
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_assigned_0">Assigned</label>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned[]" id="form_assigned_0" value="bacon" /></span>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned[]" id="form_assigned_1" value="steak" /></span>
  </p>
</form>
    FORM
  end

  it '114. Make a form with input_checkbox(label, name) but hide the label' do
    out = form_for(@data, :method => :get) do |f|
      f.input_checkbox 'Assigned', :assigned, nil, :show_label => false
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned[]" id="form_assigned_0" value="bacon" /> bacon</span>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned[]" id="form_assigned_1" value="steak" /> steak</span>
  </p>
</form>
    FORM
  end

  # ------------------------------------------------
  # Checkboxes using a hash

  it '115. Make a form with input_checkbox(label, name) using a hash' do
    out = form_for(@data, :method => :get) do |f|
      f.input_checkbox 'Assigned', :assigned_hash
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_assigned_hash_0">Assigned</label>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned_hash[]" id="form_assigned_hash_0" value="bacon" /> Bacon</span>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned_hash[]" id="form_assigned_hash_1" value="steak" /> Steak</span>
  </p>
</form>
    FORM
  end

  it '116. Make a form with input_checkbox(label, name, checked) using a hash' do
    out = form_for(@data, :method => :get) do |f|
      f.input_checkbox 'Assigned', :assigned_hash, 'bacon'
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_assigned_hash_0">Assigned</label>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned_hash[]" id="form_assigned_hash_0" checked="checked" value="bacon" /> Bacon</span>
    <span class="checkbox_wrap"><input type="checkbox" name="assigned_hash[]" id="form_assigned_hash_1" value="steak" /> Steak</span>
  </p>
</form>
    FORM
  end

  # ------------------------------------------------
  # Radio buttons

  it '117. Make a form with input_radio(label, name)' do
    out = form_for(@data, :method => :get) do |f|
      f.input_radio 'Assigned', :assigned
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_assigned_0">Assigned</label>
    <span class="radio_wrap"><input type="radio" name="assigned" id="form_assigned_0" value="bacon" /> bacon</span>
    <span class="radio_wrap"><input type="radio" name="assigned" id="form_assigned_1" value="steak" /> steak</span>
  </p>
</form>
    FORM
  end

  it '118. Make a form with input_radio(label, name, checked)' do
    out = form_for(@data, :method => :get) do |f|
      f.input_radio 'Assigned', :assigned, 'bacon'
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_assigned_0">Assigned</label>
    <span class="radio_wrap"><input type="radio" name="assigned" id="form_assigned_0" checked="checked" value="bacon" /> bacon</span>
    <span class="radio_wrap"><input type="radio" name="assigned" id="form_assigned_1" value="steak" /> steak</span>
  </p>
</form>
    FORM
  end

  it '119. Make a form with input_radio(label, name, checked, values, default)' do
    out = form_for(@data, :method => :get) do |f|
      f.input_radio 'Assigned', :assigned, 'boo', :values => ['boo']
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_assigned_0">Assigned</label>
    <span class="radio_wrap"><input type="radio" name="assigned" id="form_assigned_0" checked="checked" value="boo" /> boo</span>
  </p>
</form>
    FORM
  end

  it '120. Make a form with input_radio(label, name) but hide the value' do
    out = form_for(@data, :method => :get) do |f|
      f.input_radio 'Assigned', :assigned, nil, :show_value => false
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_assigned_0">Assigned</label>
    <span class="radio_wrap"><input type="radio" name="assigned" id="form_assigned_0" value="bacon" /></span>
    <span class="radio_wrap"><input type="radio" name="assigned" id="form_assigned_1" value="steak" /></span>
  </p>
</form>
    FORM
  end

  it '121. Make a form with input_radio(label, name) but hide the label' do
    out = form_for(@data, :method => :get) do |f|
      f.input_radio 'Assigned', :assigned, nil, :show_label => false
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <span class="radio_wrap"><input type="radio" name="assigned" id="form_assigned_0" value="bacon" /> bacon</span>
    <span class="radio_wrap"><input type="radio" name="assigned" id="form_assigned_1" value="steak" /> steak</span>
  </p>
</form>
    FORM
  end


  # ------------------------------------------------
  # Radio buttons using a hash

  it '122. Make a form with input_radio(label, name) using a hash' do
    out = form_for(@data, :method => :get) do |f|
      f.input_radio 'Assigned', :assigned_hash
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_assigned_hash_0">Assigned</label>
    <span class="radio_wrap"><input type="radio" name="assigned_hash" id="form_assigned_hash_0" value="bacon" /> Bacon</span>
    <span class="radio_wrap"><input type="radio" name="assigned_hash" id="form_assigned_hash_1" value="steak" /> Steak</span>
  </p>
</form>
    FORM
  end

  it '123. Make a form with input_radio(label, name, checked) using a hash' do
    out = form_for(@data, :method => :get) do |f|
      f.input_radio 'Assigned', :assigned_hash, 'bacon'
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_assigned_hash_0">Assigned</label>
    <span class="radio_wrap"><input type="radio" name="assigned_hash" id="form_assigned_hash_0" checked="checked" value="bacon" /> Bacon</span>
    <span class="radio_wrap"><input type="radio" name="assigned_hash" id="form_assigned_hash_1" value="steak" /> Steak</span>
  </p>
</form>
    FORM
  end

  # ------------------------------------------------
  # File uploading

  it '124. Make a form with input_file(label, name)' do
    out = form_for(@data, :method => :get) do |f|
      f.input_file 'File', :file
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_file">File</label>
    <input type="file" name="file" id="form_file" />
  </p>
</form>
    FORM
  end

  it '125. Make a form with input_file(label, name)' do
    out = form_for(@data, :method => :get) do |f|
      f.input_file 'File', :file, :id => 'awesome_file'
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="awesome_file">File</label>
    <input type="file" name="file" id="awesome_file" />
  </p>
</form>
    FORM
  end

  # ------------------------------------------------
  # Hidden fields

  it '125. Make a form with input_hidden(name)' do
    out = form_for(@data, :method => :get) do |f|
      f.input_hidden :username
    end

    assert(<<-FORM, out)
<form method="get">
  <input type="hidden" name="username" value="mrfoo" />
</form>
    FORM
  end

  it '126. Make a form with input_hidden(name, value)' do
    out = form_for(@data, :method => :get) do |f|
      f.input_hidden :username, 'Bob Ross'
    end

    assert(<<-FORM, out)
<form method="get">
  <input type="hidden" name="username" value="Bob Ross" />
</form>
    FORM
  end

  it '127. Make a form with input_hidden(name, value, id)' do
    out = form_for(@data, :method => :get) do |f|
      f.input_hidden :username, 'Bob Ross', :id => 'test'
    end

    assert(<<-FORM, out)
<form method="get">
  <input type="hidden" name="username" value="Bob Ross" id="test" />
</form>
    FORM
  end

  # ------------------------------------------------
  # Textarea elements

  it '128. Make a form with textarea(label, name)' do
    out = form_for(@data, :method => :get) do |f|
      f.textarea 'Message', :message
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_message">Message</label>
    <textarea name="message" id="form_message">Hello, textarea!</textarea>
  </p>
</form>
    FORM
  end

  it '129. Make a form with textarea(label, name, value)' do
    out = form_for(@data, :method => :get) do |f|
      f.textarea 'Message', :message, :value => 'stuff'
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_message">Message</label>
    <textarea name="message" id="form_message">stuff</textarea>
  </p>
</form>
    FORM
  end

  # ------------------------------------------------
  # Select elements

  it '130. Make a form with select(label, name) from a hash' do
    out = form_for(@data, :method => :get) do |f|
      f.select 'Server', :servers_hash
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_servers_hash">Server</label>
    <select id="form_servers_hash" size="3" name="servers_hash">
      <option value="webrick">WEBrick</option>
      <option value="mongrel">Mongrel</option>
      <option value="thin">Thin</option>
    </select>
  </p>
</form>
    FORM
  end

  it '131. Make a form with select(label, name, selected) from a hash' do
    out = form_for(@data, :method => :get) do |f|
      f.select 'Server', :servers_hash, :selected => :mongrel
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_servers_hash">Server</label>
    <select id="form_servers_hash" size="3" name="servers_hash">
      <option value="webrick">WEBrick</option>
      <option value="mongrel" selected="selected">Mongrel</option>
      <option value="thin">Thin</option>
    </select>
  </p>
</form>
    FORM
  end

  it '132. Make a form with select(label, name) from an array' do
    out = form_for(@data, :method => :get) do |f|
      f.select 'Server', :servers_array
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_servers_array">Server</label>
    <select id="form_servers_array" size="3" name="servers_array">
      <option value="WEBrick">WEBrick</option>
      <option value="Mongrel">Mongrel</option>
      <option value="Thin">Thin</option>
    </select>
  </p>
</form>
    FORM
  end

  it '133. Make a form with select(label, name, selected) from an array' do
    out = form_for(@data, :method => :get) do |f|
      f.select 'Server', :servers_array, :selected => 'Mongrel'
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_servers_array">Server</label>
    <select id="form_servers_array" size="3" name="servers_array">
      <option value="WEBrick">WEBrick</option>
      <option value="Mongrel" selected="selected">Mongrel</option>
      <option value="Thin">Thin</option>
    </select>
  </p>
</form>
    FORM
  end

  # ------------------------------------------------
  # Select elements with custom values

  it '134. Make a form with select(label, name) from a hash using custom values' do
    out = form_for(@data, :method => :get) do |f|
      f.select 'People', :people_hash, :values => {:chuck => 'Chuck', :bob => 'Bob'}
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_people_hash">People</label>
    <select id="form_people_hash" size="2" name="people_hash">
      <option value="chuck">Chuck</option>
      <option value="bob">Bob</option>
    </select>
  </p>
</form>
    FORM
  end

  it '135. Make a form with select(label, name, selected) from a hash using custom values' do
    out = form_for(@data, :method => :get) do |f|
      f.select 'People', :people_hash, :values => {:chuck => 'Chuck', :bob => 'Bob'}, :selected => :chuck
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_people_hash">People</label>
    <select id="form_people_hash" size="2" name="people_hash">
      <option value="chuck" selected="selected">Chuck</option>
      <option value="bob">Bob</option>
    </select>
  </p>
</form>
    FORM
  end

  it '136. Make a form with select(label, name) from an array using custom values' do
    out = form_for(@data, :method => :get) do |f|
      f.select 'People', :people_array, :values => ['Chuck', 'Bob']
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_people_array">People</label>
    <select id="form_people_array" size="2" name="people_array">
      <option value="Chuck">Chuck</option>
      <option value="Bob">Bob</option>
    </select>
  </p>
</form>
    FORM
  end

  it '137. Make a form with select(label, name, selected) from an array using custom values' do
    out = form_for(@data, :method => :get) do |f|
      f.select 'People', :people_array, :values => ['Chuck', 'Bob'], :selected => 'Chuck'
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_people_array">People</label>
    <select id="form_people_array" size="2" name="people_array">
      <option value="Chuck" selected="selected">Chuck</option>
      <option value="Bob">Bob</option>
    </select>
  </p>
</form>
    FORM
  end

  it '138. Make a form with multiple select(label, name) from a hash' do
    out = form_for(@data, :method => :get) do |f|
      f.select 'Server', :servers_hash, :multiple => :multiple
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_servers_hash">Server</label>
    <select id="form_servers_hash" size="3" name="servers_hash[]" multiple="multiple">
      <option value="webrick">WEBrick</option>
      <option value="mongrel">Mongrel</option>
      <option value="thin">Thin</option>
    </select>
  </p>
</form>
    FORM
  end

  it '139. Make a form with multiple select(label, name, selected) from a hash' do
    out = form_for(@data, :method => :get) do |f|
      f.select 'Server', :servers_hash, :multiple => :multiple, :selected => :webrick
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_servers_hash">Server</label>
    <select id="form_servers_hash" size="3" name="servers_hash[]" multiple="multiple">
      <option value="webrick" selected="selected">WEBrick</option>
      <option value="mongrel">Mongrel</option>
      <option value="thin">Thin</option>
    </select>
  </p>
</form>
    FORM
  end

  it '140. Make a form with multiple select(label, name, selected) from a hash' do
    out = form_for(@data, :method => :get) do |f|
      f.select 'Server', :servers_hash, :multiple => :multiple, :selected => [:webrick, :mongrel]
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_servers_hash">Server</label>
    <select id="form_servers_hash" size="3" name="servers_hash[]" multiple="multiple">
      <option value="webrick" selected="selected">WEBrick</option>
      <option value="mongrel" selected="selected">Mongrel</option>
      <option value="thin">Thin</option>
    </select>
  </p>
</form>
    FORM
  end

  # ------------------------------------------------
  # HTML5 Extensions

  it '141. Make a form with input_button(label, value) with JavaScript call' do
    out = form_for(@data, :method => :get) do |f|
      f.input_button 'Accept', :onclick=>'fcn()'
    end

    assert(<<-FORM, out)
<form method="get">
  <p><input value="Accept" type="button" onclick="fcn()" /></p>
</form>
    FORM
  end

  it '142. Make a form with input_color(label, name)' do
    out = form_for(@data, :method => :get) do |f|
      f.input_color 'Choose a color', :my_color
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_my_color">Choose a color</label>
    <input id="form_my_color" name="my_color" type="color" />
  </p>
</form>
    FORM
  end

  it '142. Make a form with input_email(label, value)' do
    out = form_for(@data, :method => :get) do |f|
      f.input_email 'Email', :email
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_email">Email</label>
    <input id="form_email" name="email" type="email" />
  </p>
</form>
    FORM
  end

  it '144. Make a form with input_image()' do
    out = form_for(@data, :method => :get) do |f|
      f.image "http://www.w3schools.com/tags/img_submit.gif", :alt=>"Submit"
    end

    assert(<<-FORM, out)
<form method="get">
    <p>
      <input alt="Submit" src="http://www.w3schools.com/tags/img_submit.gif" type="image" />
    </p>
</form>
    FORM
  end

  it '145. Make a form with input_number(label, value)' do
    out = form_for(@data, :method => :get) do |f|
      f.input_number 'Age', :age, :min=>1, :max=>120
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_age">Age</label>
    <input min="1" max="120" id="form_age" name="age" type="number" />
  </p>
</form>
    FORM
  end

  it '146. Make a form with input_range(label, value)' do
    out = form_for(@data, :method => :get) do |f|
      f.input_range 'Cost', :cost, :min=>0, :max=>100
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_cost">Cost</label>
    <input min="0" max="100" id="form_cost" name="cost" type="range" />
  </p>
</form>
    FORM
  end

  it '147. Make a form with input_reset()' do
    out = form_for(@data, :method => :get) do |f|
      f.input_reset
    end

    assert(<<-FORM, out)
<form method="get">
    <p>
      <input type="reset" />
    </p>
</form>
    FORM
  end

  it '148. Make a form with input_reset(value)' do
    out = form_for(@data, :method => :get) do |f|
      f.input_reset 'Reset'
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <input type="reset" value="Reset" />
  </p>
</form>
    FORM
  end

  it '149. Make a form with input_url(label, value)' do
    out = form_for(@data, :method => :get) do |f|
      f.input_url 'URL', :url
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_url">URL</label>
    <input id="form_url" name="url" type="url" />
  </p>
</form>
    FORM
  end

  # ------------------------------------------------
  # Verify that select boxes reload from the form object

  it '150. Make a form with select(label, name, selected) take <selected> from form object' do
    @data.person = "chuck"
    out = form_for(@data, :method => :get) do |f|
      f.select 'Person', :person, :values => {'chuck' => 'Chuck', 'bob' => 'Bob'}
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_person">Person</label>
    <select size="2" name="person" id="form_person">
      <option value="chuck" selected="selected">Chuck</option>
      <option value="bob">Bob</option>
    </select>
  </p>
</form>
    FORM
  end

  it '151. Make a form with select(label, name, selected) take <selected> from form object' do
    @data.person = "chuck"
    out = form_for(@data, :method => :get) do |f|
    	form_error(:person, "This person has not validated his email.")
      f.select 'Person', :person, :values => {'chuck' => 'Chuck', 'bob' => 'Bob'}
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_person">Person</label>
    <select size="2" name="person" id="form_person">
      <option value="chuck" selected="selected">Chuck</option>
      <option value="bob">Bob</option>
    </select>
  </p>
</form>
    FORM
  end

  # ------------------------------------------------
  # Code used in documentation

  it '160. Test error posting' do
    params = {:username=>"gladys", :password=>"abc", :gender=>"F", :country=>"SV"}
    user = UserX.new
    user.set_fields(params, [:username, :password, :gender, :country], :missing=>:skip)
    user.errors[:username] = "User not in system"
    user.errors[:password] = "The username/password combination is not on our system"
    out = form_for(user, :method=>:post, :action=>:login2) do |f|
      f.text("Username: ", :username)
      f.password("Password: ", :password)
    end.to_html

    assert(<<-FORM, out)
<form method="post" action="login2">
  <p>
    <label for="form_username"> Username: </label>
    <input id="form_username" name="username" value="gladys" type="text" />
    <span class="error"> &nbsp;User not in system </span>
  </p>
  <p>
    <label for="form_password"> Password: </label>
    <input id="form_password" name="password" value="abc" type="password" />
    <span class="error"> &nbsp;The username/password combination is not on our system </span>
  </p>
</form>
    FORM
  end

  # ------------------------------------------------
  # Error messages

  it '198. Insert an error message' do
    form_error :username, 'May not be empty'
    out = form_for(@data, :method => :get) do |f|
      f.input_text 'Username', :username
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_username">Username</label>
    <input id="form_username" name="username" value="mrfoo" type="text" />
    <span class="error">&nbsp;May not be empty</span>
  </p>
</form>
    FORM
  end

  it '199. Retrieve all errors messages from the model' do
    @data.errors = {:username => "May not be empty"}
    form_errors_from_model(@data)
    out = form_for(@data, :method => :get) do |f|
      f.input_text 'Username', :username
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_username">Username</label>
    <input id="form_username" name="username" value="mrfoo" type="text" />
    <span class="error">&nbsp;May not be empty</span>
  </p>
</form>
    FORM
  end

end
