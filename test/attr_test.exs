defmodule AttrTest do
  use ExUnit.Case
  doctest Excrawl

  import Excrawl
  require Excrawl

  @sample_doc """
    <html>
      <input id="foo" type="text" name="foo" value="123456789">
      <input id="bar" type="text" name="foo">
    </html>
  """

  parser :attr_test do
    attr name: :val, css: "input#foo", attribute: "value"
  end

  test "case4" do
    assert attr_test(@sample_doc) 
      == %{val: "123456789"}
  end

  parser :mandatory1 do
    attr name: :val, css: "input#bar", attribute: "value", mandatory: true
  end

  test "mandatory" do
    assert mandatory1(@sample_doc) 
      == {:error, "cant find attribute 'value' in 'input#bar'"}
  end
end
