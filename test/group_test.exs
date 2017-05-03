defmodule GroupTest do
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

  parser :case2 do
    group name: :main, css: "#centerCol" do
      text name: :title, css: "#productTitle"
      text name: :price, css: "#priceblock_ourprice"
    end
  end

  test "case2" do
    assert case2(@sample_doc) == %{main: %{title: "Tralala", price: "123"}}
  end

  parser :case3 do
    groups name: :products, css: ".product" do
      text name: :name, css: "#name"
    end
  end

  test "case3" do
    assert case3(@sample_doc)
      == %{products: [%{name: "Foo"}, %{name: "Bar"}]}
  end

  parser :parse_group_in_group do
    group name: :html, css: "html" do
      group name: :main, css: "#centerCol" do
        text name: :title, css: "#productTitle"
        text name: :price, css: "#priceblock_ourprice"
      end
    end
  end

  test "group in group" do
    assert parse_group_in_group(@sample_doc) == %{html: %{main: %{title: "Tralala", price: "123"}}}
  end
end
