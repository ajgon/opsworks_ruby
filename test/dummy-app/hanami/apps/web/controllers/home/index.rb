module Web::Controllers::Home
  class Index
    include Web::Action

    expose :item

    def call(params)
      data = SecureRandom.hex(32)
      dummy = Dummy.new(field: data)
      DummyRepository.create(dummy)
      @item = DummyRepository.last.field
    end
  end
end
