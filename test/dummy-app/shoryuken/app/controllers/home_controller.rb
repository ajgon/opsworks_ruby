class HomeController < ApplicationController
  def index
    data = SecureRandom.hex(32)
    Dummy.create(field: data)
    @item = Dummy.last.field
  end
end
