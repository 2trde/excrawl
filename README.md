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
      <span id="priceblock_ourprice" currency="USD">123</span>
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

### Access element text

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

### Access attributes

This example is accessing only content of elements. To access attributes
we can change it like

```elixir
parser :crawl_my_doc do
  text name: :title, css: "div #productTitle"
  text name: :price, css: "div #priceblock_ourprice"
  attr name: :currency, css: "div #priceblock_ourprice", attribute: "currency"
end
```

```elixir
%{title: "Tralala", price: "123", currency: "USD"}
```

### Grouping

Data can be grouped together. All css selectors of group
members are relative to the group root element.

```
parser :crawl_my_doc do
  group name: :main, css: "#centerCol" do
    text name: :title, css: "#productTitle"
    text name: :price, css: "#priceblock_ourprice"
  end
end
```

this will generate

```
%{main: %{title: "Tralala", price: "123"}}
```

### Groups

Groups become handy when we have many of them. Like parsing
a table with products we want one map for each product.

```html
<div class="products">
  <div class="product">
    <span class="name">Drill</span>
    <span class="price">100<span>
  </div>
  <div class="product">
    <span class="name">Hammer</span>
    <span class="price">20<span>
  </div>

</div>
```

The parse would look like

```
  parser :parse_groups do
    groups name: :products, css: ".product" do
      text name: :name, css: ".name"
      text name: :price, css: ".price"
    end
  end
```

And gives the output

```
  [
    %{name: "Drill", price: 100},
    %{name: "Hammer", price: 20}
  ]
```
