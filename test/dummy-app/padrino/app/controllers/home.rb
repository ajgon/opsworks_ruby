DummyApp::App.controllers :home do

  get :index, :map => '/' do
    data = SecureRandom.hex(32)
    Dummy.create(field: data)
    @item = Dummy.last.field
    render 'home/index'
  end

end
