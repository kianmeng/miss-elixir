defmodule Miss.Map do
  @moduledoc """
  Extra functions for `Map` module.
  """

  @type from_struct_options :: [{:nested, boolean()}]

  @doc """
  Converts a `struct` to map.

  It accepts the struct module or a struct itself and simply removes the __struct__ field from the given struct or from a new struct generated from the given module.
  """
  @spec from_struct(atom() | struct(), from_struct_options()) :: map()
  def from_struct(struct, options \\ [nested: false])
  def from_struct(struct, nested: false), do: Map.from_struct(struct)

  def from_struct(struct, nested: true) do
    IO.puts("nested: true")
    # TODO: Implement it
    Map.from_struct(struct)
  end
end
