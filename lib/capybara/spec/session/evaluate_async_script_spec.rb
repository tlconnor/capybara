Capybara::SpecHelper.spec "#evaluate_async_script", requires: [:js] do
  it "should evaluate the given script and return whatever it produces" do
    @session.visit('/with_js')
    expect(@session.evaluate_async_script("window.setTimeout(arguments[0].bind(null, 10), 5)")).to eq(10)
  end

  it "should pass arguments to the script", requires: [:js, :es_args] do
    @session.visit('/with_js')
    res = @session.evaluate_async_script("window.setTimeout(arguments[2].bind(null, arguments[0] * arguments[1]), 5)", 10, 10)
    expect(res).to eq(100)
  end

  it "should support passing elements as arguments to the script", requires: [:js, :es_args] do
    @session.visit('/with_js')
    el = @session.find(:css, '#change')
    res = @session.evaluate_async_script("
      var callback = arguments[2];
      var el = arguments[0];
      var new_text = arguments[1];
      window.setTimeout(function(){ el.textContent = new_text; callback(new_text); },1000)", el, "Doodle Funk")
    expect(res).to eq "Doodle Funk"
    expect(@session).to have_css('#change', text: 'Doodle Funk')
  end

  it "should support returning elements", requires: [:js, :es_args] do
    @session.visit('/with_js')
    el = @session.find(:css, '#change')
    el = @session.evaluate_async_script("window.setTimeout(arguments[0].bind(null, document.getElementById('change')), 10)")
    expect(el).to be_instance_of(Capybara::Node::Element)
    expect(el).to eq(@session.find(:css, '#change'))
  end
end
