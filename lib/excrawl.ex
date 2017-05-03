defmodule Excrawl do
  defmacro parser(name, handler) do
    quote do
      def group([:unused], _, _), do: nil

      @ctx_stack []
      @ctx [unquote(name)]
      @members []
      @members_stack []
      unquote(handler[:do])
      def unquote(name)(input) do
        try do
          @members
          |> Enum.reduce(%{}, fn({name, fun}, map) ->
            Map.put(map, name, fun.(@ctx, name, input))
          end)
        catch
          error -> {:error, error}
        end
      end
    end
  end

  defmacro text(opts) do
    check = case opts[:mandatory] do
      true ->
        quote do
          if length(result) == 0, do: throw "cant find '#{unquote(opts[:css])}'"
        end
      _ ->
        nil
    end

    quote do
      @members [{unquote(opts[:name]), &__MODULE__.text/3} | @members]
      def text(@ctx, unquote(opts[:name]), input) do
        result = Floki.find(input, unquote(opts[:css]))
        unquote(check)
        Floki.text(result)
      end
    end
  end

  defmacro attr(opts) do
    check = case opts[:mandatory] do
      true ->
        quote do
          if length(result) == 0, do: throw "cant find attribute '#{unquote(opts[:attribute])}' in '#{unquote(opts[:css])}'"
        end
      _ ->
        nil
    end

    quote do
      @members [{unquote(opts[:name]), &__MODULE__.attr/3} | @members]
      def attr(@ctx, unquote(opts[:name]), input) do
        result = Floki.find(input, unquote(opts[:css]))
                 |> Floki.attribute(unquote(opts[:attribute]))
        unquote(check)
        Floki.text(result)
      end
    end
  end

  defmacro group(opts, handler) do
    quote do
      @ctx_stack [@ctx | @ctx_stack]
      @ctx [unquote(opts[:name]) | @ctx]

      @members [{unquote(opts[:name]), &__MODULE__.group/3} | @members]
      @members_stack [@members | @members_stack]
      @members []

      unquote(handler[:do])

      @my_ctx hd(@ctx_stack)
      def group(@my_ctx, unquote(opts[:name]), input) do
        input = Floki.find(input, unquote(opts[:css]))
        @members
        |> Enum.reduce(%{}, fn({name, fun}, map) ->
          Map.put(map, name, fun.(@ctx, name, input))
        end)
      end

      @members hd(@members_stack)
      @members_stack tl(@members_stack)

      @ctx hd(@ctx_stack)
      @ctx_stack tl(@ctx_stack)
    end
  end

  defmacro groups(opts, handler) do
    quote do
      @ctx_stack [@ctx | @ctx_stack]
      @ctx [unquote(opts[:name]) | @ctx]

      @members [{unquote(opts[:name]), &__MODULE__.group/3} | @members]
      @members_stack [@members | @members_stack]
      @members []

      unquote(handler[:do])

      @my_ctx hd(@ctx_stack)
      def group(@my_ctx, unquote(opts[:name]), input) do
        input = Floki.find(input, unquote(opts[:css]))
				|> Enum.map(fn(input) ->
          @members
          |> Enum.reduce(%{}, fn({name, fun}, map) ->
            Map.put(map, name, fun.(@ctx, name, input))
          end)
        end)
      end

      @members hd(@members_stack)
      @members_stack tl(@members_stack)

      @ctx hd(@ctx_stack)
      @ctx_stack tl(@ctx_stack)
    end
  end
end
