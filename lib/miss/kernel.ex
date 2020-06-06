defmodule Miss.Kernel do
  @moduledoc """
  Functions to extend the Elixir `Kernel` module.
  """

  @doc """
  Performs an integer division and computes the remainder.

  `Miss.Kernel.div_rem/2` uses truncated division, which means:
  - the result of the division is always rounded towards zero
  - the remainder will always have the sign of the `dividend`

  Raises an `ArithmeticError` if one of the arguments is not an integer, or when the `divisor` is
  `0`.

  ## Examples

      iex> Miss.Kernel.div_rem(5, 2)
      {2, 1}

      iex> Miss.Kernel.div_rem(6, -4)
      {-1, 2}

      iex> Miss.Kernel.div_rem(-99, 2)
      {-49, -1}

      iex> Miss.Kernel.div_rem(10, 5)
      {2, 0}

      iex> Miss.Kernel.div_rem(0, 2)
      {0, 0}

      iex> Miss.Kernel.div_rem(5, 0)
      ** (ArithmeticError) bad argument in arithmetic expression

      iex> Miss.Kernel.div_rem(10.0, 2)
      ** (ArithmeticError) bad argument in arithmetic expression

      iex> Miss.Kernel.div_rem(10, 2.0)
      ** (ArithmeticError) bad argument in arithmetic expression

  """
  @spec div_rem(integer(), neg_integer() | pos_integer()) :: {integer(), integer()}
  def div_rem(dividend, divisor), do: {div(dividend, divisor), rem(dividend, divisor)}

  @doc """
  Creates a list of structs similar to `Kernel.struct/2`.

  In the same way that `Kernel.struct/2`, the `struct` argument may be an atom (which defines
  `defstruct`) or a `struct` itself.

  The second argument is a list of any `Enumerable` that emits two-element tuples (key-value
  pairs) during enumeration.

  Keys in the `Enumerable` that do not exist in the struct are automatically discarded. Note that
  keys must be atoms, as only atoms are allowed when defining a struct. If keys in the
  `Enumerable` are duplicated, the last entry will be taken (same behaviour as `Map.new/1`).

  This function is useful for dynamically creating a list of structs, as well as for converting a
  list of maps to a list of structs.

  ## Examples

      defmodule User do
        defstruct name: "User"
      end

      # Using a list of maps
      iex> Miss.Kernel.struct_list(User, [
      ...>   %{name: "Akira"},
      ...>   %{name: "Fernando"}
      ...> ])
      [
        %User{name: "Akira"},
        %User{name: "Fernando"}
      ]

      # Using a list of keywords
      iex> Miss.Kernel.struct_list(User, [
      ...>   [name: "Akira"],
      ...>   [name: "Fernando"]
      ...> ])
      [
        %User{name: "Akira"},
        %User{name: "Fernando"}
      ]

      # Using an existing struct
      iex> user = %User{name: "Other"}
      ...> Miss.Kernel.struct_list(user, [
      ...>   %{name: "Akira"},
      ...>   %{name: "Fernando"}
      ...> ])
      [
        %User{name: "Akira"},
        %User{name: "Fernando"}
      ]

      # Known keys are used and unknown keys are ignored
      iex> Miss.Kernel.struct_list(User, [
      ...>   %{name: "Akira", last_name: "Hamasaki"},
      ...>   %{name: "Fernando", last_name: "Hamasaki"}
      ...> ])
      [
        %User{name: "Akira"},
        %User{name: "Fernando"}
      ]

      # Unknown keys are ignored
      iex> Miss.Kernel.struct_list(User, [
      ...>   %{first_name: "Akira"},
      ...>   %{last_name: "Hamasaki"}
      ...> ])
      [
        %User{name: "User"},
        %User{name: "User"}
      ]

      # String keys are ignored
      iex> Miss.Kernel.struct_list(User, [
      ...>   %{"name" => "Akira"},
      ...>   %{"name" => "Fernando"}
      ...> ])
      [
        %User{name: "User"},
        %User{name: "User"}
      ]

  """
  @spec struct_list(module() | struct(), [Enum.t()]) :: [struct()]
  def struct_list(struct, list), do: Enum.map(list, &struct(struct, &1))

  @doc """
  Creates a list of structs similar to `Miss.Kernel.struct_list/2`, but checks for key
  validity emulating the compile time behaviour of structs.

  ## Examples

      defmodule User do
        defstruct name: "User"
      end

      # Using a list of maps
      iex> Miss.Kernel.struct_list!(User, [
      ...>   %{name: "Akira"},
      ...>   %{name: "Fernando"}
      ...> ])
      [
        %User{name: "Akira"},
        %User{name: "Fernando"}
      ]

      # Using a list of keywords
      iex> Miss.Kernel.struct_list!(User, [
      ...>   [name: "Akira"],
      ...>   [name: "Fernando"]
      ...> ])
      [
        %User{name: "Akira"},
        %User{name: "Fernando"}
      ]

      # Using an existing struct
      iex> user = %User{name: "Other"}
      ...> Miss.Kernel.struct_list!(user, [
      ...>   %{name: "Akira"},
      ...>   %{name: "Fernando"}
      ...> ])
      [
        %User{name: "Akira"},
        %User{name: "Fernando"}
      ]

      # Known keys are used and unknown keys are ignored
      iex> Miss.Kernel.struct_list!(User, [
      ...>   %{name: "Akira", last_name: "Hamasaki"},
      ...>   %{name: "Fernando", last_name: "Hamasaki"}
      ...> ])
      ** (KeyError) key :last_name not found in: %Miss.KernelTest.User{name: "User"}

      # Unknown keys are ignored
      iex> Miss.Kernel.struct_list!(User, [
      ...>   %{first_name: "Akira"},
      ...>   %{last_name: "Hamasaki"}
      ...> ])
      ** (KeyError) key :first_name not found in: %Miss.KernelTest.User{name: "User"}

      # String keys are ignored
      iex> Miss.Kernel.struct_list!(User, [
      ...>   %{"name" => "Akira"},
      ...>   %{"name" => "Fernando"}
      ...> ])
      ** (KeyError) key "name" not found in: %Miss.KernelTest.User{name: "User"}

  """
  @spec struct_list!(module() | struct(), [Enum.t()]) :: [struct()]
  def struct_list!(struct, list), do: Enum.map(list, &struct!(struct, &1))
end
