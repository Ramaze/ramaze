require File.expand_path('../../../../spec/helper', __FILE__)
require 'ramaze/helper/blue_form'

describe BF = Ramaze::Helper::BlueForm do
  extend BF

  # Generate some dummy data
  @data = Class.new do
    attr_reader :username
    attr_reader :password
    attr_reader :assigned
    attr_reader :assigned_hash
    attr_reader :message
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

  # very strange comparision, sort all characters and compare, so we don't have
  # order issues.
  def assert(expected, output)
    left  = expected.to_s.gsub(/\s+/, ' ').gsub(/>\s+</, '><').strip
    right = output.to_s.gsub(/\s+/, ' ').gsub(/>\s+</, '><').strip
    left.scan(/./).sort.should == right.scan(/./).sort
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

  # ------------------------------------------------
  # Text fields

  it 'Make a form with input_text(label, value)' do
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

  it 'Make a form with input_text(username, label, value)' do
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

  it 'Make a form with input_text(label, name, size, id)' do
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

  it 'Make a form with input_password(label, name)' do
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

  it 'Make a form with input_password(label, name, value, class)' do
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

  it 'Make a form with input_submit()' do
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

  it 'Make a form with input_submit(value)' do
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

  it 'Make a form with input_checkbox(label, name)' do
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

  it 'Make a form with input_checkbox(label, name, checked)' do
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

  it 'Make a form with input_checkbox(label, name, checked, values, default)' do
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

  it 'Make a form with input_checkbox and check multiple values using an array' do
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

  it 'Make a form with input_checkbox and check multiple values using a hash' do
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

  it 'Make a form with input_checkbox(label, name) but hide the value of the checkbox' do
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

  it 'Make a form with input_checkbox(label, name) but hide thelabel' do
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

  it 'Make a form with input_checkbox(label, name) using a hash' do
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

  it 'Make a form with input_checkbox(label, name, checked) using a hash' do
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

  it 'Make a form with input_radio(label, name)' do
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

  it 'Make a form with input_radio(label, name, checked)' do
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

  it 'Make a form with input_radio(label, name, checked, values, default)' do
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

  it 'Make a form with input_radio(label, name) but hide the value' do
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

  it 'Make a form with input_radio(label, name) but hide the label' do
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

  it 'Make a form with input_radio(label, name) using a hash' do
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

  it 'Make a form with input_radio(label, name, checked) using a hash' do
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

  it 'Make a form with input_file(label, name)' do
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

  it 'Make a form with input_file(label, name)' do
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

  it 'Make a form with input_hidden(name, value)' do
    out = form_for(@data, :method => :get) do |f|
      f.input_hidden :username, 'Bob Ross'
    end

    assert(<<-FORM, out)
<form method="get">
  <input type="hidden" name="username" value="Bob Ross" />
</form>
    FORM
  end

  it 'Make a form with input_hidden(name, value, id)' do
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

  it 'Make a form with textarea(label, name)' do
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

  it 'Make a form with textarea(label, name, value)' do
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

  it 'Make a form with select(label, name) from a hash' do
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

  it 'Make a form with select(label, name, selected) from a hash' do
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

  it 'Make a form with select(label, name) from an array' do
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

  it 'Make a form with select(label, name, selected) from an array' do
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

  it 'Make a form with select(label, name) from a hash using custom values' do
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

  it 'Make a form with select(label, name, selected) from a hash using custom values' do
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

  it 'Make a form with select(label, name) from an array using custom values' do
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

  it 'Make a form with select(label, name, selected) from an array using custom values' do
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

  it 'Make a form with multiple select(label, name) from a hash' do
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

  it 'Make a form with multiple select(label, name, selected) from a hash' do
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

  it 'Make a form with multiple select(label, name, selected) from a hash' do
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
  # Error messages

  it 'Insert an error message' do
    form_error :username, 'May not be empty'
    out = form_for(@data, :method => :get) do |f|
      f.input_text 'Username', :username
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_username">Username <span class="error">May not be empty</span></label>
    <input type="text" name="username" id="form_username" value="mrfoo" />
  </p>
</form>
    FORM
  end

  it 'Retrieve all errors messages from the model' do
    @data.errors = {:username => "May not be empty"}
    form_errors_from_model(@data)

    out = form_for(@data, :method => :get) do |f|
      f.input_text 'Username', :username
    end

    assert(<<-FORM, out)
<form method="get">
  <p>
    <label for="form_username">Username <span class="error">May not be empty</span></label>
    <input type="text" name="username" id="form_username" value="mrfoo" />
  </p>
</form>
    FORM
  end

end
