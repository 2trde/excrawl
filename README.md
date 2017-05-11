# Excrawl

Excrawl provides a DSL to create web crawler.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add excrawl to your list of dependencies in `mix.exs`:

        def deps do
          [{:excrawl, github: "mlankenau/excrawl"}]
        end

  2. Ensure excrawl is started before your application:

        def application do
          [applications: [:excrawl]]
        end

## Usage

Excrawl is using floki to turn html markup into datastructures. A dsl
helps to define what to parse.

Example markup
```html
<html>
  <body>
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
  </body>
</html>
```

DSL
```elixir
parser :crawl_my_doc do
  text name: :title, css: "div #productTitle"
  text name: :price, css: "div #priceblock_ourprice"
end
```

The DSL will generate a function ```crawl_my_doc(markup)``` that
will return

```elixir
%{title: "Tralala", price: "123"}
```
