defmodule TextTest do
  use ExUnit.Case
  doctest Excrawl

  import Excrawl
  require Excrawl

  @sample_doc """
    <html>
      <span id="productTitle">NotMe</span>
      <div id="centerCol">
        <span id="productTitle">Tralala</span>
        <span id="priceblock_ourprice">123</span>
      </div>
      <div class="product">
        <span id="name">Foo</span>
      </div>
      <div class="product">
        <span id="name">Bar</span>
      </div>
      <input type="text" name="foo" value="123456789">
    </html>
  """

  parser :case1 do
    text name: :title, css: "div #productTitle"
    text name: :price, css: "div #priceblock_ourprice"
  end

  test "case1" do
    assert case1(@sample_doc) == %{title: "Tralala", price: "123"}
  end

  parser :mandatory_text do
    text name: :name, css: ".product #non_existing", mandatory: true
  end

  test "mandatory text" do
    assert mandatory_text(@sample_doc) == {:error, "cant find '.product #non_existing'"}
  end
end
