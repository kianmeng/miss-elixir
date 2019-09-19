defmodule Miss.Map do
  @moduledoc """
  Extra functions for `Map` module.
  """

  @type transform :: [{module(), function()}]

  @doc """
  Converts a `struct` to map going through all nested structs, different from `Map.from_struct/1`
  that only converts the root struct.

  The optional parameter `transform` receives a list of tuples with the struct type and a function
  to be called instead of converting to a map. The transforming function will receive the struct
  as a single parameter.

  If you want to skip the conversion of a nested struct to map, just pass the atom `:skip` instead
  of a transformation function.

  `Date` or `Decimal` values are common examples where their map representation could be not so
  useful when converted in a nested struct. See the examples for more details.

  ## Examples

  Given the following structs:

      defmodule Post do
        defstruct [:title, :text, :date, :author, comments: []]
      end

      defmodule Author do
        defstruct [:name, :metadata]
      end

      defmodule Comment do
        defstruct [:text]
      end

      defmodule Metadata do
        defstruct [:atom, :boolean, :decimal, :float, :integer]
      end

      post = %Post{
        title: "My post",
        text: "Something really interesting",
        date: ~D[2010-09-01],
        author: %Author{
          name: "Pedro Bonamides",
          metadata: %Metadata{
            atom: :my_atom,
            boolean: true,
            decimal: Decimal.new("456.78"),
            float: 987.54,
            integer: 2_345_678
          }
        },
        comments: [
          %Comment{text: "Comment one"},
          %Comment{text: "Comment two"}
        ]
      }

  Convert all nested structs (including the `Date` and `Decimal` values):

      #{inspect(__MODULE__)}.from_nested_struct(post)
      %{
        title: "My post",
        text: "Something really interesting",
        date: %{calendar: Calendar.ISO, day: 1, month: 9, year: 2010},
        author: %{
          name: "Pedro Bonamides",
          metadata: %{
            atom: :my_atom,
            boolean: true,
            decimal: %{coef: 45678, exp: -2, sign: 1}
            float: 987.54,
            integer: 2_345_678
          }
        },
        comments: [
          %{text: "Comment one"},
          %{text: "Comment two"}
        ]
      }

  """
  @spec from_nested_struct(struct(), transform()) :: map()
  def from_nested_struct(%_{} = struct, transform \\ []), do: to_map(struct, transform)

  @spec to_map(term(), transform()) :: term()
  defp to_map(%_{} = struct, transform) do
    module = Map.get(struct, :__struct__)

    transform
    |> Keyword.get(module)
    |> case do
      nil ->
        struct
        |> Map.from_struct()
        |> Map.keys()
        |> Enum.reduce(%{}, fn key, map ->
          value =
            struct
            |> Map.get(key)
            |> to_map(transform)

          Map.put(map, key, value)
        end)

      fun when is_function(fun, 1) ->
        fun.(struct)

      :skip ->
        struct
    end
  end

  defp to_map(list, transform) when is_list(list),
    do: Enum.map(list, fn item -> to_map(item, transform) end)

  defp to_map(value, _transform), do: value
end
